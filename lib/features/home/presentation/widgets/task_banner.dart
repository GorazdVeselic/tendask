import 'package:flutter/material.dart';

import '../../../../core/database/app_database.dart';
import 'home_task_list.dart';

/// Collapsible task summary: a quiet colored bar showing a count; tapping it
/// expands the task list in place (no jump to another screen). Drives both the
/// overdue (terracotta) and upcoming (green) summaries on Home.
class TaskBanner extends StatefulWidget {
  const TaskBanner({
    super.key,
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.tasks,
    required this.catalog,
    required this.now,
    required this.subjectLabels,
    this.reminderTaskIds = const {},
    this.isOverdue = false,
    this.isUpcoming = false,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final List<Task> tasks;
  final Map<String, TaskType> catalog;
  final DateTime now;
  final Map<String, String> subjectLabels;
  final Set<String> reminderTaskIds;
  final bool isOverdue;
  final bool isUpcoming;

  @override
  State<TaskBanner> createState() => _TaskBannerState();
}

class _TaskBannerState extends State<TaskBanner> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: widget.background,
          borderRadius: BorderRadius.vertical(
            top: const Radius.circular(12),
            bottom: Radius.circular(_expanded ? 0 : 12),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
              child: Row(
                children: [
                  Icon(widget.icon, size: 18, color: widget.foreground),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: widget.foreground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(Icons.expand_more, color: widget.foreground),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_expanded)
          HomeTaskList(
            tasks: widget.tasks,
            catalog: widget.catalog,
            now: widget.now,
            subjectLabels: widget.subjectLabels,
            reminderTaskIds: widget.reminderTaskIds,
            isOverdue: widget.isOverdue,
            isUpcoming: widget.isUpcoming,
            topAttached: true,
          ),
      ],
    );
  }
}
