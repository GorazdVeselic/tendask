import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/app_colors.dart';
import '../../../i18n/translations.g.dart';

/// Screen 20 — a static illustration of how the three notification types look on
/// the lock screen. Purely educational: only task reminders are live today;
/// weather and community hints are server-side (FCM) and deferred.
class NotificationPreviewScreen extends StatelessWidget {
  const NotificationPreviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final p = t.notif_preview;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: context.pop),
        title: Text(p.title),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.green900, AppColors.green, AppColors.green900],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 32, 16, 20),
            children: [
              const _LockClock(),
              const SizedBox(height: 28),
              _NotifCard(
                icon: '⏰',
                time: p.rem_now,
                title: p.rem_title,
                body: p.rem_body,
                tag: p.rem_tag,
                tagBg: AppColors.soft,
                tagFg: AppColors.green,
              ),
              _NotifCard(
                icon: '🌤️',
                time: '8:02',
                title: p.wx_title,
                body: p.wx_body,
                tag: p.wx_tag,
                tagBg: AppColors.infoSoft,
                tagFg: AppColors.info,
              ),
              _NotifCard(
                icon: '🌍',
                time: p.com_yesterday,
                title: p.com_title,
                body: p.com_body,
                tag: p.com_tag,
                tagBg: AppColors.warnSoft,
                tagFg: AppColors.warn,
              ),
              const SizedBox(height: 16),
              Text(
                p.footer,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    height: 1.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockClock extends StatelessWidget {
  const _LockClock();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('9:41',
            style: TextStyle(
                color: Colors.white,
                fontSize: 64,
                fontWeight: FontWeight.w300,
                height: 1)),
        const SizedBox(height: 6),
        Text(context.t.notif_preview.date,
            style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9), fontSize: 15)),
      ],
    );
  }
}

class _NotifCard extends StatelessWidget {
  const _NotifCard({
    required this.icon,
    required this.time,
    required this.title,
    required this.body,
    required this.tag,
    required this.tagBg,
    required this.tagFg,
  });

  final String icon;
  final String time;
  final String title;
  final String body;
  final String tag;
  final Color tagBg;
  final Color tagFg;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: AppColors.green,
                borderRadius: BorderRadius.circular(9)),
            child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 18))),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tendask',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                            letterSpacing: 0.4)),
                    Text(time,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(title,
                    style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink)),
                const SizedBox(height: 2),
                Text(body,
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.ink, height: 1.4)),
                const SizedBox(height: 7),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                      color: tagBg, borderRadius: BorderRadius.circular(999)),
                  child: Text(tag,
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: tagFg)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
