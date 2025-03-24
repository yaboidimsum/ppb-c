class Task {
  String id; // Unique identifier for the task
  String title;
  String description;
  bool isCompleted;
  DateTime createdAt;

  Task({
    String? id, // Make id optional in constructor
    required this.title,
    required this.description,
    this.isCompleted = false,
    required this.createdAt,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(); // Generate unique ID if not provided

  // Add copyWith method to create a new instance with updated fields
  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}