import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuncbt/view/screens/auth/auth_controller.dart';
import 'package:tuncbt/view/screens/auth/screens/forget_pass.dart';

class AuthScreen extends GetView<AuthController> {
  static const routeName = "/auth";
  final bool isLogin;
  AuthScreen({Key? key, this.isLogin = true}) : super(key: key);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          _buildGradientOverlay(),
          _buildScrollableContent(context),
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

  Widget _buildScrollableContent(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40.h),
              _buildTitle(),
              SizedBox(height: 16.h),
              _buildToggleAuthModeText(),
              SizedBox(height: 40.h),
              _buildForm(context),
              if (isLogin) _buildForgetPasswordButton(),
              SizedBox(height: 40.h),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      isLogin ? 'Login' : 'Sign Up',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 32.sp,
      ),
    );
  }

  Widget _buildToggleAuthModeText() {
    return GestureDetector(
      onTap: () => Get.off(() => AuthScreen(isLogin: !isLogin)),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: 16.sp),
          children: [
            TextSpan(
              text: isLogin
                  ? 'Don\'t have an account? '
                  : 'Already have an account? ',
              style: const TextStyle(color: Colors.white70),
            ),
            TextSpan(
              text: isLogin ? 'Sign Up' : 'Login',
              style: TextStyle(
                color: Colors.blue.shade300,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (!isLogin) _buildFullNameField(),
          SizedBox(height: 16.h),
          _buildEmailField(),
          SizedBox(height: 16.h),
          _buildPasswordField(),
          if (!isLogin) ...[
            SizedBox(height: 16.h),
            _buildPhoneNumberField(),
            SizedBox(height: 16.h),
            _buildPositionField(context),
          ],
        ],
      ),
    );
  }

  Widget _buildFullNameField() {
    return TextFormField(
      controller: controller.fullNameController,
      validator: (value) => value!.isEmpty ? "This Field is missing" : null,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration('Full name'),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: controller.emailController,
      validator: (value) => value!.isEmpty || !value.contains("@")
          ? "Please enter a valid Email address"
          : null,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration('Email'),
    );
  }

  Widget _buildPasswordField() {
    return Obx(() => TextFormField(
          controller: controller.passwordController,
          obscureText: controller.obscureText.value,
          validator: (value) => value!.isEmpty || value.length < 7
              ? "Please enter a valid password"
              : null,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Password',
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureText.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: controller.toggleObscureText,
              )),
        ));
  }

  Widget _buildPhoneNumberField() {
    return TextFormField(
      controller: controller.phoneNumberController,
      validator: (value) => value!.isEmpty ? "This Field is missing" : null,
      style: const TextStyle(color: Colors.white),
      decoration: _inputDecoration('Phone number'),
    );
  }

  Widget _buildPositionField(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.showJobCategoriesDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller.positionCPController,
          validator: (value) => value!.isEmpty ? "This field is missing" : null,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration('Position in the company'),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {Widget? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.white70),
      enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      errorBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
      focusedErrorBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildForgetPasswordButton() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Get.to(() => const ForgetPasswordScreen()),
        child: Text(
          'Forgot password?',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14.sp,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() => ElevatedButton(
          onPressed: controller.isLoading.value ? null : _submitForm,
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
                ? CircularProgressIndicator(color: Colors.white)
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isLogin ? 'Login' : 'Sign Up',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.sp,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(isLogin ? Icons.login : Icons.person_add,
                          color: Colors.white),
                    ],
                  ),
          ),
        ));
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (isLogin) {
        controller.login();
      } else {
        controller.signUp();
      }
    }
  }
}
