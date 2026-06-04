/// Local-only sync state of a user row, stored in the drift `sync_status`
/// column. It NEVER leaves the device — Supabase has no such column (see
/// supabase/migrations/0001_schema.sql).
///
///   * [kSyncPending] — the row has local changes the push has not flushed yet.
///   * [kSyncSynced]  — the row matches the cloud (set after a successful push).
library;

const kSyncPending = 'pending';
const kSyncSynced = 'synced';
