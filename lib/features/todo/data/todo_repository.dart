import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/data/auth_repository.dart';
import 'todo_model.dart';

class TodoRepository {
  final AuthRepository _authRepository;
  late final Dio _dio;

  TodoRepository({required AuthRepository authRepository})
      : _authRepository = authRepository {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.firebaseDbUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  String get _uid => _authRepository.getCurrentUser()!.uid;

  Future<Map<String, String>> _authParams() async {
    final token = await _authRepository.getIdToken();
    if (token == null) {
      throw Exception('Session expired. Please sign in again.');
    }
    return {'auth': token};
  }

  Exception _handleDioError(DioException e) {
    final status = e.response?.statusCode;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return Exception('Connection timed out. Check your internet connection.');
    }
    if (e.type == DioExceptionType.connectionError) {
      return Exception('No internet connection.');
    }
    switch (status) {
      case 400:
        return Exception('Bad request. Check the data being sent.');
      case 401:
        return Exception('Unauthorised. Please sign in again.');
      case 403:
        return Exception(
          'Access denied. Update your Firebase Realtime Database rules to allow read/write.',
        );
      case 404:
        return Exception(
          'Firebase Realtime Database not found.\n'
          'Go to Firebase Console → Build → Realtime Database → Create Database, '
          'then update the URL in app_constants.dart.',
        );
      default:
        return Exception('Something went wrong (HTTP $status). Try again.');
    }
  }

  Future<List<TodoModel>> fetchTodos() async {
    final params = await _authParams();
    try {
      final response = await _dio.get(
        '/users/$_uid/todos.json',
        queryParameters: params,
      );

      if (response.data == null) return [];

      final rawData = Map<String, dynamic>.from(response.data as Map);
      final todos = rawData.entries
          .map((e) => TodoModel.fromJson(
                e.key,
                Map<String, dynamic>.from(e.value as Map),
              ))
          .toList();

      todos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return todos;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return [];
      throw _handleDioError(e);
    }
  }

  Future<TodoModel> addTodo({
    required String title,
    String description = '',
    DateTime? dueDate,
    TodoPriority priority = TodoPriority.none,
  }) async {
    final params = await _authParams();
    final todo = TodoModel(
      id: '',
      title: title,
      description: description,
      isCompleted: false,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      priority: priority,
    );

    try {
      final response = await _dio.post(
        '/users/$_uid/todos.json',
        queryParameters: params,
        data: todo.toJson(),
      );
      final generatedId = response.data['name'] as String;
      return todo.copyWith(id: generatedId);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> updateTodo(TodoModel todo) async {
    final params = await _authParams();
    try {
      await _dio.patch(
        '/users/$_uid/todos/${todo.id}.json',
        queryParameters: params,
        data: todo.toJson(),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteTodo(String todoId) async {
    final params = await _authParams();
    try {
      await _dio.delete(
        '/users/$_uid/todos/$todoId.json',
        queryParameters: params,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }
}
