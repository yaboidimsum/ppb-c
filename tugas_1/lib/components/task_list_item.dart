// import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:tugas_1/models/task.dart';
import 'package:tugas_1/components/task_form.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onDelete;
  final VoidCallback onToggle;
  final Function(Task) onEdit;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onDelete,
    required this.onToggle,
    required this.onEdit,
  });

  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return TaskForm(
          task: task,
          title: 'Edit Task',
          submitButtonText: 'Save',
          onSubmit: (updatedTask) {
            onEdit(updatedTask);
            Navigator.pop(context);
          },
          onCancel: () {
            Navigator.pop(context);
          },
        );
      },
    );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Card(
  //     margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     child: ListTile(
  //       leading: Checkbox(
  //         value: task.isCompleted,
  //         onChanged: (_) => onToggle(),
  //       ),
  //       title: Text(
  //         task.title,
  //         style: TextStyle(
  //           decoration: task.isCompleted ? TextDecoration.lineThrough : null,
  //           color: task.isCompleted ? Colors.grey : null,
  //         ),
  //       ),
  //       subtitle: Text(
  //         task.description,
  //         style: TextStyle(
  //           decoration: task.isCompleted ? TextDecoration.lineThrough : null,
  //           color: task.isCompleted ? Colors.grey : null,
  //         ),
  //       ),
  //       trailing: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           IconButton(
  //             icon: const Icon(Icons.edit),
  //             onPressed: () => _showEditDialog(context),
  //           ),
  //           IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? Colors.gray : null,
                    ),
                  ).semiBold().base(),
                  const SizedBox(height: 4),
                  Text(
                    task.description,
                    style: TextStyle(
                      decoration:
                          task.isCompleted ? TextDecoration.lineThrough : null,
                      color: task.isCompleted ? Colors.gray : null,
                    ),
                  ).muted().small(),
                  const SizedBox(height: 24),
                ],
              ),
              const Spacer(),
              Checkbox(
                state:
                    task.isCompleted
                        ? CheckboxState.checked
                        : CheckboxState.unchecked,
                onChanged: (_) {
                  onToggle();
                },
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: OutlineButton(
                  trailing: const Icon(Icons.edit_outlined, size: 20),
                  child: Text('Modify', style: TextStyle(fontSize: 20)),
                  onPressed: () => _showEditDialog(context),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DestructiveButton(
                  trailing: const Icon(Icons.delete, size: 20),
                  onPressed: onDelete,
                  child: const Text('Remove', style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ],
      ),
    ).intrinsic();
  }
}
