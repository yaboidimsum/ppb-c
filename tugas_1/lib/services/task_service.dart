import 'package:tugas_1/models/task.dart';

class TaskService {
  // In-memory list of tasks
  final List<Task> _tasks = [];

  // Get all tasks
  List<Task> getAllTasks() {
    return List.unmodifiable(_tasks);
  }

  // Add a new task
  void addTask(Task task) {
    _tasks.add(task);
  }

  // Delete a task by id
  void deleteTask(String id) {
    _tasks.removeWhere((task) => task.id == id);
  }

  // Toggle task completion status
  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
    }
  }

  // Update an existing task
  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
    }
  }

  // Add some sample tasks for testing
  void addSampleTasks() {
    _tasks.add(
      Task(
        title: 'Complete Flutter Assignment',
        description: 'Finish the task management app',
        createdAt: DateTime.now(),
      ),
    );
    // _tasks.add(
    //   Task(
    //     title: 'Study for Exam',
    //     description: 'Review chapters 1-5',
    //     createdAt: DateTime.now(),
    //   ),
    // );
  }
}