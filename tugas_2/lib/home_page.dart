import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  //reference the box
  final _myBox = Hive.box('mybox');
  String? displayText;

  //write data
  void writeData() {
    _myBox.put(1, {
      "Name": "John Doe",
      "Address": "123 Main St",
      "Phone": "555-1234",
    });
    setState(() {
      displayText = _myBox.get(1)["Name"];
    });
  }

  //read data
  void readData() {}
  //delete data
  void deleteData() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(displayText ?? "Data written: "),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 20,
              children: [
                MaterialButton(
                  onPressed: writeData,
                  color: Colors.blue,
                  child: Text("Create"),
                ),
                MaterialButton(
                  onPressed: () {},
                  color: Colors.blue,
                  child: Text("Read"),
                ),
                MaterialButton(
                  onPressed: () {},
                  color: Colors.blue,
                  child: Text("Delete"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
