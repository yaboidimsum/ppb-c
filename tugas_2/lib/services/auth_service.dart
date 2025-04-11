import '../models/user_model.dart';
import 'hive/user_hive_service.dart';

class AuthService {
  final UserHiveService _userHiveService = UserHiveService();

  User? _currentUser;
  bool get isAuthenticated => _currentUser != null;

  User? get currentUser => _currentUser;

  // Register a new user
  bool register(String username, String password, {String? email}) {
    if (_userHiveService.userExists(username)) {
      return false;
    }

    final user = User(username: username, password: password, email: email);

    _userHiveService.saveUser(user);

    return true;
  }

  bool login(String username, String password) {
    final user = _userHiveService.getUser(username);

    if (user != null && user.password == password) {
      _currentUser = user;

      // Save the username to persistent storage
      _userHiveService.saveCurrentUsername(username);
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;
    _userHiveService.saveCurrentUsername('');
  }

  bool isUsernameAvailable(String username) {
    return !_userHiveService.userExists(username);
  }
}
