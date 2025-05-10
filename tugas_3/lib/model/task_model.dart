import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String? id; // Document ID from Firestore
  final String name;
  final String description;
  final DateTime deadline;
  final String userId;

  Task({
    this.id,
    required this.name,
    required this.description,
    required this.deadline,
    required this.userId,
  });

  // Factory constructor to create a Task from a Firestore document
  factory Task.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Task(
      id: snapshot.id,
      name: data?['name'] ?? '',
      description: data?['description'] ?? '',
      deadline: (data?['deadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data?['userId'] ?? '',
    );
  }

  // Method to convert a Task instance to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'deadline': Timestamp.fromDate(deadline),
      'userId': userId,
    };
  }
}
