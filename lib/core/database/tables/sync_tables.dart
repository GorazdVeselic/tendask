import 'package:drift/drift.dart';

/// Local-only sync bookkeeping. Never pushed/pulled — it tracks how far the pull
/// has progressed so the next pull is incremental (updated_at >= last_pulled_at).
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
