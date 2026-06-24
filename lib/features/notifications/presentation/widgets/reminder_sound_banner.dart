import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/notifications/reminder_audio.dart';
import '../../../../i18n/translations.g.dart';

/// Calm-but-visible inline hint shown only when task reminders won't make a
/// sound (notification volume muted, or the phone is silent/vibrate). Tapping
/// "turn on sound" raises the notification volume and shows the system slider;
/// the reactive [reminderAudioProvider] then hides this the instant it's fixed.
/// Renders nothing while reminders are already audible.
class ReminderSoundBanner extends ConsumerWidget {
  const ReminderSoundBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.watch(reminderAudioProvider).asData?.value;
    if (audio == null || audio == ReminderAudio.audible) {
      return const SizedBox.shrink();
    }

    final t = context.t;
    final message = switch (audio) {
      ReminderAudio.volumeZero => t.reminder_sound.silent_volume,
      ReminderAudio.silentMode => t.reminder_sound.silent_mode,
      ReminderAudio.audible => '', // unreachable — handled above
    };

    // Fixed warm "attention" palette (the app's warn tone, not the theme
    // surface): a light amber card that stays high-contrast on the dark theme,
    // where a surface tint washed out and the hint was easy to miss.
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
        decoration: BoxDecoration(
          color: AppColors.warnSoft,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.warn.withValues(alpha: 0.45)),
        ),
        child: Row(
          children: [
            const Icon(Icons.volume_off_rounded, size: 20, color: AppColors.warn),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.ink,
                  fontSize: 13,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 4),
            TextButton(
              onPressed: () async {
                await ref.read(reminderAudioServiceProvider).showVolumeUi();
              },
              style: TextButton.styleFrom(
                foregroundColor: AppColors.warn,
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
                visualDensity: VisualDensity.compact,
              ),
              child: Text(t.reminder_sound.enable),
            ),
          ],
        ),
      ),
    );
  }
}
