import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';
import '../../features/journal/presentation/journal_screen.dart';
import '../../features/tasks/presentation/quick_log_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import 'main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: 'home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/journal',
              name: 'journal',
              builder: (context, state) => const JournalScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              name: 'tasks',
              builder: (context, state) => const TasksScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  name: 'task-detail',
                  builder: (context, state) => const TasksScreen(), // placeholder, M2.7
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // Full-screen routes above the shell (no bottom nav)
    GoRoute(
      path: '/quick-log',
      name: 'quick-log',
      builder: (context, state) => const QuickLogScreen(),
    ),
    GoRoute(
      path: '/tasks/new',
      name: 'task-new',
      builder: (context, state) => const TasksScreen(), // placeholder, M2.4
    ),
  ],
);
