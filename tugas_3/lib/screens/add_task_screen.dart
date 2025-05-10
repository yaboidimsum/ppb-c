import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // Import for PlatformException
import 'package:tugas_3/model/task_model.dart';
import 'package:tugas_3/services/notification_service.dart'; // Import NotificationService

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDeadline;
  bool _isLoading = false;

  Future<void> _pickDeadline(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedDeadline ?? DateTime.now(),
        ),
      );

      if (!mounted) {
        return; 
      }

     

      if (pickedTime != null) {
        setState(() {
          _selectedDeadline = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _saveTask() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDeadline == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a deadline.')),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User not logged in. Please login again.'),
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        final taskDataForSave = Task(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          deadline: _selectedDeadline!,
          userId: currentUser.uid,
        );

        DocumentReference docRef = await FirebaseFirestore.instance
            .collection('tasks')
            .add(taskDataForSave.toFirestore());

        final savedTask = Task(
          id: docRef.id,
          name: taskDataForSave.name,
          description: taskDataForSave.description,
          deadline: taskDataForSave.deadline,
          userId: taskDataForSave.userId,
        );

        // Try to schedule notifications and trigger created notification
        try {
          await NotificationService.scheduleTaskReminder(savedTask);
          await NotificationService.scheduleDeadlinePassedNotification(
            savedTask,
          );
          await NotificationService.triggerTaskCreatedNotification(
            savedTask,
          ); // Added this line

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Task added and notifications scheduled!'),
              ),
            );
          }
        } on PlatformException catch (e) {
          if (e.code == 'INSUFFICIENT_PERMISSIONS') {
            // print(
            //   "Failed to schedule/trigger notifications due to permissions: ${e.message}",
            // );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Task saved. ${e.message}'),
                  duration: const Duration(seconds: 6),
                  action: SnackBarAction(
                    label: 'Settings',
                    onPressed: () {
                      AwesomeNotifications().showNotificationConfigPage();
                    },
                  ),
                ),
              );
            }
          } else {
            // Handle other PlatformExceptions from notification scheduling/triggering
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Task saved, but error with notifications: ${e.message}',
                  ),
                ),
              );
            }
          }
        } catch (notificationError) {
          // Catch any other non-PlatformException errors from notifications
          // print("Error with notifications: $notificationError");
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Task saved, but error with notifications: $notificationError',
                ),
              ),
            );
          }
        }

        // Pop regardless of notification scheduling outcome, as task is saved.
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        // Catch errors from Firestore save itself
        // print("Error saving task to Firestore: $e");
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to add task: $e')));
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            // Use ListView for scrollability if content overflows
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Task Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 12.0),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 20.0),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _selectedDeadline == null
                          ? 'No deadline selected'
                          : 'Deadline: ${MaterialLocalizations.of(context).formatFullDate(_selectedDeadline!)} ${TimeOfDay.fromDateTime(_selectedDeadline!).format(context)}',
                    ),
                  ),
                  TextButton(
                    onPressed: _isLoading ? null : () => _pickDeadline(context),
                    child: const Text('Select Deadline'),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                    onPressed: _saveTask,
                    child: const Text('Save Task'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
