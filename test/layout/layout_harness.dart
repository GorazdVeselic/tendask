import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tendask/app/theme/app_theme.dart';
import 'package:tendask/app/theme/theme_palette.dart';
import 'package:tendask/i18n/translations.g.dart';

/// Viewports in logical pixels. 360 is what a Galaxy S23 reports at its default
/// display size; 320 is the same phone with "larger display" turned up (and the
/// narrowest Android phone still in the field); 411 is a large phone.
const kViewports = <String, Size>{
  '320x568': Size(320, 568),
  '360x640': Size(360, 640),
  '411x731': Size(411, 731),
};

/// 1.0 = system default. 1.3 is roughly one notch up on Android's font-size
/// slider, and the ceiling we intend to clamp the app to.
const kTextScales = <double>[1.0, 1.3];

/// German is the longest language and breaks first; Slovenian is the target
/// market's and the wireframes' language.
const kLocales = <AppLocale>[AppLocale.sl, AppLocale.en, AppLocale.de];

/// Widget tests render with a fixed-width test font whose glyphs are far wider
/// than the shipped one, so every width measurement would be inflated and the
/// matrix would report breakage that never happens on a device. Loading the
/// bundled font makes these measurements match the real app.
///
/// Read the file synchronously: inside a `testWidgets` body the fake-async zone
/// never pumps real `dart:io` futures, so `File.readAsBytes()` would hang.
Future<void> loadAppFont() async {
  final bytes = File(
    'assets/fonts/PlusJakartaSans-VariableFont_wght.ttf',
  ).readAsBytesSync();
  final loader = FontLoader('PlusJakartaSans')
    ..addFont(Future.value(ByteData.view(bytes.buffer)));
  await loader.load();
}

/// An inert router, just enough for `GoRouter.of(context)` to resolve. Created
/// once and shared: the matrix never navigates, so it holds no per-test state.
final _inertRouter = GoRouter(
  routes: [GoRoute(path: '/', builder: (_, _) => const SizedBox.shrink())],
);

/// Pumps [screen] as the app would render it: real theme, real translations, at
/// a given viewport and system font scale.
Future<void> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  required Size size,
  required double textScale,
  required AppLocale locale,
  List<Override> overrides = const [],
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  // The system font-size slider: this is what reaches the MediaQuery that
  // MaterialApp builds from the view. An outer MediaQuery would be overwritten.
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

  await LocaleSettings.setLocale(locale);
  addTearDown(() => LocaleSettings.setLocale(AppLocale.sl));

  await tester.pumpWidget(
    TranslationProvider(
      child: ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          theme: AppTheme.light(greenPalette),
          locale: locale.flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // The entry-step bodies are designed to live inside the wizard's
          // Scaffold, so they need a Material ancestor for their InkWells. Full
          // screens bring their own Scaffold; an outer bare one is harmless.
          //
          // Screens that read GoRouter.of(context) at build time (task detail)
          // need a router in scope. This one is inert — the matrix never taps a
          // navigation control, so pop()/push() are never reached.
          home: InheritedGoRouter(
            goRouter: _inertRouter,
            child: Scaffold(body: screen),
          ),
        ),
      ),
    ),
  );
  // Explicit pumps, not pumpAndSettle: screens driven by a PageView or a drift
  // stream never settle.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

/// Strings that already break mid-word today, per matrix screen — the backlog
/// the word-break rule uncovered the day it was written (docs/prelomi-besed.md).
///
/// Listed so the rule can stay ON while the backlog is worked off: a NEW break
/// fails immediately, these do not. Delete an entry when its screen is fixed;
/// never add one without filing it in that document. Chunks only — never
/// pixel widths, which move with every font or padding change.
const kAcceptedWordBreaks = <String, Set<String>>{
  'appearance': {'Dunkel', 'Sistemsko', 'Svetlo', 'System', 'Temno'},
  'areas': {'Bereiche', 'Območja', 'Sredstva', 'Supplies'},
  'entry/review': {
    'ERINNERUNG',
    'PONAVLJANJE',
    'WIEDERHOLUNG',
    'Wöchentlich',
    'Zelenjavni',
  },
  'entry/when': {
    'Custom',
    'Dnevno',
    'Eigene',
    'Tedensko',
    'Tomorrow',
    'Täglich',
    'Weekly',
    'Wöchentlich',
  },
  'entry/when (custom recurrence)': {
    'Custom',
    'Dnevno',
    'Eigene',
    'Tedensko',
    'Tomorrow',
    'Täglich',
    'Weekly',
    'Wöchentlich',
  },
  // Not shipped: the fifth tab is flag-dark, so this one is a precondition for
  // turning kCommunityEnabled on, not a backlog item (docs/deploy-runbook.md).
  'nav (five tabs)': {
    'Aufgaben',
    'Opravila',
    'Startseite',
    'Tagebuch',
    'Umgebung',
  },
  'note-form': {'Yesterday'},
  'notifications': {'Erinnerungen', 'dogodku'},
  'settings': {'Benachrichtigungen', 'Slovenščina'},
  // Not shipped: the suggestion screens are flag-dark. Surfaced only once the
  // matrix stopped feeding them a message_key that does not exist (N26).
  'suggestions/history': {'Auspflanzen'},
  'task-detail': {'Wiederholung'},
  'tasks': {'Gießen', 'Watering', 'Zalivanje', 'Zelenjavni'},
};

/// Everything the matrix considers a layout break, in one place.
///
/// Two distinct failures, because the app has two distinct ways of breaking:
///  * an overflow error (RenderFlex and friends) — loud, throws, and is what
///    Sentry sees;
///  * silently clipped text — a paragraph forced onto fewer lines than its
///    content needs, so glyphs paint outside the box and get cut. It reports no
///    error at all. This is what a squeezed SegmentedButton does, and it is
///    invisible to tester.takeException().
///
/// Crucially, text that can wrap freely (softWrap with no maxLines) NEVER
/// clips: Flutter breaks even an over-long, unbreakable word across lines to
/// fit. Only line-limited text (finite maxLines, or softWrap off) can clip, so
/// getMinIntrinsicWidth alone is not a clip signal — it over-reports the width
/// of freely-wrapping titles that in fact wrap to two lines and look fine.
///
/// That word-breaking is the third failure: nothing is clipped, nothing throws,
/// and the result reads "Startsei / te". It is checked FIRST, for every
/// paragraph, because it is the one break freely-wrapping text can still have.
///
/// Text that opts into ellipsis or fade is *designed* to shrink (see
/// task_action_bar), so it is never a break.
List<String> layoutBreaks(
  WidgetTester tester, {
  Set<String> acceptedWordBreaks = const {},
}) {
  final breaks = <String>[];

  // Drain every exception, not just the first: one pump can throw several
  // overflow errors, and any left untaken fails the test on its own (as an
  // opaque "Multiple exceptions" instead of a readable break list). A real
  // overflow is a break; any other exception is a harness gap worth naming
  // distinctly, not silently folding into the overflow bucket.
  for (var e = tester.takeException(); e != null; e = tester.takeException()) {
    // Several exceptions in one frame arrive aggregated as "Multiple exceptions
    // (N)", whose first line hides the overflow, so match against the whole
    // string, not just the heading.
    final full = e.toString();
    final first = full.split('\n').first;
    breaks.add(full.contains('overflowed') ? 'overflow: $first' : 'error: $first');
  }

  for (final paragraph in tester.allRenderObjects.whereType<RenderParagraph>()) {
    if (paragraph.overflow == TextOverflow.ellipsis ||
        paragraph.overflow == TextOverflow.fade) {
      continue;
    }
    if (paragraph.size.isEmpty || !paragraph.hasSize) continue;

    // A box narrower than the longest unbreakable chunk forces Flutter to break
    // INSIDE a word ("Startsei / te"). Nothing is clipped and nothing throws,
    // so neither check below sees it — but it is unreadable, and it is how a
    // bottom-nav label or a chip breaks when a fifth tab or a long German word
    // arrives.
    final chunk = _widestChunk(paragraph);
    // An accepted break must not hide a clip in the same paragraph, so only a
    // reported one ends the checks below.
    if (chunk != null &&
        chunk.width > paragraph.size.width + 0.5 &&
        !acceptedWordBreaks.contains(chunk.text)) {
      breaks.add(
        'word-broken text "${paragraph.text.toPlainText().replaceAll('\n', ' ')}": '
        '"${chunk.text}" needs ${chunk.width.round()}px, box is '
        '${paragraph.size.width.round()}px',
      );
      continue;
    }

    // Free-wrapping text always fits — skip it, or every long title trips a
    // false positive.
    final lineLimited = !paragraph.softWrap || paragraph.maxLines != null;
    if (!lineLimited) continue;

    // Vertical clip: the content needed more lines than it was allowed.
    if (paragraph.didExceedMaxLines) {
      final text = paragraph.text.toPlainText().replaceAll('\n', ' ');
      breaks.add('clipped text "$text" exceeds ${paragraph.maxLines} line(s)');
      continue;
    }

    // Horizontal clip: text pinned to a single line (maxLines 1 or no wrap)
    // whose full width spills past the box. maxIntrinsic is the single-line
    // width, which is exactly what must fit here.
    final singleLine = paragraph.maxLines == 1 || !paragraph.softWrap;
    if (!singleLine) continue;
    final needed = paragraph.getMaxIntrinsicWidth(double.infinity);
    if (needed > paragraph.size.width + 0.5) {
      final text = paragraph.text.toPlainText().replaceAll('\n', ' ');
      breaks.add(
        'clipped text "$text" needs ${needed.round()}px, box is '
        '${paragraph.size.width.round()}px',
      );
    }
  }
  return breaks;
}

/// Runs one screen across the full viewport × locale × text-scale matrix.
///
/// [build] is called per combination (widgets and controllers must not be
/// shared across pumps). [after] can drive the screen into a second state —
/// switching a tab, opening a sheet — before it is measured.
void layoutMatrix(
  String screen, {
  required Widget Function() build,
  List<Override> Function()? overrides,
  Future<void> Function(WidgetTester tester)? after,
}) {
  for (final viewport in kViewports.entries) {
    for (final locale in kLocales) {
      for (final scale in kTextScales) {
        testWidgets(
          '$screen @ ${viewport.key} · ${locale.languageCode} · text×$scale',
          (tester) async {
            await loadAppFont();
            await pumpScreen(
              tester,
              build(),
              size: viewport.value,
              textScale: scale,
              locale: locale,
              overrides: overrides?.call() ?? const [],
            );
            if (after != null) await after(tester);

            expect(
              layoutBreaks(
                tester,
                acceptedWordBreaks: kAcceptedWordBreaks[screen] ?? const {},
              ),
              isEmpty,
            );
          },
        );
      }
    }
  }
}

/// The widest chunk of [paragraph] that Flutter cannot break, and its width.
///
/// `getMinIntrinsicWidth` is not usable here: it reports the longest
/// whitespace-delimited run, treating "Aufgaben-Erinnerungen" as unbreakable
/// even though Flutter happily breaks after the hyphen. Measuring the chunks
/// with the paragraph's own style and scaler is what tells a clean wrap from a
/// word torn in half.
({String text, double width})? _widestChunk(RenderParagraph paragraph) {
  final span = paragraph.text;
  // Per-chunk styling would need per-run measurement; the app's wrapping text
  // is single-styled, and a mixed span is left to the checks below.
  if (span is! TextSpan || span.children != null) return null;
  final plain = span.toPlainText();
  if (plain.trim().isEmpty) return null;

  ({String text, double width})? widest;
  for (final word in plain.split(RegExp(r'\s+'))) {
    // Keep the hyphen on the chunk before it: that is the line Flutter draws.
    final parts = word.split('-');
    for (var i = 0; i < parts.length; i++) {
      final chunk = i == parts.length - 1 ? parts[i] : '${parts[i]}-';
      if (chunk.isEmpty) continue;
      final painter = TextPainter(
        text: TextSpan(text: chunk, style: span.style),
        textDirection: paragraph.textDirection,
        textScaler: paragraph.textScaler,
        locale: paragraph.locale,
      )..layout();
      if (widest == null || painter.width > widest.width) {
        widest = (text: chunk, width: painter.width);
      }
    }
  }
  return widest;
}
