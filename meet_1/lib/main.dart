import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(fontFamily: 'SFPro'),
      home: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Home Module',
            style: TextStyle(
              fontFamily: 'SFPro',
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Home Module',
                style: TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 16), // Adds some space between texts
              const Text(
                'This is a centered paragraph added below the main text. '
                'You can customize this text and its style as needed.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'SFPro',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.yellow[200],
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.amber,
          tooltip: 'Add',
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
