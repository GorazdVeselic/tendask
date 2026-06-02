/// Lifecycle of a task. Stored as the enum name (`waiting` / `done`) via
/// drift `textEnum`, so the on-disk and Supabase string values stay stable.
enum TaskStatus { waiting, done }
