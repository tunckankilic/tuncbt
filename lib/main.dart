import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:tuncbt/firebase_options.dart';
import 'package:tuncbt/user_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'TuncBT',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEDE7DC),
        primarySwatch: Colors.blue,
      ),
      home: const UserState(),
    );
  }
}
