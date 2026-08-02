import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme/moon_colors.dart';
import '../../../core/app_icons.dart';
import '../../../core/biodynamic/biodynamic_day.dart';
import '../../../core/biodynamic/category_element.dart';
import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/date_format.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import '../../../core/glyphs.dart';
import '../../plants/presentation/plant_picker_screen.dart';
import '../application/moon_finder.dart';
import 'moon_day_sheet.dart';
import 'moon_text.dart';
import 'widgets/element_glyph.dart';

/// The reverse finder (FR-19 T5.2, wireframe board 4): pick a plant, get the
/// next stretches of days its element favours. Reached from 🔎 on the calendar
/// (empty) or from a plant with `?plant=<catalog id>` prefilled.
class MoonFinderScreen extends ConsumerStatefulWidget {
  const MoonFinderScreen({super.key, this.initialPlantId});

  /// Catalog plant id to start with; unknown ids simply leave the field empty.
  final String? initialPlantId;

  @override
  ConsumerState<MoonFinderScreen> createState() => _MoonFinderScreenState();
}

class _MoonFinderScreenState extends ConsumerState<MoonFinderScreen>
    with WidgetsBindingObserver {
  String? _plantId;

  /// Private entry from the picker: named, but without a catalog element.
  String? _customName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _plantId = widget.initialPlantId;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The list starts at today (read in build); a screen resumed the next
    // morning must not keep offering yesterday.
    if (state == AppLifecycleState.resumed) setState(() {});
  }

  Future<void> _pickPlant() async {
    final pick = await context.pushNamed<PlantPick>('plant-picker');
    if (pick == null || !mounted) return;
    setState(() {
      _plantId = pick.plantId;
      _customName = pick.customName;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final catalog = ref.watch(plantsMapProvider).asData?.value ?? const {};
    final plant = _plantId == null ? null : catalog[_plantId];
    final element = plant == null
        ? null
        : plantElement(category: plant.category, plantId: plant.id);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(kIconArrowBack),
          onPressed: context.pop,
        ),
        title: Text(t.moon.finder.title),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          FieldLabel(t.moon.finder.plant_label),
          _PlantField(
            plant: plant,
            customName: _customName,
            onTap: _pickPlant,
          ),
          const SizedBox(height: 14),
          if (plant != null && element != null)
            _Runs(
              element: element,
              plantLabel: catalogLabel(plant.labels),
            )
          else
            _Note(
              plant == null && _customName == null
                  ? t.moon.finder.empty_hint
                  : t.moon.finder.no_recommendation,
            ),
        ],
      ),
    );
  }
}

/// Input-looking row that opens the shared plant picker.
class _PlantField extends StatelessWidget {
  const _PlantField({
    required this.plant,
    required this.customName,
    required this.onTap,
  });

  final Plant? plant;
  final String? customName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    // Local copy so the null check promotes (a widget field never does).
    final catalogPlant = plant;
    final label = catalogPlant != null
        ? catalogLabel(catalogPlant.labels)
        : customName;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: InputDecorator(
        decoration: InputDecoration(
          hintText: t.moon.finder.plant_hint,
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(kIconArrowDropDown),
        ),
        isEmpty: label == null,
        child: label == null
            ? null
            : Row(
                children: [
                  Text(
                    plant?.icon ?? kGlyphPlantFallback,
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(label, style: theme.textTheme.bodyMedium),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Muted one-liner: nothing picked yet, or a plant the calendar says nothing
/// about (houseplants, conifers, hedges, private entries).
class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
      ),
    );
  }
}

/// The answer: which element the plant wants, then the upcoming stretches.
class _Runs extends ConsumerWidget {
  const _Runs({required this.element, required this.plantLabel});

  final BiodynamicElement element;
  final String plantLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final theme = Theme.of(context);
    final today = startOfDay(DateTime.now());
    final runs = ref.watch(moonFinderRunsProvider(element, today));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            color: MoonColors.of(context).softOf(element),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            // Map completeness against BiodynamicElement is enforced by i18n
            // tests.
            t.moon.finder.callout(
              // Catalog labels are lowercase; here the name opens a sentence.
              plant: sentenceCase(plantLabel),
              day: t.moon.day_for[element.name]!,
            ),
            // Text on a soft element background stays onSurface (A4).
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        if (runs.isNotEmpty) ...[
          SectionLabel(
            t.moon.finder.next_days,
            padding: const EdgeInsets.fromLTRB(4, 18, 4, 4),
          ),
          for (final run in runs) _RunRow(run: run, element: element),
        ],
      ],
    );
  }
}

/// One stretch: element avatar, the date range, the phase half, and a "+"
/// straight into the prefilled task form.
class _RunRow extends StatelessWidget {
  const _RunRow({required this.run, required this.element});

  final MoonDayRun run;
  final BiodynamicElement element;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);

    final start = '${weekdayShort(t, run.start)} ${formatDm(run.start)}';
    final range = run.start == run.end
        ? start
        : '$start – ${weekdayShort(t, run.end)} ${formatDm(run.end)}';

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => showMoonDaySheet(context, run.start),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: MoonColors.of(context).softOf(element),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  elementEmoji(element),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    range,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    run.waxing
                        ? t.moon.finder.waxing
                        : t.moon.finder.waning,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(kIconAdd),
              tooltip: t.moon.sheet.add_task,
              color: theme.colorScheme.primary,
              onPressed: () => context.pushNamed(
                'task-new',
                queryParameters: {'date': run.start.toIso8601String()},
              ),
            ),
          ],
        ),
      ),
    );
  }
}
