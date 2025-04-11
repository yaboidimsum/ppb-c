import '../models/user_model.dart';
import 'hive/user_hive_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;

  UserService._internal();

  final UserHiveService _userHiveService = UserHiveService();

  // Current logged in User
  User? _currentUser;

  // Getter for current user
  User? get currentUser {
    // Try to load current user if it's null
    if (_currentUser == null) {
      _loadCurrentUser();
    }
    return _currentUser;
  }

  // Load current user from storage
  void _loadCurrentUser() {
    final username = _userHiveService.getCurrentUsername();
    if (username != null && username.isNotEmpty) {
      _currentUser = _userHiveService.getUser(username);
    }
  }

  //Register a new user
  bool register(String username, String password) {
    if (!_userHiveService.userExists(username)) {
      _userHiveService.saveUser(User(username: username, password: password));
      return true;
    }
    return false;
  }

  bool login(String username, String password) {
    // debugPrint("Login attempt: $username");
    final user = _userHiveService.getUser(username);

    if (user != null && user.password == password) {
      _currentUser = user;
      // _userHiveService.saveCurrentUsername(username);
      // debugPrint("Login successful, current user: ${_currentUser?.username}");
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    // Clear current username from storage
    // _userHiveService.saveCurrentUsername('');
  }
}
