// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moon_month_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Cells of the month grid for [month] (a `DateTime(year, month)` key): every
/// day of the month plus six leading days of the previous month, keyed by
/// local midnight. Six covers both consumers exactly — the grid's leading fill
/// and the week agenda of a week ending on the 1st. Memoized per (month,
/// system): one grid costs ~16 ms (measurement T1.11), too much to recompute
/// on every rebuild.

@ProviderFor(moonMonth)
final moonMonthProvider = MoonMonthFamily._();

/// Cells of the month grid for [month] (a `DateTime(year, month)` key): every
/// day of the month plus six leading days of the previous month, keyed by
/// local midnight. Six covers both consumers exactly — the grid's leading fill
/// and the week agenda of a week ending on the 1st. Memoized per (month,
/// system): one grid costs ~16 ms (measurement T1.11), too much to recompute
/// on every rebuild.

final class MoonMonthProvider
    extends
        $FunctionalProvider<
          Map<DateTime, MoonMonthDay>,
          Map<DateTime, MoonMonthDay>,
          Map<DateTime, MoonMonthDay>
        >
    with $Provider<Map<DateTime, MoonMonthDay>> {
  /// Cells of the month grid for [month] (a `DateTime(year, month)` key): every
  /// day of the month plus six leading days of the previous month, keyed by
  /// local midnight. Six covers both consumers exactly — the grid's leading fill
  /// and the week agenda of a week ending on the 1st. Memoized per (month,
  /// system): one grid costs ~16 ms (measurement T1.11), too much to recompute
  /// on every rebuild.
  MoonMonthProvider._({
    required MoonMonthFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'moonMonthProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$moonMonthHash();

  @override
  String toString() {
    return r'moonMonthProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<Map<DateTime, MoonMonthDay>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  Map<DateTime, MoonMonthDay> create(Ref ref) {
    final argument = this.argument as DateTime;
    return moonMonth(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Map<DateTime, MoonMonthDay> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Map<DateTime, MoonMonthDay>>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is MoonMonthProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$moonMonthHash() => r'c20805d547c92a17c789ac885167f304864867f6';

/// Cells of the month grid for [month] (a `DateTime(year, month)` key): every
/// day of the month plus six leading days of the previous month, keyed by
/// local midnight. Six covers both consumers exactly — the grid's leading fill
/// and the week agenda of a week ending on the 1st. Memoized per (month,
/// system): one grid costs ~16 ms (measurement T1.11), too much to recompute
/// on every rebuild.

final class MoonMonthFamily extends $Family
    with $FunctionalFamilyOverride<Map<DateTime, MoonMonthDay>, DateTime> {
  MoonMonthFamily._()
    : super(
        retry: null,
        name: r'moonMonthProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Cells of the month grid for [month] (a `DateTime(year, month)` key): every
  /// day of the month plus six leading days of the previous month, keyed by
  /// local midnight. Six covers both consumers exactly — the grid's leading fill
  /// and the week agenda of a week ending on the 1st. Memoized per (month,
  /// system): one grid costs ~16 ms (measurement T1.11), too much to recompute
  /// on every rebuild.

  MoonMonthProvider call(DateTime month) =>
      MoonMonthProvider._(argument: month, from: this);

  @override
  String toString() => r'moonMonthProvider';
}
