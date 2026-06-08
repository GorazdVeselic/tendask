import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:tendask/core/sync/sync_service.dart';

void main() {
  group('SyncService.sync', () {
    test('runs phases in order: session → push → pull → catalog', () async {
      final calls = <String>[];
      final svc = SyncService(
        hasSession: () => true,
        ensureSession: () async => calls.add('session'),
        push: () async => calls.add('push'),
        pull: () async => calls.add('pull'),
        catalog: () async => calls.add('catalog'),
      );

      await svc.sync(includeCatalog: true);

      expect(calls, ['session', 'push', 'pull', 'catalog']);
    });

    test(
      'without a session, push/pull are skipped but catalog still runs',
      () async {
        final calls = <String>[];
        final svc = SyncService(
          hasSession: () => false,
          ensureSession: () async => calls.add('session'),
          push: () async => calls.add('push'),
          pull: () async => calls.add('pull'),
          catalog: () async => calls.add('catalog'),
        );

        await svc.sync(includeCatalog: true);

        expect(calls, ['session', 'catalog']);
      },
    );

    test('catalog runs only when includeCatalog is set', () async {
      var catalogs = 0;
      final svc = SyncService(
        hasSession: () => true,
        ensureSession: () async {},
        catalog: () async => catalogs++,
      );

      await svc.sync();
      expect(catalogs, 0);

      await svc.sync(includeCatalog: true);
      expect(catalogs, 1);
    });

    test('a failing phase is isolated — later phases still run', () async {
      final calls = <String>[];
      final svc = SyncService(
        hasSession: () => true,
        ensureSession: () async => calls.add('session'),
        push: () async {
          calls.add('push');
          throw Exception('offline');
        },
        pull: () async => calls.add('pull'),
        catalog: () async => calls.add('catalog'),
      );

      await svc.sync(includeCatalog: true); // must not throw

      expect(calls, ['session', 'push', 'pull', 'catalog']);
    });

    test('re-entrant calls are skipped while a cycle is in flight', () async {
      var pushes = 0;
      final gate = Completer<void>();
      final svc = SyncService(
        hasSession: () => true,
        ensureSession: () async {},
        push: () async {
          pushes++;
          await gate.future;
        },
      );

      final first = svc.sync();
      await svc.sync(); // in-flight → no-op
      expect(pushes, 1);

      gate.complete();
      await first;

      // The guard releases after the cycle finishes — a later trigger runs.
      await svc.sync();
      expect(pushes, 2);
    });

    test('null seams (offline build) are skipped without error', () async {
      final svc = SyncService(
        hasSession: () => true,
        ensureSession: () async {},
      );

      await svc.sync(includeCatalog: true); // must not throw
    });
  });

  group('SyncService.flushPush', () {
    test('ensures session then pushes, returns true on success', () async {
      final calls = <String>[];
      final svc = SyncService(
        hasSession: () => true,
        ensureSession: () async => calls.add('session'),
        push: () async => calls.add('push'),
      );

      expect(await svc.flushPush(), isTrue);
      expect(calls, ['session', 'push']);
    });

    test('offline build (no push seam) returns true without pushing', () async {
      final svc = SyncService(
        hasSession: () => true,
        ensureSession: () async {},
      );

      expect(await svc.flushPush(), isTrue);
    });

    test('returns false when no session can be established', () async {
      var pushes = 0;
      final svc = SyncService(
        hasSession: () => false,
        ensureSession: () async {},
        push: () async => pushes++,
      );

      expect(await svc.flushPush(), isFalse);
      expect(pushes, 0); // never pushes without a session
    });

    test('returns false when the push fails (offline)', () async {
      final svc = SyncService(
        hasSession: () => true,
        ensureSession: () async {},
        push: () async => throw Exception('offline'),
      );

      expect(await svc.flushPush(), isFalse);
    });
  });
}
