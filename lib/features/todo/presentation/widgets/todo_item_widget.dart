import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/todo_bloc.dart';
import '../../data/todo_model.dart';
import 'add_edit_todo_sheet.dart';

class TodoItemWidget extends StatelessWidget {
  final TodoModel todo;

  const TodoItemWidget({super.key, required this.todo});

  Color _priorityColor(TodoPriority p) {
    switch (p) {
      case TodoPriority.high:
        return AppColors.error;
      case TodoPriority.medium:
        return AppColors.warning;
      case TodoPriority.low:
        return AppColors.secondary;
      case TodoPriority.none:
        return Colors.transparent;
    }
  }

  IconData _priorityIcon(TodoPriority p) {
    switch (p) {
      case TodoPriority.high:
        return Icons.keyboard_double_arrow_up_rounded;
      case TodoPriority.medium:
        return Icons.drag_handle_rounded;
      case TodoPriority.low:
        return Icons.keyboard_double_arrow_down_rounded;
      case TodoPriority.none:
        return Icons.circle_outlined;
    }
  }

  String _dueDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = dateOnly.difference(today).inDays;

    if (diff < 0) return '${diff.abs()}d overdue';
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff <= 6) return DateFormat('EEEE').format(date);
    return DateFormat('MMM d').format(date);
  }

  Color _dueDateColor(DateTime date, bool isCompleted) {
    if (isCompleted) return AppColors.success;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = dateOnly.difference(today).inDays;

    if (diff < 0) return AppColors.error;
    if (diff == 0) return AppColors.success;
    if (diff == 1) return AppColors.warning;
    return AppColors.primary;
  }

  IconData _dueDateIcon(DateTime date, bool isCompleted) {
    if (isCompleted) return Icons.check_circle_outline_rounded;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    if (dateOnly.isBefore(today)) return Icons.warning_amber_rounded;
    return Icons.schedule_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) =>
          context.read<TodoBloc>().add(DeleteTodo(todoId: todo.id)),
      background: _buildSwipeBackground(),
      child: _buildCard(context),
    );
  }

  Widget _buildSwipeBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.delete_rounded, color: Colors.white, size: 24),
          SizedBox(height: 4),
          Text(
            'Delete',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final priorityColor = _priorityColor(todo.priority);
    final hasPriority = todo.priority != TodoPriority.none;
    final isOverdue = todo.isOverdue;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOverdue && !todo.isCompleted
              ? AppColors.error.withValues(alpha: 0.4)
              : todo.isCompleted
                  ? AppColors.success.withValues(alpha: 0.2)
                  : colorScheme.onSurface.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              if (hasPriority)
                Container(
                  width: 4,
                  color: todo.isCompleted
                      ? priorityColor.withValues(alpha: 0.3)
                      : priorityColor,
                ),

              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showEditSheet(context),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        hasPriority ? 12 : 16,
                        14,
                        12,
                        14,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () => context
                                .read<TodoBloc>()
                                .add(ToggleTodo(todo: todo)),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 22,
                              height: 22,
                              margin: const EdgeInsets.only(top: 1),
                              decoration: BoxDecoration(
                                color: todo.isCompleted
                                    ? AppColors.success
                                    : Colors.transparent,
                                border: Border.all(
                                  color: todo.isCompleted
                                      ? AppColors.success
                                      : colorScheme.onSurface
                                          .withValues(alpha: 0.3),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: todo.isCompleted
                                  ? const Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    )
                                  : null,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    if (hasPriority) ...[
                                      Icon(
                                        _priorityIcon(todo.priority),
                                        size: 14,
                                        color: todo.isCompleted
                                            ? priorityColor
                                                .withValues(alpha: 0.4)
                                            : priorityColor,
                                      ),
                                      const SizedBox(width: 5),
                                    ],
                                    Expanded(
                                      child: Text(
                                        todo.title,
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: todo.isCompleted
                                              ? colorScheme.onSurface
                                                  .withValues(alpha: 0.4)
                                              : colorScheme.onSurface,
                                          decoration: todo.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                          decorationColor: colorScheme.onSurface
                                              .withValues(alpha: 0.4),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                if (todo.description.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    todo.description,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: colorScheme.onSurface.withValues(
                                        alpha: todo.isCompleted ? 0.3 : 0.5,
                                      ),
                                      decoration: todo.isCompleted
                                          ? TextDecoration.lineThrough
                                          : null,
                                      decorationColor: colorScheme.onSurface
                                          .withValues(alpha: 0.3),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],

                                const SizedBox(height: 8),

                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: [
                                    if (todo.dueDate != null)
                                      _Badge(
                                        icon: _dueDateIcon(
                                          todo.dueDate!,
                                          todo.isCompleted,
                                        ),
                                        label: _dueDateLabel(todo.dueDate!),
                                        color: _dueDateColor(
                                          todo.dueDate!,
                                          todo.isCompleted,
                                        ),
                                      ),

                                    if (hasPriority)
                                      _Badge(
                                        icon: _priorityIcon(todo.priority),
                                        label: todo.priority.label,
                                        color: todo.isCompleted
                                            ? priorityColor
                                                .withValues(alpha: 0.4)
                                            : priorityColor,
                                      ),

                                    if (todo.isCompleted)
                                      const _Badge(
                                        icon: Icons.check_circle_rounded,
                                        label: 'Done',
                                        color: AppColors.success,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          IconButton(
                            onPressed: () => _showEditSheet(context),
                            icon: Icon(
                              Icons.edit_rounded,
                              size: 17,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.25),
                            ),
                            style: IconButton.styleFrom(
                              minimumSize: const Size(36, 36),
                              padding: EdgeInsets.zero,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<TodoBloc>(),
        child: AddEditTodoSheet(todo: todo),
      ),
    );
  }

  Future<bool?> _confirmDelete(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Task',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text('Delete "${todo.title}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
