import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final int? id;
  final String title;
  final String label;
  final DateTime dueDate;
  final bool isDone;
  final int priority;


  const Task({
    this.id,
    required this.title,
    required this.label,
    required this.dueDate,
    this.isDone = false,
    this.priority = 0,
  });

  // Convert Task to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'label': label,
      'dueDate': dueDate.toIso8601String(),
      'isDone': isDone ? 1 : 0,
      'priority': priority,
    };
  }

  // Create Task from Map from SQLite
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      label: map['label'],
      dueDate: DateTime.parse(map['dueDate']),
      isDone: map['isDone'] == 1,
      priority: map['priority'],
    );
  }

  @override
  List<Object?> get props => [id, title, label, dueDate, isDone];

  // For copying task with changes (useful in BLoC)
  Task copyWith({
    int? id,
    String? title,
    String? label,
    DateTime? dueDate,
    bool? isDone,
    int? priority,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      label: label ?? this.label,
      dueDate: dueDate ?? this.dueDate,
      isDone: isDone ?? this.isDone,
      priority: priority ?? this.priority,
    );
  }
}

