import 'package:hive_flutter/hive_flutter.dart';
import '../../models/user_model.dart';

class UserHiveService {
  final Box _usersBox = Hive.box('usersBox');
  // final Box _settingsBox = Hive.box('settingsBox');

  void saveUser(User user) {
    _usersBox.put(user.username, user.toMap());
  }

  User? getUser(String username) {
    final data = _usersBox.get(username);
    return data != null ? User.fromMap(username, data) : null;
  }

  bool userExists(String username) => _usersBox.containsKey(username);

  //Save current username
  void saveCurrentUsername(String username) {
    _usersBox.put('currentUsername', username); // Use settings box
  }

  // Get current username
  String? getCurrentUsername() {
    return _usersBox.get('currentUsername') as String?; // Use settings box
  }
}
