import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config.dart';
import '../../../core/database/app_database.dart';
import '../../../i18n/translations.g.dart';
import '../application/suggestion_providers.dart';
import 'widgets/suggestion_card.dart';

/// The Home band of smart suggestions, shown above the task list. An empty list
/// legitimately renders nothing (no hole on Home); a local DB error shows a
/// quiet hint instead of silently swallowing the bug (CLAUDE.md).
class SuggestionBand extends ConsumerWidget {
  const SuggestionBand({super.key, this.highlightId});

  /// Suggestion id to briefly highlight (from a tapped push deep link).
  final String? highlightId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final suggestions = ref.watch(activeSuggestionsProvider);
    return switch (suggestions) {
      AsyncData(:final value) when value.isEmpty => const SizedBox.shrink(),
      AsyncData(:final value) => _Band(
        suggestions: value.take(kSuggestionBandMax).toList(),
        highlightId: highlightId,
      ),
      AsyncError() => const _BandError(),
      _ =>
        const SizedBox.shrink(), // loading: the band appears once it is ready
    };
  }
}

class _Band extends StatelessWidget {
  const _Band({required this.suggestions, this.highlightId});

  final List<Suggestion> suggestions;
  final String? highlightId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < suggestions.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            SuggestionCard(
              suggestion: suggestions[i],
              highlighted: suggestions[i].id == highlightId,
            ),
          ],
          // One disclaimer for the whole band — it qualifies the feature, not any
          // single card, so we don't repeat it per card.
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4, right: 4),
            child: Text(
              context.t.suggestions.disclaimer,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Quiet indicator for a local read failure — a suggestion DB error is a bug,
/// so we surface it calmly rather than hiding it with a shrink.
class _BandError extends StatelessWidget {
  const _BandError();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Text(
            context.t.common.load_error,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
