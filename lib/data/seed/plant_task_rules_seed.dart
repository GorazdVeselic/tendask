/// Curated agronomy rules seed — source: docs/m11/01-agronomska-pravila.md.
/// Every source_ref was verified against the live page in M11.4 (no rule ships
/// without a confirmed citation). Rule ids are stable slugs, add-only — same
/// contract as catalog ids. Cloud mirror: tool/gen_rules_sql.dart.
library;

class PlantTaskRuleSeed {
  const PlantTaskRuleSeed({
    required this.id,
    required this.scope,
    required this.refId,
    required this.taskTypeId,
    required this.timingAnchor,
    required this.window,
    this.cadence,
    this.frostGate = false,
    this.weatherGuard,
    required this.sourceRef,
    required this.confidence,
    required this.messageKey,
  });

  final String id;
  final String scope; // 'plant' | 'category'
  final String refId; // plant.id or plant category slug
  final String taskTypeId;
  // 'month_window' | 'frost_offset' | 'growth_stage' | 'cadence_only'
  final String timingAnchor;
  final String window; // JSON, shape per anchor — docs/m11/01 §0
  final String? cadence; // human-readable; machine logic reads only window
  final bool frostGate;
  final String? weatherGuard; // comma-joined codes (docs/m11/02 §G)
  final String sourceRef;
  final String confidence; // 'high' | 'medium'
  final String messageKey; // i18n key under suggestions.*
}

abstract final class PlantTaskRulesSeed {
  static const rules = <PlantTaskRuleSeed>[
    // ── A.1 lawn ─────────────────────────────────────────────────────────────
    PlantTaskRuleSeed(
      id: 'lawn.mow',
      scope: 'category',
      refId: 'lawn',
      taskTypeId: 'mow',
      timingAnchor: 'cadence_only',
      window:
          '{"min_days_since_last": 5, "max_days_since_last": 10, '
          '"season_start_week": 12, "season_end_week": 46}',
      cadence: 'weekly in season',
      weatherGuard: 'dry12h',
      sourceRef: 'RHS - Lawns: mowing (rhs.org.uk/lawns/mowing)',
      confidence: 'high',
      messageKey: 'suggestions.lawn.mow_due',
    ),
    PlantTaskRuleSeed(
      id: 'lawn.fertilize.spring',
      scope: 'category',
      refId: 'lawn',
      taskTypeId: 'fertilize',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 13, "end_week": 18, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence: '1x/year (spring feed, N-rich)',
      weatherGuard: 'soil_gt_8,no_heavy_rain_24h',
      sourceRef:
          'RHS - Lawn care in spring and summer '
          '(rhs.org.uk/lawns/spring-summer-care)',
      confidence: 'high',
      messageKey: 'suggestions.lawn.fertilize_spring',
    ),
    PlantTaskRuleSeed(
      id: 'lawn.fertilize.autumn',
      scope: 'category',
      refId: 'lawn',
      taskTypeId: 'fertilize',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 36, "end_week": 41, "climate_bucket_filter": null, '
          '"regionalize": "autumn"}',
      cadence: '1x/year (autumn feed, K-rich, low N)',
      weatherGuard: 'dry12h',
      sourceRef: 'RHS - Lawn care in autumn (rhs.org.uk/lawns/autumn-care)',
      confidence: 'high',
      messageKey: 'suggestions.lawn.fertilize_autumn',
    ),
    PlantTaskRuleSeed(
      id: 'lawn.scarify.autumn',
      scope: 'category',
      refId: 'lawn',
      taskTypeId: 'scarify',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 36, "end_week": 39, "climate_bucket_filter": null, '
          '"regionalize": "autumn"}',
      cadence: '1x/year (primary window)',
      weatherGuard: 'dry12h',
      sourceRef: 'RHS - Lawn care in autumn (rhs.org.uk/lawns/autumn-care)',
      confidence: 'high',
      messageKey: 'suggestions.lawn.scarify_autumn',
    ),
    PlantTaskRuleSeed(
      id: 'lawn.scarify.spring',
      scope: 'category',
      refId: 'lawn',
      taskTypeId: 'scarify',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 14, "end_week": 17, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence: 'optional light pass (only if not done in autumn)',
      weatherGuard: 'dry12h',
      sourceRef:
          'RHS - Jobs for April: lawns (rhs.org.uk/advice/in-month/april/lawns)',
      confidence: 'medium',
      messageKey: 'suggestions.lawn.scarify_spring',
    ),
    PlantTaskRuleSeed(
      id: 'lawn.aerate',
      scope: 'category',
      refId: 'lawn',
      taskTypeId: 'aerate',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 36, "end_week": 42, "climate_bucket_filter": null, '
          '"regionalize": "autumn"}',
      cadence: '1x/year (compacted lawns 2x)',
      weatherGuard: 'soil_moist',
      sourceRef: 'RHS - Lawn care in autumn (rhs.org.uk/lawns/autumn-care)',
      confidence: 'high',
      messageKey: 'suggestions.lawn.aerate',
    ),
    PlantTaskRuleSeed(
      id: 'lawn.overseed.spring',
      scope: 'category',
      refId: 'lawn',
      taskTypeId: 'overseed',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 15, "end_week": 19, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence: 'as needed (bare/thin patches)',
      weatherGuard: 'soil_gt_10',
      sourceRef:
          'RHS - Repairing lawns: reseeding and returfing '
          '(rhs.org.uk/lawns/repairing)',
      confidence: 'medium',
      messageKey: 'suggestions.lawn.overseed_spring',
    ),
    PlantTaskRuleSeed(
      id: 'lawn.overseed.autumn',
      scope: 'category',
      refId: 'lawn',
      taskTypeId: 'overseed',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 34, "end_week": 38, "climate_bucket_filter": null, '
          '"regionalize": "autumn"}',
      cadence: '1x/year (primary window - warm soil + autumn moisture)',
      weatherGuard: 'soil_gt_10',
      sourceRef: 'RHS - Lawn care in autumn (rhs.org.uk/lawns/autumn-care)',
      confidence: 'high',
      messageKey: 'suggestions.lawn.overseed_autumn',
    ),
    PlantTaskRuleSeed(
      id: 'lawn.topdress',
      scope: 'category',
      refId: 'lawn',
      taskTypeId: 'topdress',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 36, "end_week": 40, "climate_bucket_filter": null, '
          '"regionalize": "autumn"}',
      cadence: '1x/year (after scarifying/aeration)',
      weatherGuard: 'dry12h',
      sourceRef: 'RHS - Lawn care in autumn (rhs.org.uk/lawns/autumn-care)',
      confidence: 'high',
      messageKey: 'suggestions.lawn.topdress',
    ),
    PlantTaskRuleSeed(
      id: 'lawn.roll',
      scope: 'category',
      refId: 'lawn',
      taskTypeId: 'roll',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 12, "end_week": 15, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence: '1x/year (spring, after frost heave)',
      weatherGuard: 'soil_moist',
      sourceRef:
          'Deutsche Rasengesellschaft - Die Fruehjahrskur fuer jeden '
          'Gebrauchs- und Strapazierrasen '
          '(rasengesellschaft.de/rasenthema-detailansicht/februar-2025-2.html)',
      confidence: 'medium',
      messageKey: 'suggestions.lawn.roll',
    ),
    PlantTaskRuleSeed(
      id: 'lawn.lime',
      scope: 'category',
      refId: 'lawn',
      taskTypeId: 'lime',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 44, "end_week": 48, "climate_bucket_filter": null, '
          '"regionalize": "autumn"}',
      cadence:
          'every 2-3 years, only if soil pH is low (message says "check pH '
          'first")',
      weatherGuard: 'dry12h',
      sourceRef:
          'RHS - Lime and liming '
          '(rhs.org.uk/soil-composts-mulches/lime-liming); '
          'Landwirtschaftskammer NRW - Duengeempfehlungen fuer den Hausgarten '
          '(landwirtschaftskammer.de/verbraucher/garten/gartentipp040.htm)',
      confidence: 'medium',
      messageKey: 'suggestions.lawn.lime',
    ),
    PlantTaskRuleSeed(
      id: 'lawn.lawn_weed_moss.moss',
      scope: 'category',
      refId: 'lawn',
      taskTypeId: 'lawn_weed_moss',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 12, "end_week": 16, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence: '1x/year (moss control before scarifying)',
      weatherGuard: 'no_rain_forecast_24h',
      sourceRef:
          'RHS - Lawn care in spring and summer '
          '(rhs.org.uk/lawns/spring-summer-care); RHS - Moss on lawns '
          '(rhs.org.uk/lawns/moss-on-lawns)',
      confidence: 'high',
      messageKey: 'suggestions.lawn.moss_control',
    ),
    PlantTaskRuleSeed(
      id: 'lawn.lawn_weed_moss.weed',
      scope: 'category',
      refId: 'lawn',
      taskTypeId: 'lawn_weed_moss',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 18, "end_week": 24, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence: '1x/year (weeds in active growth)',
      weatherGuard: 'dry24h,no_rain_forecast_24h,wind_lt_15',
      sourceRef:
          'RHS - Weeds in lawns: control and care '
          '(rhs.org.uk/lawns/weed-control)',
      confidence: 'medium',
      messageKey: 'suggestions.lawn.weed_control',
    ),
    PlantTaskRuleSeed(
      id: 'lawn.water',
      scope: 'category',
      refId: 'lawn',
      taskTypeId: 'water',
      timingAnchor: 'cadence_only',
      window:
          '{"min_days_since_last": 5, "max_days_since_last": 10, '
          '"season_start_week": 22, "season_end_week": 35}',
      cadence:
          'only in prolonged summer drought (established lawns usually '
          'recover unwatered)',
      weatherGuard: 'drought7d,no_rain_forecast_48h',
      sourceRef:
          'RHS - Lawn care in spring and summer '
          '(rhs.org.uk/lawns/spring-summer-care)',
      confidence: 'medium',
      messageKey: 'suggestions.lawn.water_drought',
    ),
    // ── A.2 fruit_tree ───────────────────────────────────────────────────────
    PlantTaskRuleSeed(
      id: 'fruit_tree.prune.winter',
      scope: 'category',
      refId: 'fruit_tree',
      taskTypeId: 'prune',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 2, "end_week": 11, "climate_bucket_filter": null, '
          '"regionalize": "none"}',
      cadence:
          '1x/year (dormant; pome fruit default - stone fruit overridden per '
          'species)',
      weatherGuard: 'dry12h,temp_gt_0',
      sourceRef:
          'RHS - Apples and pears: winter pruning '
          '(rhs.org.uk/fruit/apples/winter-pruning); KGZS Zavod Ptuj - Rez '
          'sadnega drevja '
          '(kgz-ptuj.si/novice/ArtMID/887/ArticleID/1058/Rez-sadnega-drevja)',
      confidence: 'high',
      messageKey: 'suggestions.fruit_tree.prune_winter',
    ),
    PlantTaskRuleSeed(
      id: 'fruit_tree.graft.spring',
      scope: 'category',
      refId: 'fruit_tree',
      taskTypeId: 'graft',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 10, "end_week": 16, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence: 'seasonal (whip/cleft grafting at bud break)',
      weatherGuard: 'dry12h,temp_gt_0',
      sourceRef:
          'RHS - Grafting ornamental plants and fruit trees '
          '(rhs.org.uk/fruit/fruit-trees/grafting-ornamental); KGZS - '
          'Spomladansko cepljenje sadnih dreves za lub '
          '(kgzs.si/kgzs/kmetijsko-svetovanje/e-knjiznica/e-knjiznica-zapis/'
          'spomladansko-cepljenje-sadnih-dreves-za-lub)',
      confidence: 'medium',
      messageKey: 'suggestions.fruit_tree.graft_spring',
    ),
    PlantTaskRuleSeed(
      id: 'fruit_tree.graft.summer_budding',
      scope: 'category',
      refId: 'fruit_tree',
      taskTypeId: 'graft',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 30, "end_week": 34, "climate_bucket_filter": null, '
          '"regionalize": "none"}',
      cadence: 'seasonal (T-/chip-budding)',
      weatherGuard: 'dry12h',
      sourceRef:
          'RHS - Chip budding (rhs.org.uk/propagation/chip-budding); '
          'RHS - T-budding (rhs.org.uk/propagation/t-budding); KGZS - Poletno '
          'cepljenje sadnih dreves, T-okulacija '
          '(kgzs.si/kgzs/kmetijsko-svetovanje/e-knjiznica/e-knjiznica-zapis/'
          'poletno-cepljenje-sadnih-dreves-t-okulacija)',
      confidence: 'medium',
      messageKey: 'suggestions.fruit_tree.graft_budding',
    ),
    PlantTaskRuleSeed(
      id: 'fruit_tree.thin_fruit',
      scope: 'category',
      refId: 'fruit_tree',
      taskTypeId: 'thin_fruit',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 23, "end_week": 27, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence: '1x/season (after June drop)',
      sourceRef: 'RHS - Fruit thinning (rhs.org.uk/fruit/fruit-trees/thinning)',
      confidence: 'high',
      messageKey: 'suggestions.fruit_tree.thin_fruit',
    ),
    PlantTaskRuleSeed(
      id: 'fruit_tree.treat.dormant',
      scope: 'category',
      refId: 'fruit_tree',
      taskTypeId: 'treat',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 6, "end_week": 11, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence: '1x/year (dormant spray - oil/copper before bud break)',
      weatherGuard: 'dry24h,no_rain_forecast_24h,wind_lt_15,temp_gt_5',
      sourceRef:
          'KGZS Zavod Celje - Jesensko varstvo sadnega drevja '
          '(kmetijskizavod-celje.si/aktualno/'
          'jesensko-varstvo-sadnega-drevja-2022-11-16)',
      confidence: 'medium',
      messageKey: 'suggestions.fruit_tree.treat_dormant',
    ),
    PlantTaskRuleSeed(
      id: 'fruit_tree.fertilize',
      scope: 'category',
      refId: 'fruit_tree',
      taskTypeId: 'fertilize',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 10, "end_week": 14, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence: '1x/year (late winter / early spring, before growth)',
      sourceRef:
          'RHS - Fruit trees: feeding and mulching '
          '(rhs.org.uk/fruit/fruit-trees/feeding-and-mulching)',
      confidence: 'medium',
      messageKey: 'suggestions.fruit_tree.fertilize_spring',
    ),
    PlantTaskRuleSeed(
      id: 'fruit_tree.mulch',
      scope: 'category',
      refId: 'fruit_tree',
      taskTypeId: 'mulch',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 12, "end_week": 18, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence: '1x/year (moist spring soil)',
      weatherGuard: 'soil_moist',
      sourceRef:
          'RHS - Mulches and mulching (rhs.org.uk/soil-composts-mulches/mulch)',
      confidence: 'medium',
      messageKey: 'suggestions.fruit_tree.mulch',
    ),
    // ── A.3 berries ──────────────────────────────────────────────────────────
    PlantTaskRuleSeed(
      id: 'berries.prune.winter',
      scope: 'category',
      refId: 'berries',
      taskTypeId: 'prune',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 6, "end_week": 12, "climate_bucket_filter": null, '
          '"regionalize": "none"}',
      cadence:
          '1x/year (dormant; currant/gooseberry default - raspberry/blueberry '
          'overridden)',
      weatherGuard: 'dry12h,temp_gt_0',
      sourceRef:
          'RHS - How to grow blackcurrants '
          '(rhs.org.uk/fruit/blackcurrants/grow-your-own); RHS - Gooseberries: '
          'pruning and training '
          '(rhs.org.uk/fruit/gooseberries/gooseberry-pruning-and-training)',
      confidence: 'medium',
      messageKey: 'suggestions.berries.prune_winter',
    ),
    PlantTaskRuleSeed(
      id: 'berries.fertilize',
      scope: 'category',
      refId: 'berries',
      taskTypeId: 'fertilize',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 10, "end_week": 14, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence: '1x/year (early spring)',
      sourceRef:
          'RHS - How to grow blackcurrants '
          '(rhs.org.uk/fruit/blackcurrants/grow-your-own)',
      confidence: 'medium',
      messageKey: 'suggestions.berries.fertilize_spring',
    ),
    PlantTaskRuleSeed(
      id: 'berries.treat.dormant',
      scope: 'category',
      refId: 'berries',
      taskTypeId: 'treat',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 6, "end_week": 11, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence: '1x/year (dormant spray)',
      weatherGuard: 'dry24h,no_rain_forecast_24h,wind_lt_15',
      sourceRef:
          'KGZS Zavod Celje - Jesensko varstvo sadnega drevja '
          '(kmetijskizavod-celje.si/aktualno/'
          'jesensko-varstvo-sadnega-drevja-2022-11-16; dormant-spray practice '
          'shared with fruit trees - no berry-specific advisory page)',
      confidence: 'medium',
      messageKey: 'suggestions.berries.treat_dormant',
    ),
    PlantTaskRuleSeed(
      id: 'berries.mulch',
      scope: 'category',
      refId: 'berries',
      taskTypeId: 'mulch',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 12, "end_week": 18, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence: '1x/year',
      weatherGuard: 'soil_moist',
      sourceRef:
          'RHS - Mulches and mulching (rhs.org.uk/soil-composts-mulches/mulch)',
      confidence: 'medium',
      messageKey: 'suggestions.berries.mulch',
    ),
    // ── A.4 vegetable ────────────────────────────────────────────────────────
    PlantTaskRuleSeed(
      id: 'vegetable.start_seedlings',
      scope: 'category',
      refId: 'vegetable',
      taskTypeId: 'start_seedlings',
      timingAnchor: 'frost_offset',
      window:
          '{"anchor": "last_frost", "offset_min_days": -56, '
          '"offset_max_days": -28}',
      cadence: 'seasonal (indoor sowing of warm-season vegetables)',
      sourceRef:
          'RHS - How to sow seeds indoors '
          '(rhs.org.uk/propagation/how-to-sow-seeds-indoors)',
      confidence: 'medium',
      messageKey: 'suggestions.vegetable.start_seedlings',
    ),
    PlantTaskRuleSeed(
      id: 'vegetable.prick_out',
      scope: 'category',
      refId: 'vegetable',
      taskTypeId: 'prick_out',
      timingAnchor: 'growth_stage',
      window:
          '{"after_event": "start_seedlings", "offset_min_days": 14, '
          '"offset_max_days": 28}',
      cadence: 'per chain (at first true leaves)',
      sourceRef:
          'RHS - How to sow seeds indoors '
          '(rhs.org.uk/propagation/how-to-sow-seeds-indoors)',
      confidence: 'high',
      messageKey: 'suggestions.vegetable.prick_out',
    ),
    PlantTaskRuleSeed(
      id: 'vegetable.harden_off',
      scope: 'category',
      refId: 'vegetable',
      taskTypeId: 'harden_off',
      timingAnchor: 'frost_offset',
      window:
          '{"anchor": "last_frost", "offset_min_days": -21, '
          '"offset_max_days": 0}',
      cadence: 'once per chain (2-3 weeks before planting out)',
      weatherGuard: 'no_frost_forecast_48h',
      sourceRef:
          'RHS - Hardening off tender plants '
          '(rhs.org.uk/prevention-protection/hardening-off-tender-plants)',
      confidence: 'high',
      messageKey: 'suggestions.vegetable.harden_off',
    ),
    PlantTaskRuleSeed(
      id: 'vegetable.transplant',
      scope: 'category',
      refId: 'vegetable',
      taskTypeId: 'transplant',
      timingAnchor: 'frost_offset',
      window:
          '{"anchor": "last_frost", "offset_min_days": 0, '
          '"offset_max_days": 21}',
      cadence: 'once per chain (after last frost)',
      frostGate: true,
      weatherGuard: 'no_frost_forecast_48h,wind_lt_20',
      sourceRef:
          'RHS - When to plant out tender plants to avoid frosts '
          '(rhs.org.uk/garden-jobs/when-to-plant-out-tender-plants-avoiding-'
          'late-frosts)',
      confidence: 'high',
      messageKey: 'suggestions.vegetable.transplant',
    ),
    PlantTaskRuleSeed(
      id: 'vegetable.sow.direct',
      scope: 'category',
      refId: 'vegetable',
      taskTypeId: 'sow',
      timingAnchor: 'frost_offset',
      window:
          '{"anchor": "last_frost", "offset_min_days": -14, '
          '"offset_max_days": 35}',
      cadence: 'seasonal (hardy direct sowings earlier, tender after frost)',
      weatherGuard: 'soil_gt_8',
      sourceRef:
          'RHS - Seed-sowing techniques (rhs.org.uk/advice/beginners-guide/'
          'vegetable-basics/seed-sowing-techniques)',
      confidence: 'medium',
      messageKey: 'suggestions.vegetable.sow_direct',
    ),
    PlantTaskRuleSeed(
      id: 'vegetable.plant',
      scope: 'category',
      refId: 'vegetable',
      taskTypeId: 'plant',
      timingAnchor: 'frost_offset',
      window:
          '{"anchor": "last_frost", "offset_min_days": 0, '
          '"offset_max_days": 28}',
      cadence: 'seasonal (bought seedlings after last frost)',
      frostGate: true,
      weatherGuard: 'no_frost_forecast_48h',
      sourceRef:
          'RHS - When to plant out tender plants to avoid frosts '
          '(rhs.org.uk/garden-jobs/when-to-plant-out-tender-plants-avoiding-'
          'late-frosts)',
      confidence: 'high',
      messageKey: 'suggestions.vegetable.plant_out',
    ),
    PlantTaskRuleSeed(
      id: 'vegetable.fertilize',
      scope: 'category',
      refId: 'vegetable',
      taskTypeId: 'fertilize',
      timingAnchor: 'cadence_only',
      window:
          '{"min_days_since_last": 14, "max_days_since_last": 28, '
          '"season_start_week": 18, "season_end_week": 35}',
      cadence: 'every 2-4 weeks in season (hungry crops)',
      sourceRef:
          'RHS - How to feed plants '
          '(rhs.org.uk/garden-jobs/nutrition-feeding-plants)',
      confidence: 'medium',
      messageKey: 'suggestions.vegetable.fertilize_season',
    ),
    PlantTaskRuleSeed(
      id: 'vegetable.treat',
      scope: 'category',
      refId: 'vegetable',
      taskTypeId: 'treat',
      timingAnchor: 'cadence_only',
      window:
          '{"min_days_since_last": 14, "max_days_since_last": 9999, '
          '"season_start_week": 20, "season_end_week": 35}',
      cadence:
          'need-driven (rule only re-opens weather window after past '
          'treatments - see R1)',
      weatherGuard: 'dry24h,no_rain_forecast_24h,wind_lt_15',
      sourceRef:
          'KGZS - Pravilna raba fitofarmacevtskih sredstev '
          '(kgzs.si/novica/pravilna-raba-fitofarmacevtskih-sredstev-2024-04-07)',
      confidence: 'medium',
      messageKey: 'suggestions.vegetable.treat_window',
    ),
    // ── A.5 herbs ────────────────────────────────────────────────────────────
    PlantTaskRuleSeed(
      id: 'herbs.start_seedlings',
      scope: 'category',
      refId: 'herbs',
      taskTypeId: 'start_seedlings',
      timingAnchor: 'frost_offset',
      window:
          '{"anchor": "last_frost", "offset_min_days": -42, '
          '"offset_max_days": -21}',
      cadence: 'seasonal (indoor sowing: basil & tender herbs)',
      sourceRef:
          'RHS - Herbs: growing and harvesting (rhs.org.uk/herbs/growing)',
      confidence: 'medium',
      messageKey: 'suggestions.herbs.start_seedlings',
    ),
    PlantTaskRuleSeed(
      id: 'herbs.sow.direct',
      scope: 'category',
      refId: 'herbs',
      taskTypeId: 'sow',
      timingAnchor: 'frost_offset',
      window:
          '{"anchor": "last_frost", "offset_min_days": 0, '
          '"offset_max_days": 42}',
      cadence: 'seasonal (after last frost)',
      weatherGuard: 'soil_gt_10',
      sourceRef:
          'RHS - Herbs: growing and harvesting (rhs.org.uk/herbs/growing)',
      confidence: 'medium',
      messageKey: 'suggestions.herbs.sow_direct',
    ),
    PlantTaskRuleSeed(
      id: 'herbs.plant',
      scope: 'category',
      refId: 'herbs',
      taskTypeId: 'plant',
      timingAnchor: 'frost_offset',
      window:
          '{"anchor": "last_frost", "offset_min_days": 0, '
          '"offset_max_days": 56}',
      cadence: 'seasonal (bought herb plants after last frost)',
      frostGate: true,
      weatherGuard: 'no_frost_forecast_48h',
      sourceRef:
          'RHS - Herbs: growing and harvesting (rhs.org.uk/herbs/growing)',
      confidence: 'medium',
      messageKey: 'suggestions.herbs.plant_out',
    ),
    // ── A.6 shrub ────────────────────────────────────────────────────────────
    PlantTaskRuleSeed(
      id: 'shrub.prune.spring',
      scope: 'category',
      refId: 'shrub',
      taskTypeId: 'prune',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 9, "end_week": 14, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence:
          '1x/year (summer-flowering shrubs - RHS pruning group default; '
          'spring bloomers overridden per species when added)',
      weatherGuard: 'dry12h,temp_gt_0',
      sourceRef:
          'RHS - Pruning groups (rhs.org.uk/pruning/rhs-pruning-groups)',
      confidence: 'medium',
      messageKey: 'suggestions.shrub.prune_spring',
    ),
    PlantTaskRuleSeed(
      id: 'shrub.overwinter',
      scope: 'category',
      refId: 'shrub',
      taskTypeId: 'overwinter',
      timingAnchor: 'frost_offset',
      window:
          '{"anchor": "first_frost", "offset_min_days": -28, '
          '"offset_max_days": -7}',
      cadence: '1x/year (autumn - wrap/protect tender shrubs)',
      sourceRef:
          'RHS - Overwintering tender plants: wrapping (rhs.org.uk/'
          'prevention-protection/overwintering-tender-plants-wrapping)',
      confidence: 'high',
      messageKey: 'suggestions.shrub.overwinter',
    ),
    // ── A.7 hedge + conifer ──────────────────────────────────────────────────
    PlantTaskRuleSeed(
      id: 'hedge.prune.early_summer',
      scope: 'category',
      refId: 'hedge',
      taskTypeId: 'prune',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 22, "end_week": 26, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence:
          '1st of ~2 trims/year (after spring flush; message warns to check '
          'for nesting birds first)',
      weatherGuard: 'temp_lt_30',
      sourceRef:
          'RHS - Pruning hedges '
          '(rhs.org.uk/plants/types/hedges/pruning-hedges); DE BNatSchG par. '
          '39 - radical cuts banned 1 Mar-30 Sep, maintenance trims allowed '
          '(gesetze-im-internet.de/bnatschg_2009/__39.html)',
      confidence: 'high',
      messageKey: 'suggestions.hedge.prune_early_summer',
    ),
    PlantTaskRuleSeed(
      id: 'hedge.prune.late_summer',
      scope: 'category',
      refId: 'hedge',
      taskTypeId: 'prune',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 33, "end_week": 36, "climate_bucket_filter": null, '
          '"regionalize": "autumn"}',
      cadence: '2nd trim/year (regrowth hardens before winter)',
      weatherGuard: 'temp_lt_30',
      sourceRef:
          'RHS - Pruning hedges '
          '(rhs.org.uk/plants/types/hedges/pruning-hedges)',
      confidence: 'high',
      messageKey: 'suggestions.hedge.prune_late_summer',
    ),
    PlantTaskRuleSeed(
      id: 'conifer.prune',
      scope: 'category',
      refId: 'conifer',
      taskTypeId: 'prune',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 23, "end_week": 26, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence:
          '1x/year (message warns: never cut into old/bare wood - conifers do '
          'not regrow from it)',
      weatherGuard: 'temp_lt_30',
      sourceRef:
          'RHS - How to grow conifers '
          '(rhs.org.uk/plants/types/conifers/growing-guide)',
      confidence: 'medium',
      messageKey: 'suggestions.conifer.prune',
    ),
    // ── A.8 houseplant ───────────────────────────────────────────────────────
    PlantTaskRuleSeed(
      id: 'houseplant.repot',
      scope: 'category',
      refId: 'houseplant',
      taskTypeId: 'repot',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 9, "end_week": 18, "climate_bucket_filter": null, '
          '"regionalize": "none"}',
      cadence: 'every 1-2 years (spring, at start of growth)',
      sourceRef:
          'RHS - How to grow houseplants '
          '(rhs.org.uk/plants/types/houseplants/growing-guide)',
      confidence: 'high',
      messageKey: 'suggestions.houseplant.repot',
    ),
    PlantTaskRuleSeed(
      id: 'houseplant.overwinter',
      scope: 'category',
      refId: 'houseplant',
      taskTypeId: 'overwinter',
      timingAnchor: 'frost_offset',
      window:
          '{"anchor": "first_frost", "offset_min_days": -28, '
          '"offset_max_days": -7}',
      cadence: '1x/year (move balcony/patio pots inside before first frost)',
      sourceRef:
          'RHS - Overwintering tender plants: lifting or mulching '
          '(rhs.org.uk/prevention-protection/overwintering-tender-plants-'
          'lifting-or-mulching)',
      confidence: 'high',
      messageKey: 'suggestions.houseplant.overwinter',
    ),
    PlantTaskRuleSeed(
      id: 'houseplant.fertilize',
      scope: 'category',
      refId: 'houseplant',
      taskTypeId: 'fertilize',
      timingAnchor: 'cadence_only',
      window:
          '{"min_days_since_last": 14, "max_days_since_last": 28, '
          '"season_start_week": 12, "season_end_week": 40}',
      cadence: 'every 2-4 weeks in growing season; little to none in winter',
      sourceRef:
          'RHS - How to grow houseplants '
          '(rhs.org.uk/plants/types/houseplants/growing-guide)',
      confidence: 'medium',
      messageKey: 'suggestions.houseplant.fertilize_season',
    ),
    // ── B.1 raspberry ────────────────────────────────────────────────────────
    PlantTaskRuleSeed(
      id: 'raspberry.prune.summer_fruiting',
      scope: 'plant',
      refId: 'raspberry',
      taskTypeId: 'prune',
      timingAnchor: 'growth_stage',
      window:
          '{"after_event": "harvest", "offset_min_days": 0, '
          '"offset_max_days": 42}',
      cadence:
          '1x/year (summer-fruiting/floricane: cut fruited canes right after '
          'harvest)',
      sourceRef:
          'RHS - How to grow raspberries '
          '(rhs.org.uk/fruit/raspberries/grow-your-own)',
      confidence: 'high',
      messageKey: 'suggestions.raspberry.prune_after_harvest',
    ),
    PlantTaskRuleSeed(
      id: 'raspberry.prune.autumn_fruiting',
      scope: 'plant',
      refId: 'raspberry',
      taskTypeId: 'prune',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 6, "end_week": 10, "climate_bucket_filter": null, '
          '"regionalize": "none"}',
      cadence:
          '1x/year (autumn-fruiting/primocane: cut ALL canes to ground in '
          'late winter)',
      weatherGuard: 'dry12h,temp_gt_0',
      sourceRef:
          'RHS - How to grow raspberries '
          '(rhs.org.uk/fruit/raspberries/grow-your-own)',
      confidence: 'high',
      messageKey: 'suggestions.raspberry.prune_late_winter',
    ),
    // ── B.2 peach ────────────────────────────────────────────────────────────
    PlantTaskRuleSeed(
      id: 'peach.prune',
      scope: 'plant',
      refId: 'peach',
      taskTypeId: 'prune',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 14, "end_week": 20, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence:
          '1x/year (spring at bud burst/flowering - NEVER in winter dormancy: '
          'silver leaf/canker risk)',
      weatherGuard: 'dry24h',
      sourceRef:
          'RHS - How to grow peaches (rhs.org.uk/fruit/peaches/grow-your-own); '
          'LWG Bayern - Merkblatt 3173: Schnitt von Pfirsich '
          '(lwg.bayern.de/mam/cms06/gartenakademie/dateien/'
          '3173-schnitt_pfirsich.pdf)',
      confidence: 'high',
      messageKey: 'suggestions.peach.prune_spring',
    ),
    // ── B.3 tomato ───────────────────────────────────────────────────────────
    PlantTaskRuleSeed(
      id: 'tomato.start_seedlings',
      scope: 'plant',
      refId: 'tomato',
      taskTypeId: 'start_seedlings',
      timingAnchor: 'frost_offset',
      window:
          '{"anchor": "last_frost", "offset_min_days": -56, '
          '"offset_max_days": -42}',
      cadence: 'seasonal (6-8 weeks before last frost, indoors)',
      sourceRef:
          'RHS - How to grow tomatoes '
          '(rhs.org.uk/vegetables/tomatoes/grow-your-own)',
      confidence: 'high',
      messageKey: 'suggestions.tomato.start_seedlings',
    ),
    PlantTaskRuleSeed(
      id: 'tomato.prick_out',
      scope: 'plant',
      refId: 'tomato',
      taskTypeId: 'prick_out',
      timingAnchor: 'growth_stage',
      window:
          '{"after_event": "start_seedlings", "offset_min_days": 14, '
          '"offset_max_days": 21}',
      cadence: 'per chain (first true leaves)',
      sourceRef:
          'RHS - How to grow tomatoes '
          '(rhs.org.uk/vegetables/tomatoes/grow-your-own)',
      confidence: 'high',
      messageKey: 'suggestions.tomato.prick_out',
    ),
    PlantTaskRuleSeed(
      id: 'tomato.harden_off',
      scope: 'plant',
      refId: 'tomato',
      taskTypeId: 'harden_off',
      timingAnchor: 'frost_offset',
      window:
          '{"anchor": "last_frost", "offset_min_days": -14, '
          '"offset_max_days": -7}',
      cadence: 'once per chain (1-2 weeks before planting out)',
      weatherGuard: 'no_frost_forecast_48h',
      sourceRef:
          'RHS - How to grow tomatoes '
          '(rhs.org.uk/vegetables/tomatoes/grow-your-own); RHS - Hardening '
          'off tender plants '
          '(rhs.org.uk/prevention-protection/hardening-off-tender-plants)',
      confidence: 'high',
      messageKey: 'suggestions.tomato.harden_off',
    ),
    PlantTaskRuleSeed(
      id: 'tomato.transplant',
      scope: 'plant',
      refId: 'tomato',
      taskTypeId: 'transplant',
      timingAnchor: 'growth_stage',
      window:
          '{"after_event": "harden_off", "offset_min_days": 7, '
          '"offset_max_days": 14}',
      cadence: 'once per chain (after hardening off AND past last frost)',
      frostGate: true,
      weatherGuard: 'no_frost_forecast_48h,wind_lt_20',
      sourceRef:
          'RHS - How to grow tomatoes '
          '(rhs.org.uk/vegetables/tomatoes/grow-your-own)',
      confidence: 'high',
      messageKey: 'suggestions.tomato.transplant',
    ),
    PlantTaskRuleSeed(
      id: 'tomato.stake',
      scope: 'plant',
      refId: 'tomato',
      taskTypeId: 'stake',
      timingAnchor: 'growth_stage',
      window:
          '{"after_event": "transplant", "offset_min_days": 14, '
          '"offset_max_days": 28}',
      cadence: 'once per season (cordon varieties)',
      sourceRef:
          'RHS - How to grow tomatoes '
          '(rhs.org.uk/vegetables/tomatoes/grow-your-own)',
      confidence: 'medium',
      messageKey: 'suggestions.tomato.stake',
    ),
    // ── B.4 zucchini + cucumber ──────────────────────────────────────────────
    PlantTaskRuleSeed(
      id: 'zucchini.sow',
      scope: 'plant',
      refId: 'zucchini',
      taskTypeId: 'sow',
      timingAnchor: 'frost_offset',
      window:
          '{"anchor": "last_frost", "offset_min_days": 0, '
          '"offset_max_days": 28}',
      cadence: 'seasonal (direct sow after last frost, warm soil)',
      frostGate: true,
      weatherGuard: 'soil_gt_12,no_frost_forecast_48h',
      sourceRef:
          'RHS - How to grow courgettes '
          '(rhs.org.uk/vegetables/courgettes/grow-your-own)',
      confidence: 'high',
      messageKey: 'suggestions.zucchini.sow_direct',
    ),
    PlantTaskRuleSeed(
      id: 'cucumber.sow',
      scope: 'plant',
      refId: 'cucumber',
      taskTypeId: 'sow',
      timingAnchor: 'frost_offset',
      window:
          '{"anchor": "last_frost", "offset_min_days": 7, '
          '"offset_max_days": 28}',
      cadence:
          'seasonal (outdoor ridge cucumbers: direct sow ~1 week after last '
          'frost, warm soil)',
      frostGate: true,
      weatherGuard: 'soil_gt_12,no_frost_forecast_48h',
      sourceRef:
          'RHS - How to grow cucumbers '
          '(rhs.org.uk/vegetables/cucumbers/grow-your-own)',
      confidence: 'high',
      messageKey: 'suggestions.cucumber.sow_direct',
    ),
    // ── B.5 cherry_laurel ────────────────────────────────────────────────────
    PlantTaskRuleSeed(
      id: 'cherry_laurel.prune.late_spring',
      scope: 'plant',
      refId: 'cherry_laurel',
      taskTypeId: 'prune',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 21, "end_week": 24, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence:
          '1st of ~2 trims/year (after spring flush; secateurs preferred over '
          'hedge trimmer - big leaves)',
      weatherGuard: 'temp_lt_30',
      sourceRef:
          'RHS - Prunus laurocerasus plant profile '
          '(rhs.org.uk/plants/13977/prunus-laurocerasus/details); '
          'Gartenakademie RLP - Schnitt von Hecken, aber wie? '
          '(gartenakademie.rlp.de/Internet/global/themen.nsf/0/'
          'd9163e47572bf2dfc12579b4003c68e6)',
      confidence: 'medium',
      messageKey: 'suggestions.cherry_laurel.prune_late_spring',
    ),
    PlantTaskRuleSeed(
      id: 'cherry_laurel.prune.late_summer',
      scope: 'plant',
      refId: 'cherry_laurel',
      taskTypeId: 'prune',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 33, "end_week": 35, "climate_bucket_filter": null, '
          '"regionalize": "autumn"}',
      cadence:
          '2nd trim/year (light tidy; regrowth must harden before frost)',
      weatherGuard: 'temp_lt_30',
      sourceRef:
          'LWG Bayern - Gartencast: Heckengehoelze im Garten ("Spaeter reicht '
          'ein Schnitt gegen Mitte bis Ende August") '
          '(lwg.bayern.de/gartenakademie/gartendokumente/gartencast/200335/'
          'index.php)',
      confidence: 'medium',
      messageKey: 'suggestions.cherry_laurel.prune_late_summer',
    ),
    // ── B.6 rose ─────────────────────────────────────────────────────────────
    PlantTaskRuleSeed(
      id: 'rose.prune',
      scope: 'plant',
      refId: 'rose',
      taskTypeId: 'prune',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 10, "end_week": 14, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence: '1x/year (late winter/early spring - "when forsythia blooms")',
      weatherGuard: 'temp_gt_0,no_frost_forecast_48h',
      sourceRef:
          'RHS - Rose pruning: general tips '
          '(rhs.org.uk/plants/roses/pruning-guide)',
      confidence: 'high',
      messageKey: 'suggestions.rose.prune_spring',
    ),
    PlantTaskRuleSeed(
      id: 'rose.overwinter',
      scope: 'plant',
      refId: 'rose',
      taskTypeId: 'overwinter',
      timingAnchor: 'frost_offset',
      window:
          '{"anchor": "first_frost", "offset_min_days": -28, '
          '"offset_max_days": 0}',
      cadence: '1x/year (hill up / mound base before hard frost)',
      sourceRef:
          'LWG Bayern - Infoschrift: Rosen richtig pflanzen (Anhaeufeln als '
          'Winterschutz) (lwg.bayern.de/gartenakademie/gartendokumente/'
          'infoschriften/081254/index.php)',
      confidence: 'medium',
      messageKey: 'suggestions.rose.overwinter',
    ),
    // ── B.7 blueberry ────────────────────────────────────────────────────────
    PlantTaskRuleSeed(
      id: 'blueberry.prune',
      scope: 'plant',
      refId: 'blueberry',
      taskTypeId: 'prune',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 9, "end_week": 13, "climate_bucket_filter": null, '
          '"regionalize": "none"}',
      cadence:
          '1x/year (late winter/early spring - buds visible, remove old wood)',
      weatherGuard: 'dry12h,temp_gt_0',
      sourceRef:
          'RHS - How to grow blueberries '
          '(rhs.org.uk/fruit/blueberries/grow-your-own)',
      confidence: 'high',
      messageKey: 'suggestions.blueberry.prune',
    ),
    // ── B.8 hydrangea ────────────────────────────────────────────────────────
    PlantTaskRuleSeed(
      id: 'hydrangea.prune.old_wood',
      scope: 'plant',
      refId: 'hydrangea',
      taskTypeId: 'prune',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 12, "end_week": 16, "climate_bucket_filter": null, '
          '"regionalize": "spring"}',
      cadence:
          '1x/year (H. macrophylla/serrata - old wood: ONLY deadhead to first '
          'strong buds; hard prune kills bloom)',
      weatherGuard: 'no_frost_forecast_48h',
      sourceRef:
          'RHS - Hydrangea pruning '
          '(rhs.org.uk/plants/hydrangea/pruning-guide)',
      confidence: 'high',
      messageKey: 'suggestions.hydrangea.prune_old_wood',
    ),
    PlantTaskRuleSeed(
      id: 'hydrangea.prune.new_wood',
      scope: 'plant',
      refId: 'hydrangea',
      taskTypeId: 'prune',
      timingAnchor: 'month_window',
      window:
          '{"start_week": 8, "end_week": 13, "climate_bucket_filter": null, '
          '"regionalize": "none"}',
      cadence:
          '1x/year (H. paniculata/arborescens - new wood: hard prune to '
          'framework in late winter)',
      weatherGuard: 'dry12h,temp_gt_0',
      sourceRef:
          'RHS - Hydrangea pruning '
          '(rhs.org.uk/plants/hydrangea/pruning-guide)',
      confidence: 'high',
      messageKey: 'suggestions.hydrangea.prune_new_wood',
    ),
  ];
}
