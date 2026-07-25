import 'package:drift/drift.dart';

/// Local-only tables — never pushed/pulled (excluded from the push/pull table
/// lists). They hold device-side bookkeeping and state that must not leave the
/// device.

/// Tracks how far the pull has progressed so the next pull is incremental
/// (updated_at >= last_pulled_at).
class SyncCursors extends Table {
  @override
  String get tableName => 'sync_cursor';

  // Cursor name — one global 'pull' row for now (room for per-table later).
  TextColumn get name => text()();
  // High-watermark: the newest updated_at successfully pulled so far (UTC).
  DateTimeColumn get lastPulledAt => dateTime()();

  @override
  Set<Column> get primaryKey => {name};
}

/// Device-local key/value flags — onboarding-seen now, later notification
/// priming / location prompt. Per-device UI state, never synced.
class LocalFlags extends Table {
  @override
  String get tableName => 'local_flag';

  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

/// Daily on-device cache of a community aggregate slice (V2 Okolica) — one pull
/// per bucket per day, then served locally (offline-friendly), mirroring the
/// weather-cache pattern (docs/skupnost-agregacija.md §12.4). Public aggregate
/// data, never synced; cleared with user data on sign-out.
class CommunityCaches extends Table {
  @override
  String get tableName => 'community_cache';

  // Cache key: '<metric>|<resolution>|<bucket_key>|<task_type_id>|<plant_id>'.
  TextColumn get key => text()();
  // JSON slice as returned by the aggregate query.
  TextColumn get payload => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}
