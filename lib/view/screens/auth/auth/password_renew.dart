import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tuncbt/view/screens/auth/auth_controller.dart';

class PasswordRenew extends GetView<AuthController> {
  static const routeName = "/password";
  PasswordRenew({Key? key}) : super(key: key);

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
                      height: size.width >= 1200 ? 100.0 : size.height * 0.1.h),
                  Text(
                    'Password Reset',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: size.width >= 1200 ? 48.0 : 36.sp,
                    ),
                  ),
                  SizedBox(height: size.width >= 1200 ? 16.0 : 10.h),
                  SizedBox(height: size.width >= 1200 ? 60.0 : 40.h),
                  Form(
                      key: controller.emailKey,
                      child: _buildEmailField(context)),
                  SizedBox(height: size.width >= 1200 ? 24.0 : 15.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => controller.resetPassword(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: size.width >= 1200 ? 16.0 : 12.h,
                            horizontal: size.width >= 1200 ? 24.0 : 16.w,
                          ),
                        ),
                        child: Text(
                          'Reset Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: size.width >= 1200 ? 20.0 : 17.sp,
                            decoration: TextDecoration.underline,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
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
          'Email address',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isLargeTablet ? 20.0 : 16.sp,
          ),
        ),
        SizedBox(height: isLargeTablet ? 12.0 : 8.h),
        TextFormField(
          controller: controller.forgetPassTextController,
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
            hintText: 'Enter your email',
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
}
