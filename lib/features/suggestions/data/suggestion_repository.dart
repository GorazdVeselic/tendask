import 'package:drift/drift.dart';

import '../../../core/clock.dart';
import '../../../core/database/app_database.dart';
import '../../../core/date_format.dart';
import '../../../core/suggestion_status.dart';
import '../../../core/sync/sync_status.dart';

/// Whether a dismiss mutes the suggestion for the season (default, gentle
/// "not this year") or forever (permanent mute of this rule for this subject).
/// The server derives the actual `dismissed_until` from the scope.
enum DismissScope { season, forever }

/// Reads engine-authored suggestions from drift (the sync pull writes them) and
/// records the user's Plan/Dismiss/Logged decisions locally; the sync push
/// carries the status change back to the cloud. Every method is LOCAL — the
/// repository never touches Supabase directly.
class SuggestionRepository {
  SuggestionRepository(this._db, {this._clock = const SystemClock()});

  final AppDatabase _db;
  final Clock _clock;

  /// Active band content: status 'new', not expired, whose subject is still
  /// present — newest score first. The subject filter mirrors the card removal
  /// instantly when a plant/area is deleted (ahead of server housekeeping).
  /// `cat:` suggestions have no subject FK, so the LEFT joins + OR keep them.
  Stream<List<Suggestion>> watchActive() {
    final today = startOfDay(_clock.now().toLocal());
    final query =
        _db.select(_db.suggestions).join([
            leftOuterJoin(
              _db.userPlants,
              _db.userPlants.id.equalsExp(_db.suggestions.userPlantId),
            ),
            leftOuterJoin(
              _db.areas,
              _db.areas.id.equalsExp(_db.suggestions.areaId),
            ),
          ])
          ..where(
            _db.suggestions.status.equals(kSuggestionNew) &
                _db.suggestions.deleted.equals(false) &
                _db.suggestions.validUntil.isBiggerOrEqualValue(today) &
                (_db.suggestions.userPlantId.isNull() |
                    _db.userPlants.deleted.equals(false)) &
                (_db.suggestions.areaId.isNull() |
                    _db.areas.deleted.equals(false)),
          )
          ..orderBy([
            OrderingTerm.desc(_db.suggestions.score),
            // Secondary keys keep the order stable on tied scores; id last makes
            // it a total order, so cards never reshuffle between rebuilds.
            OrderingTerm.asc(_db.suggestions.ruleId),
            OrderingTerm.asc(_db.suggestions.subjectKey),
            OrderingTerm.asc(_db.suggestions.id),
          ]);
    return query.watch().map(
      (rows) => rows.map((r) => r.readTable(_db.suggestions)).toList(),
    );
  }

  /// Links the created waiting task and retires the suggestion (status=planned).
  Future<void> markPlanned(String id, {required String plannedTaskId}) =>
      _setStatus(id, status: kSuggestionPlanned, plannedTaskId: plannedTaskId);

  /// User dismissed the suggestion. The server derives `dismissed_until` on its
  /// next run from the scope (season → window/cadence end, forever → permanent).
  Future<void> dismiss(String id, {DismissScope scope = DismissScope.season}) =>
      _setStatus(
        id,
        status: kSuggestionDismissed,
        dismissScope: scope == DismissScope.forever
            ? kDismissScopeForever
            : kDismissScopeSeason,
      );

  /// 'Already done': the caller has just created a DONE task with the chosen
  /// date; links it and retires the suggestion (status=logged). History and the
  /// post-completion cooldown silence future suggestions for this subject.
  Future<void> markLogged(String id, {required String doneTaskId}) =>
      _setStatus(id, status: kSuggestionLogged, plannedTaskId: doneTaskId);

  Future<void> _setStatus(
    String id, {
    required String status,
    String? plannedTaskId,
    String? dismissScope,
  }) =>
      // Guard on status='new': the first decision wins, so a fast double-tap
      // (e.g. Plan then Dismiss before the card disappears) can't overwrite an
      // already-decided suggestion — every legitimate transition starts at 'new'.
      (_db.update(
        _db.suggestions,
      )..where((s) => s.id.equals(id) & s.status.equals(kSuggestionNew))).write(
        SuggestionsCompanion(
          status: Value(status),
          plannedTaskId: plannedTaskId == null
              ? const Value.absent()
              : Value(plannedTaskId),
          dismissScope: dismissScope == null
              ? const Value.absent()
              : Value(dismissScope),
          updatedAt: Value(_clock.now()),
          syncStatus: const Value(kSyncPending),
        ),
      );
}
