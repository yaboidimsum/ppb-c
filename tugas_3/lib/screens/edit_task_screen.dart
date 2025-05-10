import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tugas_3/model/task_model.dart';
import 'package:tugas_3/services/notification_service.dart'; // Import NotificationService

class EditTaskScreen extends StatefulWidget {
  final Task task; // Task to be edited

  const EditTaskScreen({super.key, required this.task});

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDeadline;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.task.name);
    _descriptionController = TextEditingController(
      text: widget.task.description,
    );
    _selectedDeadline = widget.task.deadline;
  }

  Future<void> _pickDeadline(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now().subtract(
        const Duration(days: 365),
      ), // Allow past dates for editing if needed
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

  Future<void> _updateTask() async {
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

      try {
        // Create a map of fields to update.
        // Use the existing userId and only update fields that can change.
        final updatedTaskData = {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'deadline': Timestamp.fromDate(_selectedDeadline!),
          // 'userId' is not updated as it should remain the same
        };

        await FirebaseFirestore.instance
            .collection('tasks')
            .doc(widget.task.id) // Use the existing task's ID
            .update(updatedTaskData);

        // Create an updated Task object to pass to notification scheduler
        final updatedTask = Task(
          id: widget.task.id,
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          deadline: _selectedDeadline!,
          userId: widget.task.userId, // userId doesn't change
        );

        // Schedule new notifications
        await NotificationService.scheduleTaskReminder(updatedTask);
        await NotificationService.scheduleDeadlinePassedNotification(
          updatedTask,
        );

        await NotificationService.triggerTaskUpdatedNotification(
          updatedTask,
        ); // Added this line

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task updated successfully!')),
          );
          Navigator.pop(context); // Go back to the TaskListScreen
        }
      } catch (e) {
        // print("Error updating task: $e");
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to update task: $e')));
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
      appBar: AppBar(title: const Text('Edit Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
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
                    onPressed: _updateTask, // Call _updateTask
                    child: const Text('Save Changes'),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
