import 'package:flutter/material.dart';

import '../../../../core/location/geocoding_client.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../i18n/translations.g.dart';

/// Primary option: type a place name (Open-Meteo geocoding). Geocoded matches
/// render inline below the field; tapping one saves it.
class EnterPlaceCard extends StatelessWidget {
  const EnterPlaceCard({
    super.key,
    required this.controller,
    required this.loading,
    required this.onSearch,
    required this.results,
    required this.onSelect,
  });

  final TextEditingController controller;
  final bool loading;
  final VoidCallback onSearch;
  final List<GeoPlace> results;
  final ValueChanged<GeoPlace> onSelect;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.primary, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldLabel(t.location.enter_place),
          TextField(
            controller: controller,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: t.location.place_hint,
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: loading ? null : onSearch,
              ),
            ),
            onSubmitted: (_) => loading ? null : onSearch(),
          ),
          const SizedBox(height: 6),
          Text(
            t.location.place_note,
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          for (final place in results)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.place_outlined),
              title: Text(place.name),
              subtitle: Text(
                [place.admin1, place.country].whereType<String>().join(', '),
              ),
              onTap: () => onSelect(place),
            ),
        ],
      ),
    );
  }
}
