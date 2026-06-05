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

/// The garden's raw coordinates, kept device-local for the weather lookup.
/// Privacy by design: coordinates NEVER leave the device — only the derived H3
/// cells sync (to profile). Single-row table (id fixed to 0 → upsert).
class DeviceLocations extends Table {
  @override
  String get tableName => 'device_location';

  IntColumn get id => integer().withDefault(const Constant(0))();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
