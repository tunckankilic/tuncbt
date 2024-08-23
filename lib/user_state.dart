import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncbt/screens/auth/auth_bindings.dart';
import 'package:tuncbt/screens/auth/screens/auth.dart';
import 'package:tuncbt/screens/tasks_screen/screens/tasks_screen.dart';
import 'package:tuncbt/screens/tasks_screen/tasks_screen_bindings.dart';

class UserState extends StatelessWidget {
  const UserState({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (ctx, userSnapshot) {
        if (userSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (userSnapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('An error has occurred')),
          );
        } else if (userSnapshot.hasData) {
          Get.put(TasksScreenBindings());
          return TasksScreen();
        } else {
          Get.put(AuthBindings());
          return AuthScreen();
        }
      },
    );
  }
}
