import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user_model.dart';

class UserHiveService {
  final Box _usersBox = Hive.box('usersBox');

  void saveUser(User user) {
    _usersBox.put(user.username, user.toMap());
  }

  User? getUser(String username) {
    final data = _usersBox.get(username);
    return data != null ? User.fromMap(username, data) : null;
  }

  bool userExists(String username) => _usersBox.containsKey(username);
}
