import 'package:flutter/material.dart';

/// One selectable plant row: icon, name, optional subtitle, and a ＋/✓ badge on
/// the right that toggles selection. Shared by the garden plant-add catalog and
/// the task subject picker so both read identically.
class PlantSelectRow extends StatelessWidget {
  const PlantSelectRow({
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
    super.key,
  });

  final String icon;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return ListTile(
      tileColor: selected ? cs.primaryContainer.withValues(alpha: 0.4) : null,
      shape: selected
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
          : null,
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(title, style: theme.textTheme.bodyMedium),
      subtitle: subtitle != null
          ? Text(subtitle!, style: theme.textTheme.bodySmall)
          : null,
      trailing: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: selected ? cs.primary : cs.primaryContainer,
        ),
        child: Icon(
          selected ? Icons.check : Icons.add,
          size: 18,
          color: selected ? cs.onPrimary : cs.primary,
        ),
      ),
      onTap: onTap,
    );
  }
}
