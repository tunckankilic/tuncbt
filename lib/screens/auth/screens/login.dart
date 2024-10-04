import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tuncbt/screens/auth/auth_bindings.dart';
import 'package:tuncbt/screens/auth/auth_controller.dart';
import 'package:tuncbt/screens/auth/screens/password_renew.dart';
import 'package:tuncbt/screens/auth/screens/register.dart';

class Login extends GetView<AuthController> {
  static const routeName = "/login";
  Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Obx(() => CachedNetworkImage(
                imageUrl:
                    "https://media.istockphoto.com/photos/businesswoman-using-computer-in-dark-office-picture-id557608443?k=6&m=557608443&s=612x612&w=0&h=fWWESl6nk7T6ufo4sRjRBSeSiaiVYAzVrY-CLlfMptM=",
                placeholder: (context, url) => Image.asset(
                    'assets/images/wallpaper.jpg',
                    fit: BoxFit.fill),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                alignment: FractionalOffset(controller.animationValue.value, 0),
              )),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.r),
            child: ListView(
              children: [
                SizedBox(height: size.height * 0.05.h),
                Text(
                  'TuncBT',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 36.sp),
                ),
                SizedBox(height: 10.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Don\'t have an account',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Get.to(() => SignUp(), binding: AuthBindings()),
                      child: Text(
                        'Register',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.red[900],
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                Form(key: controller.emailKey, child: _buildEmailField()),
                SizedBox(height: 15.h),
                Form(key: controller.passKay, child: _buildPasswordField()),
                SizedBox(height: 15.h),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15.sp)),
                  child: TextButton(
                    onPressed: () => Get.toNamed(PasswordRenew.routeName),
                    child: Text(
                      'Reset Password',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
                Container(
                  padding: EdgeInsets.all(5.sp),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(15.sp)),
                  child: TextButton(
                    onPressed: () => controller.login(),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'Or ',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 5.h),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (Platform.isIOS)
                      SizedBox(
                        width: 200.w,
                        child: SignInWithAppleButton(
                          onPressed: () => controller.signInWithApple(),
                          borderRadius: BorderRadius.circular(30.r),
                        ),
                      ),
                    SizedBox(height: 5.h),
                    if (Platform.isAndroid)
                      GoogleSignInButton(
                        onPressed: () => controller.signInWithGoogle(),
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

  // Widget _socialLoginButton({
  //   required VoidCallback onPressed,
  //   required IconData icon,
  //   required String label,
  // }) {
  //   return ElevatedButton.icon(
  //     onPressed: onPressed,
  //     icon: Icon(icon, color: Colors.white),
  //     label: Text(label),
  //     style: ElevatedButton.styleFrom(
  //       backgroundColor: Colors.pink.shade700,
  //       shape:
  //           RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
  //       padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
  //     ),
  //   );
  // }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email address',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller.emailController,
          style: const TextStyle(color: Colors.black),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!GetUtils.isEmail(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Enter your email',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.email, color: Colors.grey),
            errorStyle: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller.passwordController,
          style: const TextStyle(color: Colors.black),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: 'Enter your Password',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.password, color: Colors.grey),
            errorStyle: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black87,
        backgroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        elevation: 0,
        side: const BorderSide(color: Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/google_logo.png',
              height: 24.0,
              width: 24.0,
            ),
            const SizedBox(width: 10),
            const Text(
              'Sign in with Google',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
