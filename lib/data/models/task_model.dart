import 'package:equatable/equatable.dart';

class Task extends Equatable {
  final int? id;
  final String title;
  final String description;
  final DateTime dueDate;
  final bool isDone;

  const Task({
    this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isDone = false,
  });

  // Convert Task to Map for SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'isDone': isDone ? 1 : 0,
    };
  }

  // Create Task from Map from SQLite
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      dueDate: DateTime.parse(map['dueDate']),
      isDone: map['isDone'] == 1,
    );
  }

  @override
  List<Object?> get props => [id, title, description, dueDate, isDone];

  // For copying task with changes (useful in BLoC)
  Task copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? dueDate,
    bool? isDone,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isDone: isDone ?? this.isDone,
    );
  }
}

