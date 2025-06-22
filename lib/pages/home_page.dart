import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../bloc/task_state.dart';
import '../data/models/task_model.dart';
import 'task_form_page.dart';

enum Filter { all, completed, pending }

class HomePage extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const HomePage({Key? key, required this.onToggleTheme}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Filter _selectedFilter = Filter.all;

  List<Task> _applyFilter(List<Task> tasks) {
    switch (_selectedFilter) {
      case Filter.completed:
        return tasks.where((t) => t.isDone).toList();
      case Filter.pending:
        return tasks.where((t) => !t.isDone).toList();
      case Filter.all:
      default:
        return tasks;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Lottie.asset(
            'assets/Animation_2.json',
            width: 200,
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 10),
          const Text(
            'Todos you add will appear here',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    Color priorityColor;
    String priorityLabel;
    switch (task.priority) {
      case 2:
        priorityColor = Colors.red;
        priorityLabel = 'High';
        break;
      case 1:
        priorityColor = Colors.orange;
        priorityLabel = 'Medium';
        break;
      default:
        priorityColor = Colors.green;
        priorityLabel = 'Low';
        break;
    }

    return Dismissible(
      key: Key(task.id!.toString()),
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      secondaryBackground: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        context.read<TaskBloc>().add(DeleteTask(task.id!));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted "${task.title}"')),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: ListTile(
          title: Text(
            task.title,
            style: TextStyle(
              decoration: task.isDone ? TextDecoration.lineThrough : null,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              if (task.label.isNotEmpty)
                Text(
                  task.label,
                  style: const TextStyle(fontSize: 12),
                ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      priorityLabel,
                      style: TextStyle(fontSize: 12, color: priorityColor),
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Checkbox(
            side: const BorderSide(width: 1.5),
            value: task.isDone,
            onChanged: (_) => context.read<TaskBloc>().add(ToggleTaskStatus(task)),
          ),
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TaskFormPage(task: task),
              ),
            );
            context.read<TaskBloc>().add(LoadTasks());
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Todos',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            tooltip: 'Toggle Theme',
            onPressed: widget.onToggleTheme,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: DropdownButton<Filter>(
              value: _selectedFilter,
              underline: const SizedBox(),
              icon: const Icon(Icons.filter_list),
              onChanged: (newValue) => setState(() => _selectedFilter = newValue!),
              items: [
                DropdownMenuItem(
                  value: Filter.all,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: const Text('All Task'),
                  ),
                ),
                DropdownMenuItem(
                  value: Filter.completed,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: const Text('Completed'),
                  ),
                ),
                DropdownMenuItem(
                  value: Filter.pending,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: const Text('Pending'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const TaskFormPage()),
          );
          context.read<TaskBloc>().add(LoadTasks());
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is TaskLoaded) {
            final filteredTasks = _applyFilter(state.tasks);
            return filteredTasks.isEmpty
                ? _buildEmptyState()
                : Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView(
                          children: filteredTasks
                    .map((task) => _buildTaskCard(context, task))
                    .toList(),
                  ),
                );
          } else if (state is TaskError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
