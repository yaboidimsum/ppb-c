import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:tugas_3/model/task_model.dart'; // Corrected import path for Task model
import 'package:tugas_3/screens/login_screen.dart';
import 'package:tugas_3/screens/add_task_screen.dart';
import 'package:tugas_3/screens/edit_task_screen.dart';
import 'package:tugas_3/services/notification_service.dart'; // Import NotificationService

class TaskListScreen extends StatefulWidget {
  // Convert to StatefulWidget
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      // Navigate back to LoginScreen and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // print("Error signing out: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }

  Future<void> _deleteTask(String taskId, String taskName) async {
    try {
      // Cancel notifications before deleting from Firestore
      // await NotificationService.cancelTaskNotifications(taskId);
      await NotificationService.triggerTaskDeletedNotification(
        taskId,
        taskName,
      );
      await _firestore.collection('tasks').doc(taskId).delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted successfully')),
        );
      }
    } catch (e) {
      // print("Error deleting task: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error deleting task: $e')));
      }
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.name}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(ctx).pop(); // Close the dialog
                _deleteTask(task.id!, task.name); // Call delete task
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _signOut(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body:
          currentUser == null
              ? const Center(
                child: Text(
                  "No user logged in.",
                ), // Should not happen if routed correctly
              )
              : StreamBuilder<QuerySnapshot<Task>>(
                // Expect QuerySnapshot<Task>
                stream:
                    _firestore
                        .collection('tasks')
                        .where('userId', isEqualTo: currentUser.uid)
                        .orderBy('deadline', descending: false)
                        .withConverter<Task>(
                          // Use the converter
                          fromFirestore: Task.fromFirestore,
                          toFirestore: (Task task, _) => task.toFirestore(),
                        )
                        .snapshots(), // No need for casting here, it's already Stream<QuerySnapshot<Task>>
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    // print("Error fetching tasks: ${snapshot.error}");
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No tasks found. Add one!'),
                    );
                  }

                  // snapshot.data!.docs is now List<QueryDocumentSnapshot<Task>>
                  // Each doc.data() will return a Task object directly
                  final tasks =
                      snapshot.data!.docs.map((doc) => doc.data()).toList();

                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        child: ListTile(
                          title: Text(task.name),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.description),
                              const SizedBox(height: 4),
                              Text(
                                'Deadline: ${MaterialLocalizations.of(context).formatShortDate(task.deadline)} ${TimeOfDay.fromDateTime(task.deadline).format(context)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          isThreeLine: true,
                          onTap: () {
                            // Make the whole tile tappable for editing
                            if (task.id != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => EditTaskScreen(task: task),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Error: Task data incomplete for editing.',
                                  ),
                                ),
                              );
                            }
                          },
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                // Optional: Keep an explicit edit icon too
                                icon: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).primaryColor,
                                ),
                                tooltip: 'Edit Task',
                                onPressed: () {
                                  if (task.id != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) =>
                                                EditTaskScreen(task: task),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Error: Task data incomplete for editing.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                tooltip: 'Delete Task',
                                onPressed: () {
                                  if (task.id != null) {
                                    _showDeleteConfirmationDialog(
                                      context,
                                      task,
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Error: Task ID is missing.',
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}
