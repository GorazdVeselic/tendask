import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/location/h3_cells.dart';
import 'package:tendask/core/location/location_repository.dart';
import 'package:tendask/core/task_status.dart';
import 'package:tendask/features/tasks/presentation/widgets/task_weather_section.dart';
import 'package:tendask/features/weather/presentation/weather_card.dart';
import 'package:tendask/i18n/translations.g.dart';

const _gardenPoint = (latitude: 46.22, longitude: 15.39);
final _date = DateTime.utc(2026, 7, 29, 8);

Task _task({required TaskStatus status, String? weather}) => Task(
  id: 'task-1',
  userId: 'u1',
  taskTypeId: 'water',
  date: _date,
  status: status,
  weather: weather,
  updatedAt: _date,
  deleted: false,
  syncStatus: 'synced',
);

String _frozenSnapshot() => jsonEncode({
  'capturedAt': _date.toIso8601String(),
  'temperature': 24.0,
  'weatherCode': 3,
});

Future<void> _pump(
  WidgetTester tester, {
  required Task task,
  required GardenCoords? location,
}) async {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(body: TaskWeatherSection(task: task)),
      ),
      GoRoute(
        path: '/location',
        builder: (_, _) => const Scaffold(body: Text('location screen')),
      ),
    ],
  );
  addTearDown(router.dispose);

  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: [
          gardenLocationProvider.overrideWith((ref) => Stream.value(location)),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    ),
  );
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
}

/// The no-location hint is rich text (a linked word inside the sentence), so
/// `find.text` — which only reads `Text.data` — never matches it. Compare the
/// plain text of the same translation instead.
String get _noLocationHint =>
    t.weather.detail_no_location(link: (text) => TextSpan(text: text))
        .toPlainText();

void main() {
  setUpAll(() => LocaleSettings.setLocale(AppLocale.sl));

  testWidgets('a waiting task with a location promises a snapshot', (
    tester,
  ) async {
    await _pump(
      tester,
      task: _task(status: TaskStatus.waiting),
      location: _gardenPoint,
    );

    expect(find.textContaining(t.weather.detail_waiting), findsOne);
    expect(find.textContaining(_noLocationHint), findsNothing);
  });

  testWidgets('a waiting task without a location explains and offers the fix', (
    tester,
  ) async {
    await _pump(tester, task: _task(status: TaskStatus.waiting), location: null);

    expect(find.textContaining(_noLocationHint), findsOne);

    // No button: the card itself is the way out.
    await tester.tap(find.textContaining(_noLocationHint));
    await tester.pumpAndSettle();
    expect(find.text('location screen'), findsOne);
  });

  testWidgets('a done task without a snapshot claims no cause and leads nowhere', (
    tester,
  ) async {
    // Same wording either way: the task does not record why the snapshot is
    // missing, and today's location says nothing about the day it was done.
    for (final location in [null, _gardenPoint]) {
      await _pump(
        tester,
        task: _task(status: TaskStatus.done),
        location: location,
      );

      expect(find.textContaining(t.weather.detail_none), findsOne);
      expect(find.textContaining(_noLocationHint), findsNothing);
      // Nothing to tap: a snapshot cannot be recovered after the fact.
      expect(find.byType(InkWell), findsNothing);
    }
  });

  testWidgets('a frozen snapshot still wins over every hint', (tester) async {
    await _pump(
      tester,
      task: _task(status: TaskStatus.done, weather: _frozenSnapshot()),
      location: null,
    );

    expect(find.byType(WeatherSnapshotCard), findsOne);
    expect(find.text(t.weather.detail_none), findsNothing);
  });
}
