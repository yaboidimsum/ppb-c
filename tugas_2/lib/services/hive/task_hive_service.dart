import 'package:hive_flutter/hive_flutter.dart';
import '../../models/task_model.dart';

class TaskHiveService {
  final Box _tasksBox = Hive.box('tasksBox');

  void addTask(Task task) => _tasksBox.add(task.toMap());
  void updateTask(int key, Task task) => _tasksBox.put(key, task.toMap());

  // Get all tasks (as List of Task with keys)
  List<MapEntry<dynamic, Task>> getAllTasks() {
    return _tasksBox.toMap().entries.map((entry) {
      final taskMap = entry.value as Map;
      return MapEntry(entry.key, Task.fromMap(taskMap));
    }).toList();
  }

  // Get tasks by owner (e.g. for logged-in user)
  List<MapEntry<dynamic, Task>> getTasksForUser(String username) {
    return getAllTasks()
        .where((entry) => entry.value.owner == username)
        .toList();
  }

  void deleteTask(int key) => _tasksBox.delete(key);
}
