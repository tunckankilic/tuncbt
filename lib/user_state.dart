import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tuncbt/screens/auth/screens/login.dart';
import 'package:tuncbt/screens/tasks_screen/screens/tasks_screen.dart';

class UserState extends StatelessWidget {
  const UserState({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, userSnapshot) {
          if (userSnapshot.data == null) {
            log('user is not signed in yet');
            return Login();
          } else if (userSnapshot.hasData) {
            log('user is already signed in');
            return TasksScreen();
          } else if (userSnapshot.hasError) {
            return const Scaffold(
              body: Center(
                child: Text('An error has been occured'),
              ),
            );
          } else if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
                body: Center(
              child: CircularProgressIndicator(),
            ));
          }
          return const Scaffold(
            body: Center(
              child: Text('Something went wrong '),
            ),
          );
        });
  }
}
