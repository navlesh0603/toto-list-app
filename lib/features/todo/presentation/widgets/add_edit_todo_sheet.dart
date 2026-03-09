import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../bloc/todo_bloc.dart';
import '../../data/todo_model.dart';

class AddEditTodoSheet extends StatefulWidget {
  final TodoModel? todo;

  const AddEditTodoSheet({super.key, this.todo});

  @override
  State<AddEditTodoSheet> createState() => _AddEditTodoSheetState();
}

class _AddEditTodoSheetState extends State<AddEditTodoSheet> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDueDate;
  TodoPriority _selectedPriority = TodoPriority.none;
  bool _isSubmitting = false;

  bool get _isEditing => widget.todo != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.todo!.title;
      _descriptionController.text = widget.todo!.description;
      _selectedDueDate = widget.todo!.dueDate;
      _selectedPriority = widget.todo!.priority;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    if (_isEditing) {
      context.read<TodoBloc>().add(
            UpdateTodo(
              todo: widget.todo!.copyWith(
                title: _titleController.text.trim(),
                description: _descriptionController.text.trim(),
                dueDate: _selectedDueDate,
                clearDueDate: _selectedDueDate == null,
                priority: _selectedPriority,
              ),
            ),
          );
    } else {
      context.read<TodoBloc>().add(
            AddTodo(
              title: _titleController.text.trim(),
              description: _descriptionController.text.trim(),
              dueDate: _selectedDueDate,
              priority: _selectedPriority,
            ),
          );
    }
    Navigator.of(context).pop();
  }

  Future<void> _pickDueDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: DateTime(now.year + 5),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: Theme.of(ctx).colorScheme.copyWith(
                primary: AppColors.primary,
              ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _isEditing ? Icons.edit_rounded : Icons.add_rounded,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  _isEditing ? 'Edit Task' : 'New Task',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    autofocus: !_isEditing,
                    maxLength: 120,
                    decoration: const InputDecoration(
                      labelText: 'Task title *',
                      hintText: 'What needs to be done?',
                      counterText: '',
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _descriptionController,
                    textInputAction: TextInputAction.done,
                    maxLines: 2,
                    maxLength: 300,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'Add details...',
                      alignLabelWithHint: true,
                      counterText: '',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const _SectionLabel(label: 'Due date'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _pickDueDate(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _selectedDueDate != null
                            ? _dueDateColor(_selectedDueDate!)
                                .withValues(alpha: 0.1)
                            : colorScheme.onSurface.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedDueDate != null
                              ? _dueDateColor(_selectedDueDate!)
                                  .withValues(alpha: 0.5)
                              : colorScheme.onSurface.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: _selectedDueDate != null
                                ? _dueDateColor(_selectedDueDate!)
                                : colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _selectedDueDate != null
                                ? _formatDueDate(_selectedDueDate!)
                                : 'Set a deadline',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: _selectedDueDate != null
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: _selectedDueDate != null
                                  ? _dueDateColor(_selectedDueDate!)
                                  : colorScheme.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_selectedDueDate != null) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => setState(() => _selectedDueDate = null),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor:
                          colorScheme.onSurface.withValues(alpha: 0.06),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                _QuickDateChip(
                  label: 'Today',
                  icon: Icons.wb_sunny_rounded,
                  color: AppColors.success,
                  isSelected: _isDateSelected(DateTime.now()),
                  onTap: () => setState(() => _selectedDueDate = _today()),
                ),
                const SizedBox(width: 8),
                _QuickDateChip(
                  label: 'Tomorrow',
                  icon: Icons.wb_twilight_rounded,
                  color: AppColors.warning,
                  isSelected: _isDateSelected(
                    DateTime.now().add(const Duration(days: 1)),
                  ),
                  onTap: () => setState(
                    () => _selectedDueDate =
                        _today().add(const Duration(days: 1)),
                  ),
                ),
                const SizedBox(width: 8),
                _QuickDateChip(
                  label: 'Next week',
                  icon: Icons.date_range_rounded,
                  color: AppColors.primary,
                  isSelected: _isDateSelected(
                    DateTime.now().add(const Duration(days: 7)),
                  ),
                  onTap: () => setState(
                    () => _selectedDueDate =
                        _today().add(const Duration(days: 7)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            const _SectionLabel(label: 'Priority'),
            const SizedBox(height: 8),
            Row(
              children: TodoPriority.values.map((p) {
                final isSelected = _selectedPriority == p;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPriority = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _priorityColor(p).withValues(alpha: 0.15)
                            : colorScheme.onSurface.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? _priorityColor(p)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _priorityIcon(p),
                            size: 18,
                            color: isSelected
                                ? _priorityColor(p)
                                : colorScheme.onSurface.withValues(alpha: 0.35),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isSelected
                                  ? _priorityColor(p)
                                  : colorScheme.onSurface.withValues(alpha: 0.45),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _submit(context),
                    child: Text(_isEditing ? 'Save Changes' : 'Add Task'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  DateTime _today() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  bool _isDateSelected(DateTime date) {
    if (_selectedDueDate == null) return false;
    return _selectedDueDate!.year == date.year &&
        _selectedDueDate!.month == date.month &&
        _selectedDueDate!.day == date.day;
  }

  String _formatDueDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = dateOnly.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff < 0) return '${diff.abs()} days overdue';
    if (diff <= 6) return DateFormat('EEEE').format(date);
    return DateFormat('MMM d, yyyy').format(date);
  }

  Color _dueDateColor(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = dateOnly.difference(today).inDays;

    if (diff < 0) return AppColors.error;
    if (diff == 0) return AppColors.success;
    if (diff == 1) return AppColors.warning;
    return AppColors.primary;
  }

  Color _priorityColor(TodoPriority p) {
    switch (p) {
      case TodoPriority.high:
        return AppColors.error;
      case TodoPriority.medium:
        return AppColors.warning;
      case TodoPriority.low:
        return AppColors.secondary;
      case TodoPriority.none:
        return const Color(0xFF94A3B8);
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
        return Icons.remove_rounded;
    }
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
      ),
    );
  }
}

class _QuickDateChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _QuickDateChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isSelected ? color : Colors.grey),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
