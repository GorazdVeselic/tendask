import 'package:url_launcher/url_launcher.dart';

import 'config.dart';

/// Opens the public privacy policy in an external browser. Best-effort: a
/// launch failure (e.g. no browser) is swallowed rather than thrown into the
/// UI — the policy is also reachable from the Play listing, so this is never
/// a critical path.
Future<void> openPrivacyPolicy() async {
  try {
    await launchUrl(
      Uri.parse(kPrivacyPolicyUrl),
      mode: LaunchMode.externalApplication,
    );
  } catch (_) {
    // Ignore — opening the policy is a convenience, not essential.
  }
}
