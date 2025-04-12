# Assignment 2 of Mobile Programming

## Introduction

| Field | Information            |
| ----- | ---------------------- |
| Name  | Dimas Prihady Setyawan |
| NRP   | 5025211184             |
| Class | Mobile Programming C   |

## Description

A TodoList application built with Flutter that leverages **HiveDB** for local data persistence. The app implements an authentication system that allows multiple users to maintain separate, personalized todo lists securely on the same device.

## User and Task Model

### User Model

The User model contains required username, required password, and optional email. Each user has a unique username that serves as the primary identifier along with authentication credentials and optional contact information.

```dart
class User {
  final String username;
  final String password;
  final String? email;

  User({required this.username, required this.password, this.email});

  Map<String, dynamic> toMap() => {'password': password, 'email': email};

  static User fromMap(String username, Map<dynamic, dynamic> map) {
    return User(
      username: username,
      password: map['password'],
      email: map['email'],
    );
  }
}
```

#### Properties

1. `username`: A required string that uniquely identifies each user in the system
2. `password`: A required string containing the user's authentication credentials
3. `email`: An optional string field for user contact information

#### Methods

The User Model includes two methods:

1. `toMap()`: Converts the User object to a Map for storage in HiveDB

   - Note that the username is not included in the map because it will be used as the key in the Hive box

2. `fromMap()`: Static factory method that reconstructs a User object from stored data
   - Takes the username separately since it's used as the key in storage
   - Retrieves password and email from the provided map

### Task Model

The Task model represents individual todo items in the application. Each task contains information about the item, its completion status, and ownership details to ensure proper user association.

```dart
class Task {
  final String title;
  final String description;
  final bool completed;
  final String owner;
  final int id;

  Task({
    required this.title,
    required this.description,
    required this.completed,
    required this.owner,
    required this.id,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'completed': completed,
    'description': description,
    'owner': owner,
    'id': id,
  };

  static Task fromMap(Map<dynamic, dynamic> map) => Task(
    title: map['title'],
    description: map['description'],
    completed: map['completed'],
    owner: map['owner'],
    id: map['id'],
  );
}
```

#### Properties

1. `title`: A required string describing the task name
2. `description`: A required string providing additional details about the task
3. `completed`: A boolean flag indicating whether the task has been completed
4. `owner`: A required string representing the username of the task owner (links to User model)
5. `id`: A unique integer identifier for the task

#### Methods

The Task Model includes two methods:

1. `toMap()`: Converts a Task object to a Map where all properties are stored as key-value pairs
2. `fromMap()`: Static factory method that reconstructs a Task object from stored data

## Backend

The backend is organized into two primary components: Hive and Service layers

### Hive

---

**User Hive Service**

The `UserHiveService` class handles all direct interactions with HiveDB for user-related operations. It provides methods for storing, retrieving, and managing user data along with maintaining the current user session.

```dart
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

  //Save current username
  void saveCurrentUsername(String username) {
    _usersBox.put('currentUsername', username);
  }

  // Get current username
  String? getCurrentUsername() {
    return _usersBox.get('currentUsername') as String?;
  }
}
```

#### Key Components

#### Box Initialization

```dart
final Box _usersBox = Hive.box('usersBox');
```

- Accesses an already opened Hive box named 'usersBox' for user data storage

#### User Management Operations

#### Save User

```dart
void saveUser(User user) {
  _usersBox.put(user.username, user.toMap());
}
```

- Stores a user in the database using the username as the key
- Converts the User object to a map using the `toMap()` method before storage

#### Retrieve User

```dart
User? getUser(String username) {
  final data = _usersBox.get(username);
  return data != null ? User.fromMap(username, data) : null;
}
```

- Retrieves user data from the database by username
- Returns null if no user with the specified username exists
- Uses the static `fromMap()` method to reconstruct a User object from stored data

#### Check User Existence

```dart
bool userExists(String username) => _usersBox.containsKey(username);
```

- A utility method to check if a user with a given username already exists
- Returns a boolean indicating existence

### Session Management

#### Save Current User

```dart
void saveCurrentUsername(String username) {
  _usersBox.put('currentUsername', username);
}
```

- Stores the currently logged-in user's username

#### Get Current User

```dart
String? getCurrentUsername() {
  return _usersBox.get('currentUsername') as String?;
}
```

- Retrieves the username of the currently logged-in user
- Returns null if no user is currently logged in

---

**Task Hive Service**

The `TaskHiveService` class serves as the data access layer for task-related operations in the application. It encapsulates all direct interactions with the HiveDB database for task operations

```dart
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
```

#### Key Components

#### Box Initialization

```dart
final Box _tasksBox = Hive.box('tasksBox');
```

This line accesses an already opened Hive box named 'tasksBox'. This box is used to store all task data in the application.

#### CRUD Operations

#### Create

```dart
void addTask(Task task) => _tasksBox.add(task.toMap());
```

- Adds a new task to the box using auto-incrementing keys
- Converts the Task object to a map before storage using the `toMap()` method

#### Read

```dart
List<MapEntry<dynamic, Task>> getAllTasks() {
  return _tasksBox.toMap().entries.map((entry) {
    final taskMap = entry.value as Map;
    return MapEntry(entry.key, Task.fromMap(taskMap));
  }).toList();
}
```

- Retrieves all tasks from the box
- Converts each stored map back to a Task object using the static `fromMap()` method
- Returns a list of MapEntry objects containing both the key and the Task object

#### Update

```dart
void updateTask(int key, Task task) => _tasksBox.put(key, task.toMap());
```

- Updates an existing task at a specific key
- Converts the Task object to a map before storage

#### Delete

```dart
void deleteTask(int key) => _tasksBox.delete(key);
```

- Removes a task from the box at the specified key

#### User-Specific Task Filtering

```dart
List<MapEntry<dynamic, Task>> getTasksForUser(String username) {
  return getAllTasks()
      .where((entry) => entry.value.owner == username)
      .toList();
}
```

- Filters tasks to only return those belonging to a specific user
- Leverages the `owner` field in the Task model to establish the relationship
- Returns a list of MapEntry objects with both keys and Task objects

---

### Service

**User Service**

The `UserService` class implements the business logic for user management. It handles user authentication, registration, and session management while leveraging the UserHiveService for data persistence.

```dart
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
    final user = _userHiveService.getUser(username);

    if (user != null && user.password == password) {
      _currentUser = user;
      return true;
    }
    return false;
  }

  void logout() {
    _currentUser = null;

  }
}
```

### Singleton Pattern

```dart
static final UserService _instance = UserService._internal();
factory UserService() => _instance;
UserService._internal();
```

- Ensures only one instance of `UserService` exists throughout the application
- The factory constructor returns the same instance every time
- Private constructor prevents direct instantiation

#### Current User Access

```dart
User? _currentUser;

User? get currentUser {
  if (_currentUser == null) {
    _loadCurrentUser();
  }
  return _currentUser;
}
```

- Maintains the currently logged-in user in memory
- Lazy-loads the user from storage if not already loaded
- Returns null if no user is logged in

#### Loading Current User

```dart
void _loadCurrentUser() {
  final username = _userHiveService.getCurrentUsername();
  if (username != null && username.isNotEmpty) {
    _currentUser = _userHiveService.getUser(username);
  }
}
```

- Retrieves the current username from the storage service
- Loads the corresponding user object if a username exists

#### Authentication Operations

#### User Registration

```dart
bool register(String username, String password) {
  if (!_userHiveService.userExists(username)) {
    _userHiveService.saveUser(User(username: username, password: password));
    return true;
  }
  return false;
}
```

- Checks if the username is already taken
- Creates and stores a new user if the username is available
- Returns a boolean indicating success or failure

#### User Login

```dart
bool login(String username, String password) {
  final user = _userHiveService.getUser(username);

  if (user != null && user.password == password) {
    _currentUser = user;
    return true;
  }
  return false;
}
```

- Retrieves the user by username
- Verifies the password matches
- Sets the current user on successful authentication
- Returns a boolean indicating success or failure

#### User Logout

```dart
void logout() {
  _currentUser = null;
  // Clear current username from storage
  // _userHiveService.saveCurrentUsername('');
}
```

- Clears the current user from memory

---

**Task Service**

The `TaskService` class implements the business logic for task management.It handles task creation, retrieval, updates, and deletion while enforcing user ownership rules to ensure data isolation between users.

```dart
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
```

#### Key Components

#### Core Functions

#### Create Task

```dart
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
```

- Checks if a user is logged in before creating a task
- Generates a unique task ID using the current timestamp
- Automatically sets the owner to the current user
- Initializes the task as not completed
- Delegates storage to the TaskHiveService
- Returns a boolean indicating success or failure

#### Get Current User's Tasks

```dart
List<MapEntry<dynamic, Task>> getCurrentUserTasks() {
  if (_userService.currentUser == null) {
    return [];
  }

  return _taskHiveService.getTasksForUser(_userService.currentUser!.username);
}
```

- Returns an empty list if no user is logged in
- Uses the TaskHiveService to retrieve tasks filtered by the current user
- Returns both the Hive keys and Task objects for complete data access

#### Update Task

```dart
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
```

- Verifies a user is logged in
- Finds the task by its key
- Enforces ownership validation before allowing updates
- Creates a new Task instance with updated values while preserving the ID
- Delegates the update operation to the TaskHiveService
- Returns a boolean indicating success or failure

#### Delete Task

```dart
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
```

- Verifies a user is logged in
- Finds the task by its key
- Enforces ownership validation before allowing deletion
- Delegates the delete operation to the TaskHiveService
- Returns a boolean indicating success or failure

#### Get Single Task

```dart
Task? getTask(int taskKey) {
  final tasks = _taskHiveService.getAllTasks();
  try {
    final taskEntry = tasks.firstWhere((entry) => entry.key == taskKey);
    return taskEntry.value;
  } catch (e) {
    return null;
  }
}
```

- Retrieves a specific task by its key
- Uses try-catch to handle cases where the task doesn't exist
- Returns null if the task is not found

---

## Frontend

The frontend consists of main, register, login, and task_list_screen

**Main**

The `main.dart` file serves as the entry point for the application. It initializes Hive for local storage and sets up the application's routing system.

```dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/task/task_list_screen.dart';
import 'services/user_service.dart';

void main() async {
  //initilize Hive

  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // Open the box
  await Hive.openBox('usersBox');
  await Hive.openBox('tasksBox');
  await Hive.openBox('settingsBox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/tasks': (context) => const TaskListScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = UserService();

    if (userService.currentUser != null) {
      return const TaskListScreen();
    } else {
      return const LoginScreen();
    }
  }
}
```

#### Key Components

#### Hive Initialization

```dart
WidgetsFlutterBinding.ensureInitialized();
await Hive.initFlutter();

// Open the box
await Hive.openBox('usersBox');
await Hive.openBox('tasksBox');
```

- Ensures Flutter is initialized before async operations
- Initializes Hive for local storage
- Opens three Hive boxes for storing users, tasks, and application settings

#### Application Setup

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Task Manager',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/tasks': (context) => const TaskListScreen(),
      },
    );
  }
}
```

- Creates a MaterialApp with a blue theme and Material 3 design
- Disables the debug banner for a cleaner UI
- Sets up named routes for navigation between screens
- Uses an AuthWrapper as the initial route to handle authentication state

#### Authentication Wrapper

```dart
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = UserService();

    if (userService.currentUser != null) {
      return const TaskListScreen();
    } else {
      return const LoginScreen();
    }
  }
}
```

- Acts as a router based on authentication state
- Checks if a user is currently logged in
- Redirects to TaskListScreen if a user is logged in, otherwise to LoginScreen
- Provides a seamless user experience by maintaining login state between app sessions

---

**Login**

The `LoginScreen` provides the user interface for authentication. It allows existing users to log in to the application using their credentials.

```dart
import 'package:flutter/material.dart';
import '../../services/user_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _userService = UserService();
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final success = _userService.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (success) {
        debugPrint("Login: ${_userService.currentUser}");
        Navigator.of(context).pushReplacementNamed('/tasks');
      } else {
        setState(() => _errorMessage = ('Invalid username or password'));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Login'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/register');
                },
                child: const Text('Don\'t have an account? Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### Key Components

#### Form Management

```dart
final _formKey = GlobalKey<FormState>();
final _usernameController = TextEditingController();
final _passwordController = TextEditingController();
final _userService = UserService();
String? _errorMessage;
```

- Uses a form key to manage form validation
- Implements text controllers for username and password fields
- Maintains an error message state for displaying authentication failures

#### Authentication Logic

```dart
void _login() async {
  if (_formKey.currentState!.validate()) {
    final success = _userService.login(
      _usernameController.text,
      _passwordController.text,
    );

    if (success) {
      debugPrint("Login: ${_userService.currentUser}");
      Navigator.of(context).pushReplacementNamed('/tasks');
    } else {
      setState(() => _errorMessage = ('Invalid username or password'));
    }
  }
}
```

- Validates the form input before attempting login
- Calls the UserService to authenticate the user
- Navigates to the task list screen on successful login
- Displays an error message on failed authentication

#### User Interface

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Login')),
    body: Padding(
      padding: EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Form fields and buttons
          ],
        ),
      ),
    ),
  );
}
```

- Presents a clean, centered form with input validation
- Includes fields for username and password
- Displays error messages when authentication fails
- Provides a link to the registration screen for new users

---

#### Register Screen

The `RegisterScreen` allows new users to create accounts in the application. It collects user credentials and optional email information.

```dart
import 'package:flutter/material.dart';
// import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();
  // final _authService = AuthService();
  final _userService = UserService();
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final success = _userService.register(
        _usernameController.text,
        _passwordController.text,
        email: _emailController.text.isNotEmpty ? _emailController.text : null,
      );

      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Registration successful")));
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = "Username Already Exists";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email(Optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
              ),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                child: const Text('Register'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### Key Components

#### Form Management

```dart
final _formKey = GlobalKey<FormState>();
final _usernameController = TextEditingController();
final _passwordController = TextEditingController();
final _emailController = TextEditingController();
final _userService = UserService();
String? _errorMessage;
```

- Uses a form key to manage form validation
- Implements text controllers for username, password, and optional email fields
- Maintains an error message state for displaying registration failures

#### Registration Logic

```dart
void _register() async {
  if (_formKey.currentState!.validate()) {
    final success = _userService.register(
      _usernameController.text,
      _passwordController.text,
      email: _emailController.text.isNotEmpty ? _emailController.text : null,
    );

    if (success) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Registration successful")));
      Navigator.pop(context);
    } else {
      setState(() {
        _errorMessage = "Username Already Exists";
      });
    }
  }
}
```

- Validates the form input before attempting registration
- Calls the UserService to create a new user account
- Shows a success message and returns to the login screen on successful registration
- Displays an error message if the username is already taken

#### User Interface

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: const Text('Register')),
    body: Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Form fields and buttons
          ],
        ),
      ),
    ),
  );
}
```

- Presents a clean, centered form with input validation
- Includes fields for email (optional), username, and password
- Enforces password strength requirements
- Displays error messages when registration fails
- Provides a link back to the login screen for existing users

---

**Task List Screen**

The `TaskListScreen` is the main interface for viewing, creating, updating, and deleting tasks. It displays the current user's tasks and provides functionality for task management.

```dart
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
 // omitted because it's too long
}
```

#### Key Components

#### State Management

```dart
final TaskService _taskService = TaskService();
final UserService _userService = UserService();
List<MapEntry<dynamic, Task>> _tasks = [];

final _titleController = TextEditingController();
final _descriptionController = TextEditingController();
```

- Maintains a list of tasks with their Hive keys
- Uses text controllers for task title and description input
- Leverages TaskService and UserService for data operations

#### Task Loading

```dart
@override
void initState() {
  super.initState();
  debugPrint("Current user: ${_userService.currentUser?.username}");
  _loadTasks();
}

void _loadTasks() {
  setState(() {
    _tasks = _taskService.getCurrentUserTasks();
  });
}
```

- Loads tasks when the screen initializes
- Updates the UI when tasks change
- Filters tasks to show only those belonging to the current user

**Task Operations**

**Add Task**

```dart
void _showAddTaskDialog() {
  _titleController.clear();
  _descriptionController.clear();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Add Task'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            // Form fields
          ],
        ),
      ),
      actions: [
        // Cancel and Add buttons
      ],
    ),
  );
}
```

- Displays a dialog for creating new tasks
- Clears input fields when opened
- Validates that title and description are not empty
- Shows success or failure messages
- Refreshes the task list after adding a task

**Edit Task**

```dart
void _showEditTaskDialog(int taskKey, Task task) {
  _titleController.text = task.title;
  _descriptionController.text = task.description;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Form fields pre-filled with task data
          ],
        ),
      ),
      actions: [
        // Cancel and Update buttons
      ],
    ),
  );
}
```

- Displays a dialog for editing existing tasks
- Pre-fills input fields with current task data
- Validates that title and description are not empty
- Shows success or failure messages
- Refreshes the task list after updating a task

**Toggle Task Completion**

```dart
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
```

- Toggles the completion status of a task
- Preserves the task title and description
- Updates the UI to reflect the new status

**Delete Task**

```dart
void _deleteTask(int taskKey) {
  _taskService.deleteTask(taskKey);
}
```

- Removes a task from storage
- Implemented with swipe-to-delete gesture in the UI

**User Interface**

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('${_userService.currentUser?.username}'),
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
    body: _tasks.isEmpty
        ? Center(child: Text("No Tasks Yet. Add your first task"))
        : ListView.builder(
            // Task list implementation
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: _showAddTaskDialog,
      child: const Icon(Icons.add),
    ),
  );
}
```

- Displays the current user's username in the app bar
- Provides a logout button in the app bar
- Shows a message when no tasks exist
- Renders tasks in a scrollable list
- Implements swipe-to-delete functionality for tasks
- Includes checkboxes for toggling task completion
- Provides edit buttons for modifying tasks
- Features a floating action button for adding new tasks
