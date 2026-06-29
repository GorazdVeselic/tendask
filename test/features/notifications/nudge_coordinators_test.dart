import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/auth/auth_service.dart';
import 'package:tendask/core/config.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/catalog_provider.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/database/seed_service.dart';
import 'package:tendask/core/notifications/notification_service.dart';
import 'package:tendask/core/notifications/notification_settings.dart';
import 'package:tendask/features/areas/application/areas_providers.dart';
import 'package:tendask/features/notifications/application/journal_nudge_coordinator.dart';
import 'package:tendask/features/notifications/application/reminder_coordinator.dart';
import 'package:tendask/features/notifications/application/reminder_schedule.dart';
import 'package:tendask/features/plants/application/plants_providers.dart';
import 'package:tendask/features/settings/application/profile_providers.dart';
import 'package:tendask/features/settings/data/profile_repository.dart';
import 'package:tendask/features/supplies/data/supplies_repository.dart';
import 'package:tendask/features/tasks/application/tasks_providers.dart';
import 'package:tendask/features/tasks/data/tasks_repository.dart';
import 'package:tendask/i18n/translations.g.dart';

/// Records the OS-notification calls so we can assert what each coordinator
/// scheduled/cancelled. Overrides every method that would touch the real plugin,
/// so the inherited FlutterLocalNotificationsPlugin is never actually used.
class _FakeNotificationService extends NotificationService {
  _FakeNotificationService([Iterable<int> seed = const []])
    : pending = {...seed};

  final Set<int> pending;
  final scheduledReminders = <int>[];
  final scheduledNudges = <int>[];
  final nudgeTitles = <String>[];
  final cancelled = <int>[];

  @override
  Future<void> scheduleAt({
    required int id,
    required DateTime when,
    required String title,
    required String body,
    String? payload,
  }) async {
    pending.add(id);
    scheduledReminders.add(id);
  }

  @override
  Future<void> scheduleNudge({
    required int id,
    required DateTime when,
    required String title,
    required String body,
  }) async {
    pending.add(id);
    scheduledNudges.add(id);
    nudgeTitles.add(title);
  }

  @override
  Future<void> cancel(int id) async {
    pending.remove(id);
    cancelled.add(id);
  }

  @override
  Future<Set<int>> pendingIds() async => {...pending};
}

/// A stream that emits [value] immediately and stays open (closed on dispose),
/// mimicking a drift watch — so an autoDispose StreamProvider override doesn't
/// dispose mid-load the way a completing `Stream.value` does.
Stream<T> _open<T>(T value, Ref ref) {
  final c = StreamController<T>();
  c.add(value);
  ref.onDispose(c.close);
  return c.stream;
}

typedef _Env = ({
  ProviderContainer container,
  AppDatabase db,
  TasksRepository repo,
  ProfileRepository profileRepo,
  _FakeNotificationService notif,
});

Future<_Env> _setup({
  required NotificationSettings settings,
  Iterable<int> pendingSeed = const [],
}) async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await SeedService(db).runIfNeeded(); // catalog (task types) for FK on create()
  final profileRepo = ProfileRepository(db);
  await profileRepo.setNotificationSettings(kLocalUserId, settings);
  final repo = TasksRepository(db, SuppliesRepository(db));
  final notif = _FakeNotificationService(pendingSeed);

  final container = ProviderContainer(
    overrides: [
      databaseProvider.overrideWithValue(db),
      notificationServiceProvider.overrideWithValue(notif),
      authServiceProvider.overrideWithValue(AuthService(null)),
      profileRepositoryProvider.overrideWithValue(profileRepo),
      tasksRepositoryProvider.overrideWith((ref) => repo),
      // Label sources the reminder coordinator listens to. An empty map is enough
      // (title → 🔔, empty-subject body → date). A non-completing controller
      // mimics the production drift watch: it stays open, so the autoDispose
      // provider isn't disposed mid-load the way a completing Stream.value is.
      taskTypesMapProvider.overrideWith((ref) => _open(<String, TaskType>{}, ref)),
      areasMapProvider.overrideWith((ref) => _open(<String, Area>{}, ref)),
      userPlantsMapProvider.overrideWith(
        (ref) => _open(<String, UserPlant>{}, ref),
      ),
      plantsMapProvider.overrideWith((ref) => _open(<String, Plant>{}, ref)),
    ],
  );
  // Hold the label maps alive for the whole test. On-device the UI watches them;
  // here the coordinator's own ref.listen is the only holder, and an isolated
  // container would dispose the autoDispose providers mid-load.
  container.listen(taskTypesMapProvider, (_, _) {});
  container.listen(areasMapProvider, (_, _) {});
  container.listen(userPlantsMapProvider, (_, _) {});
  container.listen(plantsMapProvider, (_, _) {});
  return (
    container: container,
    db: db,
    repo: repo,
    profileRepo: profileRepo,
    notif: notif,
  );
}

void _registerTearDown(_Env env) {
  // LIFO: dispose the container (cancels the coordinator's db subscription)
  // before closing the database.
  addTearDown(() => env.db.close());
  addTearDown(env.container.dispose);
}

final _past = DateTime.utc(2026, 1, 1, 8);

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    LocaleSettings.setLocale(AppLocale.sl);
  });

  group('JournalNudgeCoordinator', () {
    test('opt-in (segment A): clears then schedules the chain with copy A', () async {
      final env = await _setup(settings: const NotificationSettings());
      _registerTearDown(env);

      env.container.read(journalNudgeCoordinatorProvider.notifier).start();
      await pumpEventQueue(times: 30);

      // Both reserved ids are cleared first, then re-scheduled in order.
      expect(env.notif.cancelled, containsAll(kJournalNudgeNotificationIds));
      expect(env.notif.scheduledNudges, kJournalNudgeNotificationIds);
      expect(env.notif.pending, {...kJournalNudgeNotificationIds});
      // No tasks → segment A copy.
      expect(env.notif.nudgeTitles, isNotEmpty);
      expect(
        env.notif.nudgeTitles.every((t0) => t0 == t.journal_nudge.title_a),
        isTrue,
      );
    });

    test('segment B copy once at least one task exists', () async {
      final env = await _setup(settings: const NotificationSettings());
      _registerTearDown(env);
      await env.repo.create(
        userId: kLocalUserId,
        taskTypeId: 'mow',
        date: _past,
        subjects: const [],
      );

      env.container.read(journalNudgeCoordinatorProvider.notifier).start();
      await pumpEventQueue(times: 30);

      expect(env.notif.scheduledNudges, kJournalNudgeNotificationIds);
      expect(
        env.notif.nudgeTitles.every((t0) => t0 == t.journal_nudge.title_b),
        isTrue,
      );
    });

    test('opt-out clears the chain and schedules nothing', () async {
      final env = await _setup(
        settings: const NotificationSettings(journalNudgeEnabled: false),
        pendingSeed: kJournalNudgeNotificationIds,
      );
      _registerTearDown(env);

      env.container.read(journalNudgeCoordinatorProvider.notifier).start();
      await pumpEventQueue(times: 30);

      expect(env.notif.cancelled, containsAll(kJournalNudgeNotificationIds));
      expect(env.notif.scheduledNudges, isEmpty);
      expect(env.notif.pending, isEmpty);
    });
  });

  group('ReminderCoordinator', () {
    test('master switch off: cancels its own ids, never the reserved nudge ids', () async {
      final env = await _setup(
        settings: const NotificationSettings(taskRemindersEnabled: false),
        pendingSeed: [555, ...kJournalNudgeNotificationIds],
      );
      _registerTearDown(env);

      env.container.read(reminderCoordinatorProvider.notifier).start();
      await pumpEventQueue(times: 30);

      expect(env.notif.cancelled, contains(555));
      expect(env.notif.cancelled, isNot(contains(-201)));
      expect(env.notif.cancelled, isNot(contains(-202)));
      // The journal nudge's reserved ids survive untouched.
      expect(env.notif.pending, containsAll(<int>[-201, -202]));
      expect(env.notif.scheduledReminders, isEmpty);
    });

    test('schedules future reminders, cancels orphans, spares the nudge ids', () async {
      final env = await _setup(
        settings: const NotificationSettings(),
        pendingSeed: [999, ...kJournalNudgeNotificationIds],
      );
      _registerTearDown(env);

      final future = DateTime.now().add(const Duration(days: 5));
      await env.repo.create(
        userId: kLocalUserId,
        taskTypeId: 'mow',
        date: future,
        subjects: const [],
        reminders: const [ReminderSpec(offsetMinutes: 0)],
      );
      final reminder = (await env.db.select(env.db.taskReminders).get()).single;
      final nid = reminderNotificationId(reminder.id);

      env.container.read(reminderCoordinatorProvider.notifier).start();
      await pumpEventQueue(times: 30);

      expect(env.notif.scheduledReminders, contains(nid));
      expect(env.notif.cancelled, contains(999)); // orphan dropped
      expect(env.notif.cancelled, isNot(contains(-201)));
      expect(env.notif.cancelled, isNot(contains(-202)));
      expect(env.notif.pending, containsAll(<int>[-201, -202]));
    });
  });
}
