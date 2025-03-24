// import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:tugas_1/components/toast.dart';
import 'package:tugas_1/models/task.dart';

class TaskForm extends StatefulWidget {
  final Task? task; // Optional task for editing (null for new task)
  final Function(Task) onSubmit;
  final VoidCallback onCancel;
  final String title;
  final String submitButtonText;

  const TaskForm({
    super.key,
    this.task,
    required this.onSubmit,
    required this.onCancel,
    required this.title,
    required this.submitButtonText,
  });

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.task?.title ?? '');
    descriptionController = TextEditingController(
      text: widget.task?.description ?? '',
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // @override
  // Widget build(BuildContext context) {
  //   return AlertDialog(
  //     title: Text(widget.title),
  //     content: Column(
  //       mainAxisSize: MainAxisSize.min,
  //       children: [
  //         TextField(
  //           controller: titleController,
  //           decoration: const InputDecoration(
  //             labelText: 'Task Title',
  //             border: OutlineInputBorder(),
  //           ),
  //         ),
  //         const SizedBox(height: 16),
  //         TextField(
  //           controller: descriptionController,
  //           decoration: const InputDecoration(
  //             labelText: 'Task Description',
  //             border: OutlineInputBorder(),
  //           ),
  //           maxLines: 3,
  //         ),
  //       ],
  //     ),
  //     actions: [
  //       TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
  //       ElevatedButton(
  //         onPressed: () {
  //           final task =
  //               widget.task != null
  //                   ? widget.task!.copyWith(
  //                     title: titleController.text,
  //                     description: descriptionController.text,
  //                   )
  //                   : Task(
  //                     title: titleController.text,
  //                     description: descriptionController.text,
  //                     createdAt: DateTime.now(),
  //                   );
  //           widget.onSubmit(task);
  //         },
  //         child: Text(widget.submitButtonText),
  //       ),
  //     ],
  //   );
  // }

  final FormController controller = FormController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Keep title and description short and concise. Goodly done!',
          ),
          const Gap(16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              controller: controller,
              child: FormTableLayout(
                rows: [
                  FormField<String>(
                    key: FormKey(#title),
                    label: Text('Title'),
                    child: TextField(initialValue: titleController.text),
                  ),
                  FormField<String>(
                    key: FormKey(#desc),
                    label: Text('Desc'),
                    child: TextField(initialValue: descriptionController.text),
                  ),
                ],
              ),
            ).withPadding(vertical: 16),
          ),
        ],
      ),
      actions: [
        SecondaryButton(
          child: Text('Back'),
          onPressed: () {
            widget.onCancel();
          },
        ),
        const Spacer(),
        PrimaryButton(
          onPressed: () {
            showToast(
              context: context,
              builder: buildToast,
              location: ToastLocation.topLeft,
            );
            final task =
                widget.task != null
                    ? widget.task!.copyWith(
                      title: controller.values[FormKey(#title)],
                      description: controller.values[FormKey(#desc)],
                    )
                    : Task(
                      title:
                          controller.values[FormKey(#title)]?.isNotEmpty == true
                              ? controller.values[FormKey(#title)]
                              : 'No Title',
                      description:
                          controller.values[FormKey(#desc)]?.isNotEmpty == true
                              ? controller.values[FormKey(#desc)]
                              : 'No Desc',
                      createdAt: DateTime.now(),
                    );

            widget.onSubmit(task);
          },
          child: Text(widget.submitButtonText),
        ),
      ],
    );
  }
}
