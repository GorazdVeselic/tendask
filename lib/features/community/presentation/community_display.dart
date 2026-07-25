import '../../../i18n/translations.g.dart';
import '../data/community_models.dart';
import '../data/community_stats.dart';

/// Scope wording for a resolved bucket (§7.4: the UI must always say how wide
/// the comparison is). The three H3 levels read the same to the user — "in your
/// area" — because the cell size is not something a gardener reasons about.
String communityScopeLabel(Translations t, CommunityResolution resolution) =>
    switch (resolution) {
      CommunityResolution.r7 ||
      CommunityResolution.r6 ||
      CommunityResolution.r5 => t.community.scope.area,
      CommunityResolution.climate => t.community.scope.climate,
    };

/// Qualitative feed wording (§7.1) — never a percentage over the 7-day window.
String communityIntensityLabel(Translations t, CommunityIntensity intensity) =>
    switch (intensity) {
      CommunityIntensity.often => t.community.intensity.often,
      CommunityIntensity.some => t.community.intensity.some,
      CommunityIntensity.rare => t.community.intensity.rare,
    };

/// The same qualitative scale as a full sentence, for the detail screen's
/// "this week" row.
String communityThisWeekLabel(Translations t, CommunityIntensity intensity) =>
    switch (intensity) {
      CommunityIntensity.often => t.community.detail.this_week.often,
      CommunityIntensity.some => t.community.detail.this_week.some,
      CommunityIntensity.rare => t.community.detail.this_week.rare,
    };

/// Where the reader stands against the curve, as one sentence: a number when the
/// sample carries one, the descriptive band when it does not (§7.7), and the
/// "not started" line when [myWeek] is null. Shared by the detail card and the
/// task-detail entry card so both phrase the same finding identically.
String communityTimingHeadline(
  Translations t,
  SeasonCurve curve,
  int? myWeek,
) {
  if (myWeek == null) return t.community.detail.not_started;
  final percent = seasonPercent(curve, myWeek);
  if (percent != null) return t.community.detail.you_percent(percent: percent);
  return communityTimingLabel(t, timingBand(seasonCdfForWeek(curve, myWeek)));
}

/// Where the reader stands, worded without a number — the honest form below
/// [kCommunityReliabilityMin] (§7.7).
String communityTimingLabel(Translations t, CommunityTiming timing) =>
    switch (timing) {
      CommunityTiming.early => t.community.detail.you_band.early,
      CommunityTiming.typical => t.community.detail.you_band.typical,
      CommunityTiming.late => t.community.detail.you_band.late,
    };
