import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_icons.dart';
import '../../i18n/translations.g.dart';

class MainShell extends StatelessWidget {
  const MainShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    // Add FAB on the Home/Tasks *tabs* themselves — not on pushed sub-pages
    // (e.g. task detail), where it would overlap their action bars. Journal is a
    // read-only history view, so it has no add button. The Garden tab owns its
    // own contextual FAB (plant/supply/recipe per segment), so it is excluded
    // here to avoid a duplicate.
    final location = GoRouterState.of(context).uri.path;
    final showFab = location == '/home' || location == '/tasks';
    return Scaffold(
      body: shell,
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: () => context.pushNamed('task-new'),
              child: const Icon(kIconAdd),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        // Every tab tap returns to that tab's root screen (resets its stack),
        // so an open detail/entity is never shown when switching tabs.
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: true),
        destinations: [
          NavigationDestination(
            icon: const Icon(kIconHomeOutlined),
            selectedIcon: const Icon(kIconHome),
            label: t.nav.home,
          ),
          NavigationDestination(
            icon: const Icon(kIconCheckBoxOutlined),
            selectedIcon: const Icon(kIconCheckBox),
            label: t.nav.tasks,
          ),
          NavigationDestination(
            icon: const Icon(kIconCalendarTodayOutlined),
            selectedIcon: const Icon(kIconCalendarToday),
            label: t.nav.journal,
          ),
          NavigationDestination(
            icon: const Icon(kIconGrassOutlined),
            selectedIcon: const Icon(kIconGrass),
            label: t.nav.areas,
          ),
        ],
      ),
    );
  }
}
