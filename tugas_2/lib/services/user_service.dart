import '../models/user_model.dart';
import 'hive/user_hive_service.dart';

class UserService {
  final UserHiveService _userHiveService = UserHiveService();

  // Current logged in User
  User? _currentUser;

  // Getter for current user
  User? get currentUser => _currentUser;

  //Register a new user
  bool register(String username, String password) {
    if (!_userHiveService.userExists(username)) {
      _userHiveService.saveUser(User(username: username, password: password));
      return true;
    }
    return false;
  }

  bool login(String username, String password) {
    final user = _userHiveService.getUser(username);

    if (user != null &&
        user.username == username &&
        user.password == password) {
      _currentUser = user;
      return true;
    }
    return false;
  }

  void logout(){
    _currentUser = null;
  }
}
