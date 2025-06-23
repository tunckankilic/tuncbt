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
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 60.h),
              _buildTitle(context),
              SizedBox(height: 40.h),
              _buildEmailField(context),
              SizedBox(height: 40.h),
              _buildResetButton(context),
              SizedBox(height: 20.h),
              _buildBackButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.forgotPasswordTitle,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 32.sp,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          AppLocalizations.of(context)!.forgotPasswordSubtitle,
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.forgotPasswordEmail,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller.forgetPassTextController,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: AppLocalizations.of(context)!.forgotPasswordEmail,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(Icons.email, color: Colors.grey),
          ),
        ),
      ],
    );
  }

  Widget _buildResetButton(BuildContext context) {
    return Obx(() => ElevatedButton(
          onPressed:
              controller.isLoading.value ? null : controller.resetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.pink.shade700,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r)),
          ),
          child: Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: controller.isLoading.value
                ? const CircularProgressIndicator(color: Colors.white)
                : Text(
                    AppLocalizations.of(context)!.forgotPasswordReset,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18.sp,
                    ),
                  ),
          ),
        ));
  }

  Widget _buildBackButton(BuildContext context) {
    return TextButton(
      onPressed: () => Get.back(),
      child: Text(
        AppLocalizations.of(context)!.forgotPasswordBackToLogin,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16.sp,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
