import 'package:go_router/go_router.dart';

import '../../features/areas/presentation/area_detail_screen.dart';
import '../../features/areas/presentation/area_form_screen.dart';
import '../../features/areas/presentation/areas_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/journal/presentation/journal_screen.dart';
import '../../features/journal/presentation/note_form_screen.dart';
import '../../features/plants/presentation/plant_detail_screen.dart';
import '../../features/plants/presentation/plant_edit_screen.dart';
import '../../features/plants/presentation/plant_picker_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/supplies/presentation/supplies_screen.dart';
import '../../features/tasks/presentation/entry/entry_screen.dart';
import '../../features/tasks/presentation/task_detail_screen.dart';
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
              path: '/tasks',
              name: 'tasks',
              builder: (context, state) => const TasksScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  name: 'task-detail',
                  builder: (context, state) => TaskDetailScreen(
                    id: state.pathParameters['id']!,
                  ),
                ),
              ],
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
              path: '/areas',
              name: 'areas',
              builder: (context, state) => const AreasScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  name: 'area-detail',
                  builder: (context, state) => AreaDetailScreen(
                    id: state.pathParameters['id']!,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
    // Full-screen routes above the shell (no bottom nav)
    GoRoute(
      path: '/plant-picker',
      name: 'plant-picker',
      builder: (context, state) => const PlantPickerScreen(),
    ),
    GoRoute(
      path: '/plant-new',
      name: 'plant-new',
      builder: (context, state) => const PlantEditScreen(),
    ),
    GoRoute(
      path: '/plant/:id',
      name: 'plant-detail',
      builder: (context, state) =>
          PlantDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/plant/:id/edit',
      name: 'plant-edit',
      builder: (context, state) =>
          PlantEditScreen(userPlantId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/supplies',
      name: 'supplies',
      builder: (context, state) => const SuppliesScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    // Path must not collide with the shell '/areas/:id' (area-detail):
    // '/areas/new' would match ':id'="new". Use a distinct prefix.
    GoRoute(
      path: '/area-new',
      name: 'area-new',
      builder: (context, state) => const AreaFormScreen(),
    ),
    GoRoute(
      path: '/areas/:id/edit',
      name: 'area-edit',
      builder: (context, state) =>
          AreaFormScreen(areaId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/notes/new',
      name: 'note-new',
      builder: (context, state) => const NoteFormScreen(),
    ),
    GoRoute(
      path: '/notes/:id/edit',
      name: 'note-edit',
      builder: (context, state) =>
          NoteFormScreen(noteId: state.pathParameters['id']),
    ),
    // Path must not collide with the shell '/tasks/:id' (task-detail):
    // '/tasks/new' would match ':id'="new". Use a distinct prefix.
    GoRoute(
      path: '/task-new',
      name: 'task-new',
      builder: (context, state) {
        final raw = state.uri.queryParameters['date'];
        return EntryScreen(
          initialDate: raw != null ? DateTime.tryParse(raw) : null,
        );
      },
    ),
    GoRoute(
      path: '/tasks/:id/edit',
      name: 'task-edit',
      builder: (context, state) =>
          EntryScreen(taskId: state.pathParameters['id']),
    ),
  ],
);
