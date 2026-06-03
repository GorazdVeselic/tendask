import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/catalog_labels.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/catalog_provider.dart';
import '../../../core/widgets/section_label.dart';
import '../../../i18n/translations.g.dart';
import 'plant_display.dart';

/// Result of the plant picker: a catalog match ([plantId]) or a private
/// custom entry ([customName]). Returned via `context.pop(pick)`.
typedef PlantPick = ({String? plantId, String? customName});

/// Fixed category order for the filter chips (`all` plus catalog categories).
const _categories = [
  'all',
  'fruit_tree',
  'berries',
  'vegetable',
  'herbs',
  'ornamental',
  'lawn',
];

class PlantPickerScreen extends ConsumerStatefulWidget {
  const PlantPickerScreen({super.key});

  @override
  ConsumerState<PlantPickerScreen> createState() => _PlantPickerScreenState();
}

class _PlantPickerScreenState extends ConsumerState<PlantPickerScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _category = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _categoryLabel(String category, Translations t) => switch (category) {
        'all' => t.plants.cat_all,
        'fruit_tree' => t.plants.cat_fruit_tree,
        'berries' => t.plants.cat_berries,
        'vegetable' => t.plants.cat_vegetable,
        'herbs' => t.plants.cat_herbs,
        'ornamental' => t.plants.cat_ornamental,
        'lawn' => t.plants.cat_lawn,
        _ => category,
      };

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final plants = ref.watch(plantsListProvider).asData?.value;
    final normQuery = _query.trim().toLowerCase();

    final results = plants == null
        ? <Plant>[]
        : plants
            .where((p) => _category == 'all' || p.category == _category)
            .where((p) => plantMatchesQuery(p, normQuery))
            .toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: context.pop,
        ),
        title: Text(t.plants.picker_title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: t.plants.search_hint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final c in _categories)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_categoryLabel(c, t)),
                      selected: c == _category,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: plants == null
                ? const Center(child: CircularProgressIndicator.adaptive())
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      if (results.isNotEmpty) ...[
                        SectionLabel(t.plants.from_catalog,
                            padding: const EdgeInsets.only(bottom: 6)),
                        Card(
                          child: Column(
                            children: [
                              for (var i = 0; i < results.length; i++) ...[
                                if (i > 0)
                                  Divider(
                                    height: 1,
                                    indent: 56,
                                    color: theme.colorScheme.outlineVariant,
                                  ),
                                _CatalogRow(
                                  plant: results[i],
                                  theme: theme,
                                  onTap: () => context.pop(
                                    (plantId: results[i].id, customName: null),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      _CustomEntry(
                        query: _query.trim(),
                        t: t,
                        theme: theme,
                        onAdd: (name) =>
                            context.pop((plantId: null, customName: name)),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _CatalogRow extends StatelessWidget {
  const _CatalogRow({
    required this.plant,
    required this.theme,
    required this.onTap,
  });

  final Plant plant;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sub = plant.scientificName != null
        ? '${plant.scientificName} · ${plant.category}'
        : plant.category;
    return ListTile(
      leading: Text(plant.icon ?? '🌿', style: const TextStyle(fontSize: 22)),
      title: Text(catalogLabel(plant.labels), style: theme.textTheme.bodyMedium),
      subtitle: Text(sub, style: theme.textTheme.bodySmall),
      trailing: Icon(Icons.add, color: theme.colorScheme.primary),
      onTap: onTap,
    );
  }
}

class _CustomEntry extends StatelessWidget {
  const _CustomEntry({
    required this.query,
    required this.t,
    required this.theme,
    required this.onAdd,
  });

  final String query;
  final Translations t;
  final ThemeData theme;
  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    if (query.isEmpty) return const SizedBox.shrink();
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          style: BorderStyle.solid,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(t.plants.not_found,
                padding: const EdgeInsets.only(bottom: 6)),
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () => onAdd(query),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  t.plants.custom_add(q: query),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.plants.custom_private,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
