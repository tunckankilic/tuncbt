import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/view/screens/auth/auth_bindings.dart';
import 'package:tuncbt/view/screens/auth/auth_controller.dart';
import 'package:tuncbt/view/screens/auth/auth/password_renew.dart';
import 'package:tuncbt/view/screens/auth/auth/register.dart';

class Login extends GetView<AuthController> {
  static const routeName = "/login";
  Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            child: Obx(() => CachedNetworkImage(
                  imageUrl:
                      "https://media.istockphoto.com/photos/businesswoman-using-computer-in-dark-office-picture-id557608443?k=6&m=557608443&s=612x612&w=0&h=fWWESl6nk7T6ufo4sRjRBSeSiaiVYAzVrY-CLlfMptM=",
                  placeholder: (context, url) => Image.asset(
                      'assets/images/wallpaper.jpg',
                      fit: BoxFit.cover),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  alignment:
                      FractionalOffset(controller.animationValue.value, 0),
                )),
          ),
          Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: size.width >= 1200 ? 800.0 : double.infinity,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: size.width >= 1200 ? size.width * 0.2 : 16.r,
              ),
              child: ListView(
                children: [
                  SizedBox(
                      height:
                          size.width >= 1200 ? 100.0 : size.height * 0.05.h),
                  Text(
                    AppLocalizations.of(context)!.appTitle,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: size.width >= 1200 ? 48.0 : 36.sp,
                    ),
                  ),
                  SizedBox(height: size.width >= 1200 ? 16.0 : 10.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.loginNoAccount,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: size.width >= 1200 ? 18.0 : 14.sp,
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Get.to(() => SignUp(), binding: AuthBindings()),
                        child: Text(
                          AppLocalizations.of(context)!.register,
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.red[900],
                            fontWeight: FontWeight.bold,
                            fontSize: size.width >= 1200 ? 22.0 : 18.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.width >= 1200 ? 60.0 : 40.h),
                  Form(
                      key: controller.emailKey,
                      child: _buildEmailField(context)),
                  SizedBox(height: size.width >= 1200 ? 24.0 : 15.h),
                  Form(
                      key: controller.passKay,
                      child: _buildPasswordField(context)),
                  SizedBox(height: size.width >= 1200 ? 24.0 : 15.h),
                  Container(
                    padding: EdgeInsets.all(size.width >= 1200 ? 8.0 : 5.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                          size.width >= 1200 ? 20.0 : 15.sp),
                    ),
                    child: TextButton(
                      onPressed: () => Get.toNamed(PasswordRenew.routeName),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: size.width >= 1200 ? 16.0 : 12.h,
                          horizontal: size.width >= 1200 ? 24.0 : 16.w,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.loginResetPassword,
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: size.width >= 1200 ? 18.0 : 14.sp,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.width >= 1200 ? 24.0 : 15.h),
                  Container(
                    padding: EdgeInsets.all(size.width >= 1200 ? 8.0 : 5.sp),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(
                          size.width >= 1200 ? 20.0 : 15.sp),
                    ),
                    child: TextButton(
                      onPressed: () => controller.login(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          vertical: size.width >= 1200 ? 20.0 : 16.h,
                          horizontal: size.width >= 1200 ? 32.0 : 24.w,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.login,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size.width >= 1200 ? 22.0 : 17.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth >= 1200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.loginEmail,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isLargeTablet ? 20.0 : 16.sp,
          ),
        ),
        SizedBox(height: isLargeTablet ? 12.0 : 8.h),
        TextFormField(
          controller: controller.emailController,
          style: TextStyle(
            color: Colors.black,
            fontSize: isLargeTablet ? 18.0 : 16.sp,
          ),
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
            hintText: AppLocalizations.of(context)!.loginEmail,
            hintStyle: TextStyle(
              fontSize: isLargeTablet ? 18.0 : 16.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isLargeTablet ? 12.0 : 8.r),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(
              Icons.email,
              color: Colors.grey,
              size: isLargeTablet ? 28.0 : 24.sp,
            ),
            errorStyle: TextStyle(
              color: Colors.white,
              fontSize: isLargeTablet ? 16.0 : 14.sp,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: isLargeTablet ? 20.0 : 16.h,
              horizontal: isLargeTablet ? 24.0 : 16.w,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth >= 1200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.loginPassword,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isLargeTablet ? 20.0 : 16.sp,
          ),
        ),
        SizedBox(height: isLargeTablet ? 12.0 : 8.h),
        TextFormField(
          controller: controller.passwordController,
          style: TextStyle(
            color: Colors.black,
            fontSize: isLargeTablet ? 18.0 : 16.sp,
          ),
          keyboardType: TextInputType.emailAddress,
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your password';
            }
            return null;
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: AppLocalizations.of(context)!.loginPassword,
            hintStyle: TextStyle(
              fontSize: isLargeTablet ? 18.0 : 16.sp,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isLargeTablet ? 12.0 : 8.r),
              borderSide: BorderSide.none,
            ),
            prefixIcon: Icon(
              Icons.password,
              color: Colors.grey,
              size: isLargeTablet ? 28.0 : 24.sp,
            ),
            errorStyle: TextStyle(
              color: Colors.white,
              fontSize: isLargeTablet ? 16.0 : 14.sp,
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: isLargeTablet ? 20.0 : 16.h,
              horizontal: isLargeTablet ? 24.0 : 16.w,
            ),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth >= 1200;

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black87,
        backgroundColor: Colors.white,
        minimumSize: Size(double.infinity, isLargeTablet ? 64.0 : 50.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isLargeTablet ? 48.0 : 40.0),
        ),
        elevation: 0,
        side: const BorderSide(color: Colors.grey),
        padding: EdgeInsets.symmetric(
          vertical: isLargeTablet ? 16.0 : 10.0,
          horizontal: isLargeTablet ? 32.0 : 24.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            'assets/google_logo.png',
            height: isLargeTablet ? 32.0 : 24.0,
            width: isLargeTablet ? 32.0 : 24.0,
          ),
          SizedBox(width: isLargeTablet ? 16.0 : 10.0),
          Text(
            'Sign in with Google',
            style: TextStyle(
              fontSize: isLargeTablet ? 20.0 : 16.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
