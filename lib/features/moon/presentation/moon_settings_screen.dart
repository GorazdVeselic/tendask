import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/biodynamic/calendar_system.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import '../application/moon_settings_controller.dart';

/// Moon calendar settings (FR-19 T3.6, wireframe board 2b): the opt-in switch,
/// the zodiac-system toggle, the display sub-toggles and a "what is this"
/// explainer. Reached via ⚙️ on the calendar (Tendask+ entry comes with T6).
class MoonSettingsScreen extends ConsumerWidget {
  const MoonSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    // Warmed in bootstrap and keepAlive, so data is present in practice; the
    // spinner only covers the theoretical first-frame gap.
    final settingsAsync = ref.watch(moonSettingsControllerProvider);
    final controller = ref.read(moonSettingsControllerProvider.notifier);
    final hint = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      height: 1.4,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: context.pop,
        ),
        title: Text(t.moon.calendar.title),
        centerTitle: true,
      ),
      body: settingsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (_, _) => Center(child: Text(t.moon.settings.load_error)),
        data: (settings) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            Card(
              child: SwitchListTile(
                secondary: const Text('🌙', style: TextStyle(fontSize: 22)),
                title: Text(t.moon.settings.enable),
                subtitle: Text(t.moon.settings.enable_sub),
                value: settings.enabled,
                onChanged: (v) => unawaited(controller.setEnabled(v)),
              ),
            ),

            SectionLabel(t.moon.settings.system_label),
            SegmentedButton<CalendarSystem>(
              segments: [
                ButtonSegment(
                  value: CalendarSystem.sidereal,
                  label: _SystemSegment(
                    title: t.moon.settings.system_sidereal,
                    subtitle: t.moon.settings.system_sidereal_sub,
                  ),
                ),
                ButtonSegment(
                  value: CalendarSystem.tropical,
                  label: _SystemSegment(
                    title: t.moon.settings.system_tropical,
                    subtitle: t.moon.settings.system_tropical_sub,
                  ),
                ),
              ],
              selected: {settings.system},
              showSelectedIcon: false,
              onSelectionChanged: (s) =>
                  unawaited(controller.setSystem(s.first)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
              child: Text(t.moon.settings.system_help, style: hint),
            ),

            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: const Text('🪴', style: TextStyle(fontSize: 22)),
                    title: Text(t.moon.settings.highlight_garden),
                    subtitle: Text(t.moon.settings.highlight_garden_sub),
                    value: settings.highlightGarden,
                    onChanged: (v) =>
                        unawaited(controller.setHighlightGarden(v)),
                  ),
                  SwitchListTile(
                    secondary: const Text('📅', style: TextStyle(fontSize: 22)),
                    title: Text(t.moon.settings.show_in_journal),
                    subtitle: Text(t.moon.settings.show_in_journal_sub),
                    value: settings.showInJournal,
                    onChanged: (v) => unawaited(controller.setShowInJournal(v)),
                  ),
                  SwitchListTile(
                    secondary: const Text('🌌', style: TextStyle(fontSize: 22)),
                    title: Text(t.moon.settings.show_astro),
                    subtitle: Text(t.moon.settings.show_astro_sub),
                    value: settings.showAstroDetails,
                    onChanged: (v) =>
                        unawaited(controller.setShowAstroDetails(v)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            const _AboutCard(),
          ],
        ),
      ),
    );
  }
}

/// Two-line segment label (mechanism name over its small qualifier), matching
/// the wireframe's stacked segmented control.
class _SystemSegment extends StatelessWidget {
  const _SystemSegment({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          Text(title, textAlign: TextAlign.center),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// The tinted "what is this" explainer with the tradition-not-advice footnote.
class _AboutCard extends StatelessWidget {
  const _AboutCard();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final onContainer = theme.colorScheme.onPrimaryContainer;

    TextSpan bold(String text) => TextSpan(
      text: text,
      style: const TextStyle(fontWeight: FontWeight.w700),
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.moon.settings.about_title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: onContainer,
            ),
          ),
          const SizedBox(height: 6),
          Text.rich(
            t.moon.settings.about_body(b: bold),
            style: theme.textTheme.bodySmall?.copyWith(
              height: 1.5,
              color: onContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.moon.settings.about_footnote,
            style: theme.textTheme.labelSmall?.copyWith(
              color: onContainer.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
