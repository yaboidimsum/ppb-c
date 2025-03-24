import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My first app",
          style: TextStyle(color: Colors.black, fontFamily: 'SFPro'),
        ),
        centerTitle: true,
        backgroundColor: Colors.amber[200],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            color: Colors.blue[200],
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.fromLTRB(20, 20, 20, 20),
            alignment: Alignment.center,
            child: Image.asset('assets/img/image.jpeg'),
          ),
          Container(
            color: Colors.red[200],
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
            alignment: Alignment.centerLeft,
            width: 400,
            height: 80,
            child: Text(
              'What image is that?',
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'SFPro',
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            color: Colors.yellow[100],
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.fromLTRB(20, 10, 20, 20),
            alignment: Alignment.center,
            width: 400,
            height: 110,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                Column(
                  children: [
                    Icon(Icons.food_bank, color: Colors.black, size: 40.0),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Food',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'SFPro',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.beach_access, color: Colors.black, size: 40.0),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Scenery',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'SFPro',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.person, color: Colors.black, size: 40.0),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'People',
                        style: TextStyle(
                          color: Colors.black,
                          fontFamily: 'SFPro',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
