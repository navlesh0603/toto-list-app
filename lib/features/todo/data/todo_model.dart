enum TodoPriority { high, medium, low, none }

extension TodoPriorityX on TodoPriority {
  String get label {
    switch (this) {
      case TodoPriority.high:
        return 'High';
      case TodoPriority.medium:
        return 'Medium';
      case TodoPriority.low:
        return 'Low';
      case TodoPriority.none:
        return 'None';
    }
  }

  String get toJson => name;

  static TodoPriority fromJson(String? value) {
    switch (value) {
      case 'high':
        return TodoPriority.high;
      case 'medium':
        return TodoPriority.medium;
      case 'low':
        return TodoPriority.low;
      default:
        return TodoPriority.none;
    }
  }

  int get sortOrder {
    switch (this) {
      case TodoPriority.high:
        return 0;
      case TodoPriority.medium:
        return 1;
      case TodoPriority.low:
        return 2;
      case TodoPriority.none:
        return 3;
    }
  }
}

class TodoModel {
  final String id;
  final String title;
  final String description;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? dueDate;
  final TodoPriority priority;

  const TodoModel({
    required this.id,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    required this.createdAt,
    this.dueDate,
    this.priority = TodoPriority.none,
  });

  factory TodoModel.fromJson(String id, Map<String, dynamic> json) {
    return TodoModel(
      id: id,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      isCompleted: json['isCompleted'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      dueDate: json['dueDate'] != null
          ? DateTime.tryParse(json['dueDate'] as String)
          : null,
      priority: TodoPriorityX.fromJson(json['priority'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.toJson,
    };
  }

  bool get isOverdue {
    if (isCompleted || dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isDueTomorrow {
    if (dueDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate!.year == tomorrow.year &&
        dueDate!.month == tomorrow.month &&
        dueDate!.day == tomorrow.day;
  }

  TodoModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    bool clearDueDate = false,
    TodoPriority? priority,
  }) {
    return TodoModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      priority: priority ?? this.priority,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TodoModel &&
        id == other.id &&
        title == other.title &&
        description == other.description &&
        isCompleted == other.isCompleted &&
        priority == other.priority &&
        createdAt == other.createdAt &&
        dueDate == other.dueDate;
  }

  @override
  int get hashCode => Object.hash(
        id,
        title,
        description,
        isCompleted,
        priority,
        createdAt,
        dueDate,
      );
}
