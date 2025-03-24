// import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:tugas_1/screens/task_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      title: 'Task Manager',
      theme: ThemeData(colorScheme: ColorSchemes.darkZinc(), radius: 0.5),
      home: const TaskListScreen(),
    );
  }
}
