import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../i18n/translations.g.dart';

class MainShell extends StatelessWidget {
  const MainShell({required this.shell, super.key});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      body: shell,
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // wired in M2: opens quick entry (screen 02)
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: shell.goBranch,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.calendar_today_outlined),
            selectedIcon: const Icon(Icons.calendar_today),
            label: t.nav.journal,
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
