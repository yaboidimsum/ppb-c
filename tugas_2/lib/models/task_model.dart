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
