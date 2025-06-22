import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../data/models/task_model.dart';

class TaskFormPage extends StatefulWidget {
  final Task? task;
  const TaskFormPage({Key? key, this.task}) : super(key: key);

  @override
  State<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends State<TaskFormPage> {
  final _titleController = TextEditingController();
  DateTime? _dueDate;
  int _priority = 0;
  String? _selectedLabel;

  final List<String> labels = ['Home', 'Work', 'Food', 'Music'];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _selectedLabel = widget.task!.label;
      _dueDate = widget.task!.dueDate;
      _priority = widget.task!.priority;
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _save() {
    if (_titleController.text.trim().isEmpty || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter all details')),
      );
      return;
    }
    final newTask = Task(
      id: widget.task?.id,
      title: _titleController.text.trim(),
      label: _selectedLabel!,
      dueDate: _dueDate!,
      isDone: widget.task?.isDone ?? false,
      priority: _priority
    );

    print("${widget.task?.id} ===== ${_titleController.text.trim()} ==== ${_selectedLabel!} ====== ${ _dueDate!} ==== ${widget.task?.isDone}  === ${_priority}");

    if (widget.task == null) {
      context.read<TaskBloc>().add(AddTask(newTask));
    } else {
      context.read<TaskBloc>().add(UpdateTask(newTask));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        title: Text(widget.task == null ? 'Add Todo' : 'Edit Todo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'What needs to be done?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLabel,
              decoration: InputDecoration(
                labelText: 'Label',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              items: labels
                  .map((label) =>
                  DropdownMenuItem(value: label, child: Text(label)))
                  .toList(),
              onChanged: (newValue) => setState(() => _selectedLabel = newValue),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(
                _dueDate == null
                    ? 'Pick Due Date'
                    : DateFormat('EEE, d MMM yyyy').format(_dueDate!),
              ),
              leading: const Icon(Icons.calendar_today),
              trailing: const Icon(Icons.edit),
              tileColor: Colors.blue[50],
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Priority',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Slider(
                  activeColor:Colors.blue,
                  value: _priority.toDouble(),
                  min: 0,
                  max: 2,
                  divisions: 2,
                  label: _priority == 0 ? 'Low' : _priority == 1 ? 'Medium' : 'High',
                  onChanged: (newValue) {
                    setState(() => _priority = newValue.round());
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Low'),
                    Text('Medium'),
                    Text('High'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),
            SizedBox(

              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),

                ),
                onPressed: _save,
                child: const Text(
                  'Done',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600,color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
