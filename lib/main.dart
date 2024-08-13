import 'package:flutter/material.dart';
import 'package:tuncbt/screens/tasks_screen.dart';

import 'screens/auth/login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter workos',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFEDE7DC),
        primarySwatch: Colors.blue,
      ),
      home: TasksScreen(),
    );
  }
}
