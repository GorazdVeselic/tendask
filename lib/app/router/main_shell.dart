import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../i18n/translations.g.dart';

class MainShell extends StatelessWidget {
  const MainShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    // Quick-log FAB only on Home (0) and Journal (1); Areas/Tasks have their
    // own add actions and the FAB would overlap their content / action sheets.
    final showFab = shell.currentIndex == 0 || shell.currentIndex == 1;
    return Scaffold(
      body: shell,
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: () => context.pushNamed('task-new'),
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: t.nav.home,
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
          NavigationDestination(
            icon: const Icon(Icons.check_box_outlined),
            selectedIcon: const Icon(Icons.check_box),
            label: t.nav.tasks,
          ),
        ],
      ),
    );
  }
}
