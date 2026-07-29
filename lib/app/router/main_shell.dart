import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/config.dart';
import '../../i18n/translations.g.dart';

class MainShell extends StatelessWidget {
  const MainShell({
    required this.shell,
    this.community = kCommunityEnabled,
    super.key,
  });

  final StatefulNavigationShell shell;

  /// Passed down by the router rather than read here, so the tab and the shell
  /// branch can never disagree: one destination too many and every index after
  /// it points at the wrong branch.
  final bool community;

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: MainShellNavigationBar(
        selectedIndex: shell.currentIndex,
        // Every tab tap returns to that tab's root screen (resets its stack),
        // so an open detail/entity is never shown when switching tabs.
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: true),
        community: community,
      ),
    );
  }
}

/// The bottom nav. A widget of its own so the layout matrix renders exactly what
/// the app renders — labels *and* their text-scale ceiling: five tabs leave 64 px
/// per label at 320 dp, and a label that does not fit breaks mid-word (R4).
class MainShellNavigationBar extends StatelessWidget {
  const MainShellNavigationBar({
    required this.selectedIndex,
    this.onDestinationSelected,
    this.community = kCommunityEnabled,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final bool community;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: kNavLabelMaxTextScale,
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        destinations: mainShellDestinations(context.t, community: community),
      ),
    );
  }
}

/// The bottom-nav destinations, in branch order.
List<NavigationDestination> mainShellDestinations(
  Translations t, {
  required bool community,
}) => [
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
  if (community)
    NavigationDestination(
      // Hexagon = the H3 cell the aggregates are grouped by (and the logo).
      icon: const Icon(Icons.hexagon_outlined),
      selectedIcon: const Icon(Icons.hexagon),
      label: t.nav.community,
    ),
];
