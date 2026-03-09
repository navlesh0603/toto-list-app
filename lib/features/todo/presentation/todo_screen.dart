import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/todo_bloc.dart';
import '../data/todo_model.dart';
import 'widgets/add_edit_todo_sheet.dart';
import 'widgets/todo_item_widget.dart';

enum _Filter { all, active, completed }

enum _SortOrder { createdAt, dueDate, priority, alphabetical }

extension on _SortOrder {
  String get label {
    switch (this) {
      case _SortOrder.createdAt:
        return 'Newest first';
      case _SortOrder.dueDate:
        return 'Due date';
      case _SortOrder.priority:
        return 'Priority';
      case _SortOrder.alphabetical:
        return 'A → Z';
    }
  }

  IconData get icon {
    switch (this) {
      case _SortOrder.createdAt:
        return Icons.access_time_rounded;
      case _SortOrder.dueDate:
        return Icons.calendar_today_rounded;
      case _SortOrder.priority:
        return Icons.flag_rounded;
      case _SortOrder.alphabetical:
        return Icons.sort_by_alpha_rounded;
    }
  }
}

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  _Filter _filter = _Filter.all;
  _SortOrder _sortOrder = _SortOrder.createdAt;
  bool _searchOpen = false;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<TodoModel> _process(List<TodoModel> todos) {
    List<TodoModel> result;
    switch (_filter) {
      case _Filter.active:
        result = todos.where((t) => !t.isCompleted).toList();
        break;
      case _Filter.completed:
        result = todos.where((t) => t.isCompleted).toList();
        break;
      case _Filter.all:
        result = List.from(todos);
        break;
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result
          .where(
            (t) =>
                t.title.toLowerCase().contains(q) ||
                t.description.toLowerCase().contains(q),
          )
          .toList();
    }

    result.sort((a, b) {
      switch (_sortOrder) {
        case _SortOrder.createdAt:
          return b.createdAt.compareTo(a.createdAt);
        case _SortOrder.dueDate:
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        case _SortOrder.priority:
          final pc = a.priority.sortOrder.compareTo(b.priority.sortOrder);
          if (pc != 0) return pc;
          return b.createdAt.compareTo(a.createdAt);
        case _SortOrder.alphabetical:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });

    return result;
  }

  List<TodoModel> _getTodos(TodoState state) {
    if (state is TodoLoaded) return state.todos;
    if (state is TodoError) return state.previousTodos;
    return [];
  }

  int _overdueCount(List<TodoModel> todos) =>
      todos.where((t) => t.isOverdue).length;

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<TodoBloc>(),
        child: const AddEditTodoSheet(),
      ),
    );
  }

  void _showSortSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(
        current: _sortOrder,
        onSelected: (o) => setState(() => _sortOrder = o),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<TodoBloc, TodoState>(
        listener: (context, state) {
          if (state is TodoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () => context.read<TodoBloc>().add(LoadTodos()),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          final todos = _getTodos(state);
          final processed = _process(todos);
          final overdue = _overdueCount(todos);

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, todos, overdue),

                if (todos.isNotEmpty && !_searchOpen)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _buildProgressCard(context, todos),
                  ),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _searchOpen
                      ? _buildSearchBar(context)
                      : const SizedBox.shrink(),
                ),

                _buildFilterAndSort(context),
                const SizedBox(height: 8),

                Expanded(
                  child: _buildBody(context, state, processed),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSheet(context),
        tooltip: 'Add Task',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    List<TodoModel> todos,
    int overdueCount,
  ) {
    final authState = context.watch<AuthBloc>().state;
    final email = authState is AuthAuthenticated ? (authState.email ?? '') : '';
    final username = email.isNotEmpty ? email.split('@').first : 'User';
    final initials = username.isNotEmpty ? username[0].toUpperCase() : 'U';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  username,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (overdueCount > 0) ...[
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 13, color: AppColors.error),
                      const SizedBox(width: 4),
                      Text(
                        '$overdueCount task${overdueCount == 1 ? '' : 's'} overdue',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          IconButton(
            onPressed: () {
              setState(() {
                _searchOpen = !_searchOpen;
                if (!_searchOpen) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
            icon: Icon(
              _searchOpen ? Icons.search_off_rounded : Icons.search_rounded,
              color: _searchOpen
                  ? AppColors.primary
                  : Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
            ),
            tooltip: 'Search tasks',
          ),

          _buildAvatarMenu(context, initials),

          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Search tasks…',
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildAvatarMenu(BuildContext context, String initials) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
              SizedBox(width: 10),
              Text(
                'Sign Out',
                style: TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (v) {
        if (v == 'logout') _confirmLogout(context);
      },
      tooltip: 'Account menu',
      child: CircleAvatar(
        radius: 22,
        backgroundColor: AppColors.primary,
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, List<TodoModel> todos) {
    final completed = todos.where((t) => t.isCompleted).length;
    final total = todos.length;
    final progress = total > 0 ? completed / total : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completed of $total task${total == 1 ? '' : 's'} done',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterAndSort(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: _Filter.values.map((f) {
                final isSelected = _filter == f;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: const EdgeInsets.only(right: 6),
                      height: 38,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        f.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(width: 6),

          GestureDetector(
            onTap: () => _showSortSheet(context),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: _sortOrder != _SortOrder.createdAt
                    ? AppColors.primary.withValues(alpha: 0.12)
                    : Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: _sortOrder != _SortOrder.createdAt
                    ? Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sort_rounded,
                    size: 16,
                    color: _sortOrder != _SortOrder.createdAt
                        ? AppColors.primary
                        : Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Sort',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _sortOrder != _SortOrder.createdAt
                          ? AppColors.primary
                          : Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    TodoState state,
    List<TodoModel> items,
  ) {
    if (state is TodoLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (items.isEmpty) return _buildEmptyState(context);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
      itemCount: items.length,
      itemBuilder: (_, i) => TodoItemWidget(todo: items[i]),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bool isSearch = _searchQuery.trim().isNotEmpty;

    final (title, subtitle) = isSearch
        ? (
            'No results',
            'No tasks match "$_searchQuery".',
          )
        : switch (_filter) {
            _Filter.active => (
                'All caught up!',
                'No active tasks. Add one with the + button.',
              ),
            _Filter.completed => (
                'Nothing completed yet',
                "Finish a task and it'll show up here.",
              ),
            _Filter.all => (
                'No tasks yet',
                'Tap the + button to add your first task.',
              ),
          };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: cs.onSurface.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
            if (_filter == _Filter.all && !isSearch) ...[
              const SizedBox(height: 28),
              SizedBox(
                width: 200,
                child: ElevatedButton.icon(
                  onPressed: () => _showAddSheet(context),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Add First Task'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning,';
    if (h < 17) return 'Good afternoon,';
    return 'Good evening,';
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AuthBloc>().add(LogoutRequested());
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SortSheet extends StatelessWidget {
  final _SortOrder current;
  final ValueChanged<_SortOrder> onSelected;

  const _SortSheet({required this.current, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                color: cs.onSurface.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const Text(
            'Sort by',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          ..._SortOrder.values.map((o) {
            final isSelected = o == current;
            return ListTile(
              onTap: () {
                onSelected(o);
                Navigator.of(context).pop();
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tileColor:
                  isSelected ? AppColors.primary.withValues(alpha: 0.08) : null,
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : cs.onSurface.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  o.icon,
                  size: 18,
                  color: isSelected
                      ? AppColors.primary
                      : cs.onSurface.withValues(alpha: 0.4),
                ),
              ),
              title: Text(
                o.label,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : cs.onSurface,
                  fontSize: 15,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_rounded,
                      color: AppColors.primary, size: 20)
                  : null,
            );
          }),
        ],
      ),
    );
  }
}

extension on _Filter {
  String get label {
    switch (this) {
      case _Filter.all:
        return 'All';
      case _Filter.active:
        return 'Active';
      case _Filter.completed:
        return 'Done';
    }
  }
}
