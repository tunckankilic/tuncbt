import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/view/screens/auth/auth_controller.dart';

class ForgetPasswordScreen extends GetView<AuthController> {
  static const routeName = "/forgot-pass";

  const ForgetPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          _buildGradientOverlay(),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Obx(() => CachedNetworkImage(
          imageUrl:
              "https://media.istockphoto.com/photos/businesswoman-using-computer-in-dark-office-picture-id557608443?k=6&m=557608443&s=612x612&w=0&h=fWWESl6nk7T6ufo4sRjRBSeSiaiVYAzVrY-CLlfMptM=",
          placeholder: (context, url) => Image.asset(
            'assets/images/wallpaper.jpg',
            fit: BoxFit.cover,
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          alignment: FractionalOffset(controller.animationValue.value, 0),
        ));
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.6),
            Colors.black.withOpacity(0.3),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth >= 1200;
    final horizontalPadding = isLargeTablet ? screenWidth * 0.2 : 24.w;

    return SafeArea(
      child: SingleChildScrollView(
        child: Center(
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isLargeTablet ? 800.0 : double.infinity,
            ),
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: isLargeTablet ? 100.0 : 60.h),
                _buildTitle(context),
                SizedBox(height: isLargeTablet ? 60.0 : 40.h),
                _buildEmailField(context),
                SizedBox(height: isLargeTablet ? 60.0 : 40.h),
                _buildResetButton(context),
                SizedBox(height: isLargeTablet ? 30.0 : 20.h),
                _buildBackButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth >= 1200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.forgotPasswordTitle,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isLargeTablet ? 48.0 : 32.sp,
          ),
        ),
        SizedBox(height: isLargeTablet ? 12.0 : 8.h),
        Text(
          AppLocalizations.of(context)!.forgotPasswordSubtitle,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isLargeTablet ? 20.0 : 16.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth >= 1200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.forgotPasswordEmail,
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
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: AppLocalizations.of(context)!.forgotPasswordEmail,
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
            contentPadding: EdgeInsets.symmetric(
              vertical: isLargeTablet ? 20.0 : 16.h,
              horizontal: isLargeTablet ? 24.0 : 16.w,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth >= 1200;

    return Obx(() => ElevatedButton(
          onPressed:
              controller.isLoading.value ? null : controller.resetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink.shade700,
            padding: EdgeInsets.symmetric(
              vertical: isLargeTablet ? 24.0 : 16.h,
              horizontal: isLargeTablet ? 32.0 : 24.w,
            ),
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(isLargeTablet ? 12.0 : 8.r)),
          ),
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: controller.isLoading.value
                ? SizedBox(
                    width: isLargeTablet ? 28.0 : 24.sp,
                    height: isLargeTablet ? 28.0 : 24.sp,
                    child: const CircularProgressIndicator(color: Colors.white),
                  )
                : Text(
                    AppLocalizations.of(context)!.forgotPasswordReset,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isLargeTablet ? 22.0 : 18.sp,
                    ),
                  ),
          ),
        ));
  }

  Widget _buildBackButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth >= 1200;

    return TextButton(
      onPressed: () => Get.back(),
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(
          vertical: isLargeTablet ? 16.0 : 12.h,
          horizontal: isLargeTablet ? 24.0 : 16.w,
        ),
      ),
      child: Text(
        AppLocalizations.of(context)!.forgotPasswordBackToLogin,
        style: TextStyle(
          color: Colors.white70,
          fontSize: isLargeTablet ? 18.0 : 16.sp,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
