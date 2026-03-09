import 'dart:collection';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/todo_model.dart';
import '../data/todo_repository.dart';

abstract class TodoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTodos extends TodoEvent {}

class AddTodo extends TodoEvent {
  final String title;
  final String description;
  final DateTime? dueDate;
  final TodoPriority priority;

  AddTodo({
    required this.title,
    this.description = '',
    this.dueDate,
    this.priority = TodoPriority.none,
  });

  @override
  List<Object?> get props => [title, description, dueDate, priority];
}

class UpdateTodo extends TodoEvent {
  final TodoModel todo;

  UpdateTodo({required this.todo});

  @override
  List<Object?> get props => [todo];
}

class DeleteTodo extends TodoEvent {
  final String todoId;

  DeleteTodo({required this.todoId});

  @override
  List<Object?> get props => [todoId];
}

class ToggleTodo extends TodoEvent {
  final TodoModel todo;

  ToggleTodo({required this.todo});

  @override
  List<Object?> get props => [todo];
}

abstract class TodoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class TodoInitial extends TodoState {}

class TodoLoading extends TodoState {}

class TodoLoaded extends TodoState {
  final List<TodoModel> todos;

  TodoLoaded({required List<TodoModel> todos})
      : todos = UnmodifiableListView(todos);

  @override
  List<Object?> get props => [todos];
}

class TodoError extends TodoState {
  final String message;
  final List<TodoModel> previousTodos;

  TodoError({required this.message, List<TodoModel> previousTodos = const []})
      : previousTodos = UnmodifiableListView(previousTodos);

  @override
  List<Object?> get props => [message, previousTodos];
}

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final TodoRepository todoRepository;

  TodoBloc({required this.todoRepository}) : super(TodoInitial()) {
    on<LoadTodos>(_onLoadTodos);
    on<AddTodo>(_onAddTodo);
    on<UpdateTodo>(_onUpdateTodo);
    on<DeleteTodo>(_onDeleteTodo);
    on<ToggleTodo>(_onToggleTodo);
  }

  List<TodoModel> get _currentTodos {
    final s = state;
    if (s is TodoLoaded) return List<TodoModel>.from(s.todos);
    if (s is TodoError) return List<TodoModel>.from(s.previousTodos);
    return <TodoModel>[];
  }

  Future<void> _onLoadTodos(
    LoadTodos event,
    Emitter<TodoState> emit,
  ) async {
    emit(TodoLoading());
    try {
      final todos = await todoRepository.fetchTodos();
      emit(TodoLoaded(todos: todos));
    } catch (e) {
      emit(TodoError(message: _clean(e)));
    }
  }

  Future<void> _onAddTodo(
    AddTodo event,
    Emitter<TodoState> emit,
  ) async {
    final snapshot = _currentTodos;
    try {
      final newTodo = await todoRepository.addTodo(
        title: event.title,
        description: event.description,
        dueDate: event.dueDate,
        priority: event.priority,
      );
      emit(TodoLoaded(todos: [newTodo, ...snapshot]));
    } catch (e) {
      emit(TodoError(message: _clean(e), previousTodos: snapshot));
    }
  }

  Future<void> _onUpdateTodo(
    UpdateTodo event,
    Emitter<TodoState> emit,
  ) async {
    final snapshot = _currentTodos;

    final optimistic =
        snapshot.map((t) => t.id == event.todo.id ? event.todo : t).toList();
    emit(TodoLoaded(todos: optimistic));
    try {
      await todoRepository.updateTodo(event.todo);
    } catch (e) {
      emit(TodoLoaded(todos: snapshot));
      emit(TodoError(message: _clean(e), previousTodos: snapshot));
    }
  }

  Future<void> _onDeleteTodo(
    DeleteTodo event,
    Emitter<TodoState> emit,
  ) async {
    final snapshot = _currentTodos;

    final optimistic = snapshot.where((t) => t.id != event.todoId).toList();
    emit(TodoLoaded(todos: optimistic));
    try {
      await todoRepository.deleteTodo(event.todoId);
    } catch (e) {
      emit(TodoLoaded(todos: snapshot));
      emit(TodoError(message: _clean(e), previousTodos: snapshot));
    }
  }

  Future<void> _onToggleTodo(
    ToggleTodo event,
    Emitter<TodoState> emit,
  ) async {
    final snapshot = _currentTodos;
    final toggled = event.todo.copyWith(isCompleted: !event.todo.isCompleted);

    final optimistic =
        snapshot.map((t) => t.id == event.todo.id ? toggled : t).toList();
    emit(TodoLoaded(todos: optimistic));
    try {
      await todoRepository.updateTodo(toggled);
    } catch (e) {
      emit(TodoLoaded(todos: snapshot));
      emit(TodoError(message: _clean(e), previousTodos: snapshot));
    }
  }

  String _clean(Object e) {
    final msg = e.toString();

    if (msg.startsWith('Exception: ')) {
      return msg.substring('Exception: '.length);
    }
    return msg;
  }
}
