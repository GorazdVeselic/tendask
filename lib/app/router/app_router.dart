import 'package:go_router/go_router.dart';
import '../../features/journal/presentation/journal_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import 'main_shell.dart';

final appRouter = GoRouter(
  initialLocation: '/dnevnik',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, shell) => MainShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dnevnik',
              name: 'dnevnik',
              builder: (context, state) => const JournalScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/opravila',
              name: 'opravila',
              builder: (context, state) => const TasksScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
