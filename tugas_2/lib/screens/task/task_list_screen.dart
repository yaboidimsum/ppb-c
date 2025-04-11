import 'package:flutter/material.dart';
import '../../models/task_model.dart';
import '../../services/task_service.dart';
import '../../services/user_service.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskService _taskService = TaskService();
  final UserService _userService = UserService();
  List<MapEntry<dynamic, Task>> _tasks = [];

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    debugPrint("Current user: ${_userService.currentUser?.username}");

    _loadTasks();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadTasks() {
    setState(() {
      _tasks = _taskService.getCurrentUserTasks();
    });
  }

  void _showAddTaskDialog() {
    _titleController.clear();
    _descriptionController.clear();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Task'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty &&
                      _descriptionController.text.isNotEmpty) {
                    final success = _taskService.createTask(
                      _titleController.text,
                      _descriptionController.text,
                    );

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task created successfully'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to create task')),
                      );
                    }

                    Navigator.of(context).pop();
                    _loadTasks();
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _toggleTaskCompletion(int taskKey) {
    final task = _taskService.getTask(taskKey);

    if (task != null) {
      _taskService.updateTask(
        taskKey,
        task.title,
        task.description,
        !task.completed,
      );
      _loadTasks();
    }
  }

  void _deleteTask(int taskKey) {
    _taskService.deleteTask(taskKey);
  }

  void _showEditTaskDialog(int taskKey, Task task) {
    _titleController.text = task.title;
    _descriptionController.text = task.description;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Edit Task'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (_titleController.text.isNotEmpty &&
                      _descriptionController.text.isNotEmpty) {
                    final success = _taskService.updateTask(
                      taskKey,
                      _titleController.text,
                      _descriptionController.text,
                      task.completed,
                    );

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Task updated successfully'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to update task')),
                      );
                    }

                    Navigator.of(context).pop();
                    _loadTasks();
                  }
                },
                child: const Text('Update'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          // 'Tasks for ${_userService.currentUser?.username ?? "User"}',
          '${_userService.currentUser?.username}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _userService.logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            tooltip: 'Logout',
          ),
        ],
      ),
      body:
          _tasks.isEmpty
              ? Center(child: Text("No Tasks Yet. Add your first task"))
              : ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  final task = _tasks[index].value;
                  final taskKey = _tasks[index].key;

                  return Dismissible(
                    key: Key(taskKey.toString()),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _deleteTask(taskKey);
                    },
                    child: ListTile(
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration:
                              task.completed
                                  ? TextDecoration.lineThrough
                                  : null,
                        ),
                      ),
                      subtitle: Text(task.description),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditTaskDialog(taskKey, task),
                            tooltip: 'Edit Task',
                          ),
                          Checkbox(
                            value: task.completed,
                            onChanged: (value) {
                              _toggleTaskCompletion(taskKey);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
