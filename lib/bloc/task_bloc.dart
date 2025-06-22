import 'package:flutter_bloc/flutter_bloc.dart';
import 'task_event.dart';
import 'task_state.dart';
import '../../data/database/task_database.dart';
import '../../data/models/task_model.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskDatabase db;

  TaskBloc({required this.db}) : super(TaskLoading()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
    on<ToggleTaskStatus>(_onToggleTaskStatus);
  }

  Future<void> _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await db.getTasks();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError("Failed to load tasks"));
    }
  }

  Future<void> _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    print(event.task);
    await db.insertTask(event.task);
    add(LoadTasks());
  }

  Future<void> _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    await db.updateTask(event.task);
    add(LoadTasks());
  }

  Future<void> _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    await db.deleteTask(event.taskId);
    add(LoadTasks());
  }

  Future<void> _onToggleTaskStatus(ToggleTaskStatus event, Emitter<TaskState> emit) async {
    final updatedTask = event.task.copyWith(isDone: !event.task.isDone);
    await db.updateTask(updatedTask);
    add(LoadTasks());
  }
}
