import '../../../i18n/translations.g.dart';
import '../data/community_models.dart';

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
