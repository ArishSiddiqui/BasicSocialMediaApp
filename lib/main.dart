import 'package:flutter/material.dart';
import 'package:feed/pages/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feed',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.red[600],
        accentColor: Colors.yellow,
      ),
      home: Home(),
    );
  }
}
