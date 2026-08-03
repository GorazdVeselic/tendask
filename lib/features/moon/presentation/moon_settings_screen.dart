import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_icons.dart';
import '../../../core/auth/auth_service.dart';
import '../../../core/biodynamic/calendar_system.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/notifications/notification_settings.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import '../../../core/glyphs.dart';
import '../../notifications/presentation/notification_priming_sheet.dart';
import '../../plus/application/plus_provider.dart';
import '../../settings/application/profile_providers.dart';
import '../application/moon_settings_controller.dart';

/// Moon calendar settings (FR-19 T3.6, wireframe board 2b): the zodiac-system
/// toggle, the five display sub-toggles and a "what is this" explainer. Reached
/// via ⚙️ on the calendar and via the "Moon calendar" row on /tendask-plus.
///
/// There is no master switch any more (decision B3): the phase on Home is the
/// one free hook and stays visible for everyone. Without Tendask+ the screen is
/// a SHOWROOM — everything is here but disabled, showing the DEFAULTS (all on,
/// by constellations), i.e. the picture of what the licence brings rather than
/// the user's own state. The explainer shows either way.
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
    final isPlus = ref.watch(plusActiveProvider);
    final hint = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      height: 1.4,
    );

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(kIconArrowBack),
          onPressed: context.pop,
        ),
        title: Text(t.moon.calendar.title),
        centerTitle: true,
      ),
      body: settingsAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (_, _) => Center(child: Text(t.moon.settings.load_error)),
        data: (stored) {
          final shown = isPlus ? stored : kMoonSettingsDefaults;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
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
                selected: {shown.system},
                showSelectedIcon: false,
                onSelectionChanged: isPlus
                    ? (s) => unawaited(controller.setSystem(s.first))
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(2, 8, 2, 0),
                // The chosen system explains itself — one general sentence for
                // both left the reader to guess which half applied.
                child: Text(
                  switch (shown.system) {
                    CalendarSystem.sidereal =>
                      t.moon.settings.system_help_sidereal,
                    CalendarSystem.tropical =>
                      t.moon.settings.system_help_tropical,
                  },
                  style: hint,
                ),
              ),

              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    _HintTile(enabled: isPlus),
                    _MoonSwitch(
                      glyph: kGlyphSubject,
                      title: t.moon.settings.highlight_garden,
                      subtitle: t.moon.settings.highlight_garden_sub,
                      value: shown.highlightGarden,
                      onChanged: isPlus
                          ? (v) => unawaited(controller.setHighlightGarden(v))
                          : null,
                    ),
                    _MoonSwitch(
                      glyph: kGlyphCalendarLayer,
                      title: t.moon.settings.show_in_journal,
                      subtitle: t.moon.settings.show_in_journal_sub,
                      value: shown.showInJournal,
                      onChanged: isPlus
                          ? (v) => unawaited(controller.setShowInJournal(v))
                          : null,
                    ),
                    _MoonSwitch(
                      glyph: kGlyphAstro,
                      title: t.moon.settings.show_astro,
                      subtitle: t.moon.settings.show_astro_sub,
                      value: shown.showAstroDetails,
                      onChanged: isPlus
                          ? (v) => unawaited(controller.setShowAstroDetails(v))
                          : null,
                    ),
                    _MoonSwitch(
                      glyph: kGlyphElementLabels,
                      title: t.moon.settings.show_element_labels,
                      subtitle: t.moon.settings.show_element_labels_sub,
                      value: shown.showElementLabels,
                      onChanged: isPlus
                          ? (v) => unawaited(controller.setShowElementLabels(v))
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              const _AboutCard(),
            ],
          );
        },
      ),
    );
  }
}

/// One sub-toggle row: emoji, title, small qualifier. A null [onChanged] greys
/// the row out — the showroom state without Tendask+.
class _MoonSwitch extends StatelessWidget {
  const _MoonSwitch({
    required this.glyph,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String glyph;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Text(glyph, style: const TextStyle(fontSize: 22)),
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }
}

/// The 🔔 opt-in for the "tomorrow is a X day" hint (FR-19 T4b). The only row
/// here that is NOT device-local: it lives in the profile and syncs with the
/// account (decision B1), so it reads and writes the notification settings
/// instead of [MoonSettingsController].
class _HintTile extends ConsumerWidget {
  const _HintTile({required this.enabled});

  /// False without Tendask+: the row then shows the showroom picture and never
  /// touches the profile stream.
  final bool enabled;

  Future<void> _set(
    BuildContext context,
    WidgetRef ref,
    NotificationSettings settings,
    bool on,
  ) async {
    if (on) {
      final notif = ref.read(notificationServiceProvider);
      // Denied → leave it off; the switch mirrors what is stored.
      if (!await _ensurePermission(context, notif)) return;
    }
    final userId = ref.read(authServiceProvider).userId;
    // The hint coordinator re-arms itself off the profile table update.
    await ref
        .read(profileRepositoryProvider)
        .setNotificationSettings(
          userId,
          settings.copyWith(moonHintEnabled: on),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    if (!enabled) {
      // Shown ON like the other four, even though the stored opt-in defaults to
      // off: the showroom paints what the licence brings, not a stored value.
      return _MoonSwitch(
        glyph: kGlyphBell,
        title: t.moon.settings.hint,
        subtitle: t.moon.settings.hint_sub,
        value: true,
        onChanged: null,
      );
    }
    final settingsAsync = ref.watch(notificationSettingsProvider);
    final settings = settingsAsync.asData?.value;

    return _MoonSwitch(
      glyph: kGlyphBell,
      title: t.moon.settings.hint,
      subtitle: settingsAsync.hasError
          ? t.moon.settings.load_error
          : t.moon.settings.hint_sub,
      value: settings?.moonHintEnabled ?? false,
      onChanged: settings == null
          ? null
          : (v) => unawaited(_set(context, ref, settings, v)),
    );
  }
}

/// Notification permission for the hint. It rides the inexact nudge channel, so
/// unlike a task reminder it needs no exact-alarm grant — priming (screen 21)
/// plus POST_NOTIFICATIONS is the whole flow.
Future<bool> _ensurePermission(
  BuildContext context,
  NotificationService notif,
) async {
  if (await notif.areNotificationsEnabled()) return true;
  if (!context.mounted) return false;
  if (await showNotificationPriming(context) != true) return false;
  return notif.requestPermission();
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
