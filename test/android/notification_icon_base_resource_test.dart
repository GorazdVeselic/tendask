@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Regression guard for the `invalid_icon` saga (vc1–vc6): the notification
/// status-bar icon `ic_stat_notify` is resolved at runtime by name
/// (`getIdentifier(name, "drawable", pkg)`), so it MUST be a single
/// density-INDEPENDENT vector in base `res/drawable/`. A density-qualified
/// variant (`drawable-hdpi/…`) lands in a density config split whose
/// `resources.arsc` entry is absent from the base on SplitCompat-less installs
/// (Play pre-launch / Test Lab) → `getIdentifier` returns 0 → the whole reminder
/// subsystem dies in production, invisible to local universal-APK testing.
///
/// This test runs on CI and fails the build the moment that pattern is
/// reintroduced — catching the regression before it ships, where the previous
/// four fixes only chased it after Play surfaced it via Sentry.
void main() {
  const resDir = 'android/app/src/main/res';
  const iconName = 'ic_stat_notify';

  test('$iconName exists as a base (unqualified) drawable', () {
    final base = File('$resDir/drawable/$iconName.xml');
    expect(
      base.existsSync(),
      isTrue,
      reason:
          'Missing $resDir/drawable/$iconName.xml — the icon must live in the '
          'unqualified base drawable folder so its entry lands in the base '
          'resources.arsc on every install.',
    );
  });

  test('$iconName is a density-independent VectorDrawable, not a bitmap', () {
    final base = File('$resDir/drawable/$iconName.xml');
    final firstTag = base.readAsStringSync();
    expect(
      firstTag.contains('<vector'),
      isTrue,
      reason:
          '$iconName.xml must be a <vector> (one entry in base, no density '
          'variants). A <bitmap>/PNG reintroduces the density-split bug.',
    );
  });

  test('no density-qualified or non-base variant of $iconName exists', () {
    final offenders = <String>[];
    for (final entity in Directory(resDir).listSync()) {
      if (entity is! Directory) continue;
      final folder = entity.path.split(Platform.pathSeparator).last;
      // The single allowed location is the unqualified `drawable/` folder.
      if (folder == 'drawable') continue;
      if (!folder.startsWith('drawable') && !folder.startsWith('mipmap')) {
        continue;
      }
      for (final file in entity.listSync().whereType<File>()) {
        final name = file.path.split(Platform.pathSeparator).last;
        if (name == '$iconName.xml' || name == '$iconName.png') {
          offenders.add('$folder/$name');
        }
      }
    }
    expect(
      offenders,
      isEmpty,
      reason:
          'Found qualified $iconName variant(s) outside base drawable/: '
          '$offenders. These split into a density config APK and break '
          'getIdentifier on SplitCompat-less installs.',
    );
  });

  test('keep.xml protects $iconName from R8 resource shrinking', () {
    final keep = File('$resDir/raw/keep.xml');
    expect(keep.existsSync(), isTrue, reason: 'Missing $resDir/raw/keep.xml.');
    expect(
      keep.readAsStringSync().contains('@drawable/$iconName'),
      isTrue,
      reason:
          'keep.xml must list @drawable/$iconName — it is referenced only by a '
          'runtime string, so R8 would otherwise strip it from release builds.',
    );
  });
}
