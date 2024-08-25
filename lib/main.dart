import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tuncbt/config/constants.dart';
import 'package:tuncbt/config/router.dart';
import 'package:tuncbt/firebase_options.dart';
import 'package:tuncbt/screens/auth/auth_bindings.dart';
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
    return ScreenUtilInit(
      designSize: const Size(320, 568),
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TuncBT',
        theme: AppTheme.lightTheme,
        initialBinding: AuthBindings(),
        getPages: RouteManager.routes,
        home: const UserState(),
      ),
    );
  }
}
