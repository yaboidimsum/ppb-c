import 'package:coffee_card/components/styled_button.dart';
import 'package:flutter/material.dart';
import 'package:coffee_card/components/styled_body_text.dart';

class CoffeePrefs extends StatefulWidget {
  const CoffeePrefs({super.key});

  @override
  State<CoffeePrefs> createState() => _CoffeePrefsState();
}

class _CoffeePrefsState extends State<CoffeePrefs> {
  int strength = 1;
  int sugar = 1;

  void increaseStrength() {
    setState(() {
      strength = strength < 5 ? strength + 1 : 1;
    });
  }

  void increaseSweet() {
    setState(() {
      sugar = sugar < 5 ? sugar + 1 : 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const StyledBodyText('Strength:'),

            // Text('$strength'),
            for (int i = 0; i < strength; i++)
              Image.asset(
                'assets/img/coffee_bean.png',
                width: 25,
                color: Colors.brown[100],
                colorBlendMode: BlendMode.multiply,
              ),

            const Expanded(child: SizedBox()),
            StyledButton(onPressed: increaseStrength, child: const Text('+')),
          ],
        ),
        Row(
          children: [
            const StyledBodyText('Sugars:'),

            if (sugar == 0) const Text('No sugar'),

            // Text('$sugar'),
            for (int i = 0; i < sugar; i++)
              Image.asset(
                'assets/img/sugar_cube.png',
                width: 25,
                color: Colors.brown[100],
                colorBlendMode: BlendMode.multiply,
              ),
            // Image.asset(
            //   'assets/img/sugar_cube.png',
            //   width: 25,
            //   color: Colors.brown[100],
            //   colorBlendMode: BlendMode.multiply,
            // ),
            const Expanded(child: SizedBox()),
            StyledButton(onPressed: increaseSweet, child: const Text('+')),
          ],
        ),
      ],
    );
  }
}
