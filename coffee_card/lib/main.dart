import 'package:coffee_card/home/home.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: Home()));
}

class Sandbox extends StatelessWidget {
  const Sandbox({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sandbox'),
        backgroundColor: Colors.grey,
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.values[4],
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: Colors.blue,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            width: 100,
            height: 200,
            child: const Text('Container 1'),
          ),
          Container(
            color: Colors.red,
            padding: const EdgeInsets.all(20),
            alignment: Alignment.center,
            width: 100,
            height: 400,
            child: const Text('Container 2'),
          ),
        ],
      ),
    );
  }
}
