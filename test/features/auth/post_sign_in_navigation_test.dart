import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:h3_flutter/h3_flutter.dart';
import 'package:tendask/core/database/app_database.dart';
import 'package:tendask/core/database/database_provider.dart';
import 'package:tendask/core/location/location_repository.dart';
import 'package:tendask/features/auth/presentation/post_sign_in_navigation.dart';

// gardenCell() reads the profile directly and never touches H3, but
// locationRepositoryProvider still wires h3Provider — fake it so the real FFI
// library is never loaded under `flutter test`.
class _FakeH3 implements H3 {
  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class _Trigger extends ConsumerStatefulWidget {
  const _Trigger({this.syncFuture});
  final Future<void>? syncFuture;
  @override
  ConsumerState<_Trigger> createState() => _TriggerState();
}

class _TriggerState extends ConsumerState<_Trigger> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      goToLocationOrHome(context, ref, syncFuture: widget.syncFuture);
    });
  }

  @override
  Widget build(BuildContext context) => const Scaffold(body: Text('START'));
}

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Future<void> seedCell(String? r7) => db
      .into(db.profiles)
      .insert(
        ProfilesCompanion.insert(
          userId: 'u',
          h3R7: Value(r7),
          updatedAt: DateTime.utc(2026, 6, 18),
        ),
      );

  Future<String> route(WidgetTester tester, {Future<void>? syncFuture}) async {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => _Trigger(syncFuture: syncFuture)),
        GoRoute(
          path: '/home',
          builder: (_, __) => const Scaffold(body: Text('HOME')),
        ),
        GoRoute(
          path: '/location',
          builder: (_, __) => const Scaffold(body: Text('LOCATION')),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          databaseProvider.overrideWith((ref) => db),
          h3Provider.overrideWith((ref) => _FakeH3()),
        ],
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    return router.routerDelegate.currentConfiguration.uri.path;
  }

  group('goToLocationOrHome', () {
    testWidgets('signed-in: pull restores the cell → /home', (tester) async {
      // The pull future writes the account's profile before completing.
      final pull = seedCell('871f8d4ffffffff');
      expect(await route(tester, syncFuture: pull), '/home');
    });

    testWidgets('signed-in: pull leaves no cell → /location', (tester) async {
      expect(await route(tester, syncFuture: Future<void>.value()), '/location');
    });

    testWidgets('pull error → falls back to the local cell (/home)', (
      tester,
    ) async {
      await seedCell('871f8d4ffffffff');
      // Defer the error so routing's await is attached before it fires (a bare
      // Future.error would be reported unhandled before the post-frame callback).
      final pull = Future<void>.delayed(
        const Duration(milliseconds: 10),
        () => throw StateError('offline'),
      );
      expect(await route(tester, syncFuture: pull), '/home');
    });

    testWidgets('guest with a local cell → /home', (tester) async {
      await seedCell('871f8d4ffffffff');
      expect(await route(tester), '/home');
    });

    testWidgets('guest without a cell → /location', (tester) async {
      expect(await route(tester), '/location');
    });
  });
}
