import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../i18n/translations.g.dart';

class MainShell extends StatelessWidget {
  const MainShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    // Add FAB on the Home/Tasks/Garden *tabs* themselves — not on pushed
    // sub-pages (e.g. task detail), where it would overlap their action bars.
    // Journal is a read-only history view, so it has no add button. On the
    // Garden tab the FAB goes straight to adding plants (area-add is a quieter
    // entry in the list); elsewhere it opens the task quick-log.
    final location = GoRouterState.of(context).uri.path;
    final onGarden = location == '/areas';
    final showFab =
        location == '/home' || location == '/tasks' || onGarden;
    return Scaffold(
      body: shell,
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: () =>
                  context.pushNamed(onGarden ? 'plant-add' : 'task-new'),
              child: const Icon(Icons.add),
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
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: t.nav.home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.check_box_outlined),
            selectedIcon: const Icon(Icons.check_box),
            label: t.nav.tasks,
          ),
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today),
            label: t.nav.journal,
          ),
          NavigationDestination(
            icon: const Icon(Icons.grass_outlined),
            selectedIcon: const Icon(Icons.grass),
            label: t.nav.areas,
          ),
        ],
      ),
    );
  }
}
