import 'package:flutter/material.dart';

import 'elements/bottomNav.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BottomWidget(),
    );
  }
}
