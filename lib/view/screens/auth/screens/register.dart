import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/view/screens/auth/auth_controller.dart';

class SignUp extends GetView<AuthController> {
  static const routeName = "/register";

  SignUp({Key? key}) : super(key: key);

  final _signUpFormKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final referralCode = Get.arguments?['referralCode'] as String?;
    if (referralCode != null) {
      controller.setReferralCode(referralCode);
    }

    return Scaffold(
      body: Stack(
        children: [
          _buildBackgroundImage(),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.1),
                  _buildHeader(size, context),
                  SizedBox(height: 20.h),
                  if (controller.teamName.value.isNotEmpty) ...[
                    _buildTeamInfo(),
                    SizedBox(height: 20.h),
                  ],
                  _buildForm(size, context),
                  SizedBox(height: 40.h),
                  _buildSignUpButton(context),
                ],
              ),
            ),
          ),
          if (controller.isTeamLoading.value)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Obx(() => CachedNetworkImage(
          imageUrl:
              "https://media.istockphoto.com/photos/businesswoman-using-computer-in-dark-office-picture-id557608443?k=6&m=557608443&s=612x612&w=0&h=fWWESl6nk7T6ufo4sRjRBSeSiaiVYAzVrY-CLlfMptM=",
          placeholder: (context, url) =>
              Image.asset('assets/images/wallpaper.jpg', fit: BoxFit.fill),
          errorWidget: (context, url, error) => const Icon(Icons.error),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          alignment: FractionalOffset(controller.animationValue.value, 0),
        ));
  }

  Widget _buildHeader(Size size, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.isSocialSignIn.value
              ? 'Complete Your Profile'
              : AppLocalizations.of(context)!.register,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 30.sp),
        ),
        Row(
          children: [
            if (!controller.isSocialSignIn.value)
              SizedBox(
                width: 150.w,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: AppLocalizations.of(context)!.registerHasAccount,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp),
                      ),
                      const TextSpan(text: '    '),
                      TextSpan(
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Get.back(),
                        text: AppLocalizations.of(context)!.login,
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: Colors.red[200],
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SizedBox(
              width: 10.w,
            ),
            _buildImageContainer(size),
            _buildImageEditButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Katılacağınız Takım:',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.group, color: Colors.green, size: 24.sp),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.teamName.value,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForm(Size size, BuildContext context) {
    return Form(
      key: _signUpFormKey,
      child: Column(
        children: [
          if (!controller.isSocialSignIn.value) ...[
            _buildNameAndImageSection(size, context)
          ],
          const SizedBox(height: 20),
          if (!controller.isSocialSignIn.value) ...[
            _buildPasswordField(context),
            const SizedBox(height: 20),
            _buildConfirmPasswordField(context),
            const SizedBox(height: 20),
          ],
          _buildPhoneNumberField(context),
          const SizedBox(height: 20),
          _buildPositionField(context),
        ],
      ),
    );
  }

  Widget _buildNameAndImageSection(Size size, BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: controller.emailController,
          validator: (value) => value!.isEmpty ? "This Field is missing" : null,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.registerEmail,
            hintStyle: const TextStyle(color: Colors.black),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
            errorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red)),
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        TextFormField(
          controller: controller.fullNameController,
          validator: (value) => value!.isEmpty ? "This Field is missing" : null,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.registerName,
            hintStyle: const TextStyle(color: Colors.black),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
            errorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red)),
          ),
        ),
      ],
    );
  }

  Widget _buildImageContainer(Size size) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: size.width * 0.24,
        height: size.width * 0.24,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.white),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Obx(() {
            if (controller.imageFile.value != null) {
              return Image.file(
                controller.imageFile.value!,
                fit: BoxFit.cover,
              );
            } else {
              return Image.network(
                'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person,
                  size: size.width * 0.12,
                  color: Colors.grey,
                ),
              );
            }
          }),
        ),
      ),
    );
  }

  Widget _buildImageEditButton() {
    return InkWell(
      onTap: () => controller.showImageDialog(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.pink,
          border: Border.all(width: 2, color: Colors.white),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            controller.imageFile.value == null
                ? Icons.add_a_photo
                : Icons.edit_outlined,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Obx(() => TextFormField(
          controller: controller.passwordController,
          obscureText: controller.obscureText.value,
          validator: (value) => value!.isEmpty || value.length < 7
              ? "Please enter a valid password"
              : null,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            suffixIcon: GestureDetector(
              onTap: controller.toggleObscureText,
              child: Icon(
                  controller.obscureText.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.white),
            ),
            hintText: AppLocalizations.of(context)!.registerPassword,
            hintStyle: const TextStyle(color: Colors.black),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
            errorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red)),
          ),
        ));
  }

  Widget _buildConfirmPasswordField(BuildContext context) {
    return Obx(() => TextFormField(
          controller: controller.confirmPasswordController,
          obscureText: controller.obscureText.value,
          validator: (value) => value != controller.passwordController.text
              ? "Passwords do not match"
              : null,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            suffixIcon: GestureDetector(
              onTap: controller.toggleObscureText,
              child: Icon(
                  controller.obscureText.value
                      ? Icons.visibility
                      : Icons.visibility_off,
                  color: Colors.white),
            ),
            hintText: AppLocalizations.of(context)!.registerConfirmPassword,
            hintStyle: const TextStyle(color: Colors.black),
            enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
            focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white)),
            errorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red)),
          ),
        ));
  }

  Widget _buildPhoneNumberField(BuildContext context) {
    return TextFormField(
      controller: controller.phoneNumberController,
      validator: (value) => value!.isEmpty ? "This Field is missing" : null,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.registerPhone,
        hintStyle: const TextStyle(color: Colors.black),
        enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
        errorBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.red)),
      ),
    );
  }

  Widget _buildPositionField(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.showJobCategoriesDialog(),
      child: TextFormField(
        enabled: false,
        controller: controller.positionCPController,
        validator: (value) => value!.isEmpty ? "This field is missing" : null,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          suffixIcon:
              const Icon(Icons.arrow_downward_rounded, color: Colors.black),
          hintText: AppLocalizations.of(context)!.registerPosition,
          hintStyle: const TextStyle(color: Colors.black),
          enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white)),
          focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white)),
          errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.red)),
          disabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white)),
        ),
      ),
    );
  }

  Widget _buildSignUpButton(BuildContext context) {
    return Obx(() => controller.isLoading.value
        ? const Center(child: CircularProgressIndicator())
        : MaterialButton(
            onPressed: () {
              if (_signUpFormKey.currentState!.validate()) {
                controller.signUp(isSocial: controller.isSocialSignIn.value);
              }
            },
            color: Colors.red[900],
            elevation: 8,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13.r)),
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 14.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    controller.isSocialSignIn.value
                        ? 'Complete Profile'
                        : AppLocalizations.of(context)!.signUp,
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.sp),
                  ),
                  SizedBox(width: 16.r),
                  Icon(Icons.person_add, color: Colors.white, size: 30.r),
                ],
              ),
            ),
          ));
  }
}
