import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:tugas_1/components/task_list_item.dart';
import 'package:tugas_1/components/task_form.dart';
import 'package:tugas_1/services/task_service.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService _taskService = TaskService();

  @override
  void initState() {
    super.initState();
    _taskService.addSampleTasks();
  }

  void _showAddTaskDialog() {
    shadcn.showDialog(
      context: context,
      builder: (context) {
        return TaskForm(
          title: 'Add New Task',
          submitButtonText: 'Add Task',
          onSubmit: (task) {
            setState(() {
              _taskService.addTask(task);
            });
            Navigator.pop(context);
          },
          onCancel: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _taskService.getAllTasks();

    return Scaffold(
      appBar: AppBar(title: const Text('Task Manager')),
      body:
          tasks.isEmpty
              ? const Center(child: Text('No tasks yet. Add some!'))
              : Container(
                margin: const EdgeInsets.fromLTRB(16, 64, 16, 16),
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskListItem(
                      task: task,
                      onDelete: () {
                        setState(() {
                          _taskService.deleteTask(task.id);
                        });
                      },
                      onToggle: () {
                        setState(() {
                          _taskService.toggleTaskCompletion(task.id);
                        });
                      },
                      onEdit: (updatedTask) {
                        setState(() {
                          _taskService.updateTask(updatedTask);
                        });
                      },
                    );
                  },
                ),
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        child: const Icon(Icons.add),
      ),
    );
  }
}
