import '../models/task_model.dart';
import 'hive/task_hive_service.dart';
import 'user_service.dart';

class TaskService {
  final TaskHiveService _taskHiveService = TaskHiveService();
  final UserService _userService = UserService();

  bool createTask(String title, String description) {
    if (_userService.currentUser == null) {
      return false;
    }

    final task = Task(
      title: title,
      description: description,
      completed: false,
      owner: _userService.currentUser!.username,
      id: DateTime.now().millisecondsSinceEpoch,
    );

    _taskHiveService.addTask(task);
    return true;
  }

  List<MapEntry<dynamic, Task>> getCurrentUserTasks() {
    if (_userService.currentUser == null) {
      return [];
    }

    return _taskHiveService.getTasksForUser(_userService.currentUser!.username);
  }

  bool updateTask(
    int taskKey,
    String title,
    String description,
    bool completed,
  ) {
    if (_userService.currentUser == null) {
      return false;
    }

    final tasks = _taskHiveService.getAllTasks();

    final taskEntry = tasks.firstWhere(
      (entry) => entry.key == taskKey,
      orElse:
          () => MapEntry(
            -1,
            Task(
              title: '',
              description: '',
              completed: false,
              owner: '',
              id: -1,
            ),
          ),
    );

    if (taskEntry.key == -1 ||
        taskEntry.value.owner != _userService.currentUser!.username) {
      return false;
    }

    final updatedTask = Task(
      title: title,
      description: description,
      completed: completed,
      owner: _userService.currentUser!.username,
      id: taskEntry.value.id,
    );

    _taskHiveService.updateTask(taskKey, updatedTask);
    return true;
  }

  bool deleteTask(int taskKey) {
    if (_userService.currentUser == null) {
      return false;
    }

    final tasks = _taskHiveService.getAllTasks();
    final taskEntry = tasks.firstWhere(
      (entry) => entry.key == taskKey,
      orElse:
          () => MapEntry(
            -1,
            Task(
              title: '',
              description: '',
              completed: false,
              owner: '',
              id: -1,
            ),
          ),
    );

    if (taskEntry.key == -1 ||
        taskEntry.value.owner != _userService.currentUser!.username) {
      return false;
    }

    _taskHiveService.deleteTask(taskKey);
    return true;
  }

  Task? getTask(int taskKey) {
    final tasks = _taskHiveService.getAllTasks();
    try {
      final taskEntry = tasks.firstWhere((entry) => entry.key == taskKey);
      return taskEntry.value;
    } catch (e) {
      return null;
    }
  }
}
