import 'package:coffee_card/components/styled_body_text.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/coffee_prefs/coffee_prefs.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    //Return a container with a child of a column
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Coffee ID',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.brown[700],
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            color: Colors.brown[200],
            padding: const EdgeInsets.all(20),
            // alignment: Alignment.center,
            // height: 300,
            child: const  StyledBodyText('How I like my coffee...!'),
          ),
          Container(
            color: Colors.brown[100],
            padding: const EdgeInsets.all(20),
            // alignment: Alignment.topLeft,
            // height: 300,
            child: const CoffeePrefs(),
          ),
          Expanded(
            child: Image.asset(
              'assets/img/coffee_bg.jpg',
              fit: BoxFit.fitWidth,
              // alignment: Alignment.center,
            ),
          ),
        ],
      ),
    );
  }
}
