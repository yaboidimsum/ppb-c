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
}
