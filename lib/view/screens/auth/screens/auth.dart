import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/view/screens/auth/auth_controller.dart';
import 'package:tuncbt/view/screens/auth/screens/forget_pass.dart';
import 'package:tuncbt/view/widgets/modern_card_widget.dart';
import 'package:tuncbt/view/widgets/glassmorphic_button.dart';

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
            Colors.black.withOpacity(0.7),
            Colors.black.withOpacity(0.4),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildScrollableContent(BuildContext context) {
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
                SizedBox(height: isLargeTablet ? 24.0 : 16.h),
                _buildToggleAuthModeText(context),
                SizedBox(height: isLargeTablet ? 60.0 : 40.h),
                ModernInfoCard(
                  child: _buildForm(context),
                ),
                if (isLogin) _buildForgetPasswordButton(context),
                SizedBox(height: isLargeTablet ? 32.0 : 24.h),
                _buildSubmitButton(context),
                SizedBox(height: isLargeTablet ? 60.0 : 40.h),
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

    return Text(
      isLogin ? 'Login' : 'Sign Up',
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: isLargeTablet ? 48.0 : 32.sp,
      ),
    );
  }

  Widget _buildToggleAuthModeText(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth >= 1200;
    final fontSize = isLargeTablet ? 20.0 : 16.sp;

    return GestureDetector(
      onTap: () => Get.off(() => AuthScreen(isLogin: !isLogin)),
      child: RichText(
        text: TextSpan(
          style: TextStyle(fontSize: fontSize),
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth >= 1200;
    final spacing = isLargeTablet ? 24.0 : 16.h;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (!isLogin) _buildFullNameField(context),
          SizedBox(height: spacing),
          _buildEmailField(context),
          SizedBox(height: spacing),
          _buildPasswordField(context),
          if (!isLogin) ...[
            SizedBox(height: spacing),
            _buildPhoneNumberField(context),
            SizedBox(height: spacing),
            _buildPositionField(context),
          ],
        ],
      ),
    );
  }

  Widget _buildFullNameField(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth >= 1200;

    return TextFormField(
      controller: controller.fullNameController,
      validator: (value) => value!.isEmpty ? "This Field is missing" : null,
      style: TextStyle(
        color: Colors.white,
        fontSize: isLargeTablet ? 18.0 : 16.sp,
      ),
      decoration: _inputDecoration('Full name', context: context),
    );
  }

  Widget _buildEmailField(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth >= 1200;

    return TextFormField(
      controller: controller.emailController,
      validator: (value) => value!.isEmpty || !value.contains("@")
          ? "Please enter a valid Email address"
          : null,
      style: TextStyle(
        color: Colors.white,
        fontSize: isLargeTablet ? 18.0 : 16.sp,
      ),
      decoration: _inputDecoration('Email', context: context),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth >= 1200;

    return Obx(() => TextFormField(
          controller: controller.passwordController,
          obscureText: controller.obscureText.value,
          validator: (value) => value!.isEmpty || value.length < 7
              ? "Please enter a valid password"
              : null,
          style: TextStyle(
            color: Colors.white,
            fontSize: isLargeTablet ? 18.0 : 16.sp,
          ),
          decoration: _inputDecoration('Password',
              context: context,
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureText.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.white70,
                  size: isLargeTablet ? 28.0 : 24.sp,
                ),
                onPressed: controller.toggleObscureText,
              )),
        ));
  }

  Widget _buildPhoneNumberField(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth >= 1200;

    return TextFormField(
      controller: controller.phoneNumberController,
      validator: (value) =>
          value!.isEmpty ? AppLocalizations.of(context)!.fieldRequired : null,
      style: TextStyle(
        color: Colors.white,
        fontSize: isLargeTablet ? 18.0 : 16.sp,
      ),
      decoration: _inputDecoration(AppLocalizations.of(context)!.registerPhone,
          context: context),
    );
  }

  Widget _buildPositionField(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth >= 1200;

    return GestureDetector(
      onTap: () => controller.showJobCategoriesDialog(),
      child: AbsorbPointer(
        child: TextFormField(
          controller: controller.positionCPController,
          validator: (value) => value!.isEmpty
              ? AppLocalizations.of(context)!.fieldRequired
              : null,
          style: TextStyle(
            color: Colors.white,
            fontSize: isLargeTablet ? 18.0 : 16.sp,
          ),
          decoration: _inputDecoration(
              AppLocalizations.of(context)!.registerPosition,
              context: context),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint,
      {Widget? suffixIcon, BuildContext? context}) {
    final screenWidth = context != null ? MediaQuery.of(context).size.width : 0;
    final isLargeTablet = screenWidth >= 1200;
    final fontSize = isLargeTablet ? 18.0 : 16.sp;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.white70,
        fontSize: fontSize,
      ),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(
        color: Colors.white70,
        width: isLargeTablet ? 2.0 : 1.0,
      )),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
        color: Colors.white,
        width: isLargeTablet ? 2.0 : 1.0,
      )),
      errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
        color: Colors.red,
        width: isLargeTablet ? 2.0 : 1.0,
      )),
      focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(
        color: Colors.red,
        width: isLargeTablet ? 2.0 : 1.0,
      )),
      suffixIcon: suffixIcon,
    );
  }

  Widget _buildForgetPasswordButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth >= 1200;

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => Get.to(() => const ForgetPasswordScreen()),
        child: Text(
          AppLocalizations.of(context)!.loginResetPassword,
          style: TextStyle(
            color: Colors.white70,
            fontSize: isLargeTablet ? 16.0 : 14.sp,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeTablet = screenWidth >= 1200;

    return Obx(() => ModernPrimaryButton(
          text: isLogin
              ? AppLocalizations.of(context)!.loginButton
              : AppLocalizations.of(context)!.registerButton,
          icon: Icon(
            isLogin ? Icons.login : Icons.person_add,
            color: Colors.white,
            size: isLargeTablet ? 28.0 : 20.sp,
          ),
          onPressed: controller.isLoading.value ? null : _submitForm,
          isLoading: controller.isLoading.value,
          fullWidth: true,
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
