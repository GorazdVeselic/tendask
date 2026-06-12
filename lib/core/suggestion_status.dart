/// Suggestion lifecycle values stored in the drift/Supabase `status` column.
///
/// Plain constants instead of a Dart enum on purpose: the DB value must be
/// exactly 'new' (mirror of the Supabase CHECK constraint) and `new` is a
/// reserved word in Dart — drift's textEnum cannot remap it (same pattern as
/// sync_status.dart).
library;

const kSuggestionNew = 'new';
const kSuggestionPlanned = 'planned';
const kSuggestionDismissed = 'dismissed';
const kSuggestionLogged = 'logged';
const kSuggestionExpired = 'expired';

/// `dismiss_scope` values — meaningful only with status = dismissed.
const kDismissScopeSeason = 'season';
const kDismissScopeForever = 'forever';
