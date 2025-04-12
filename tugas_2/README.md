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
