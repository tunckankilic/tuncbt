import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tuncbt/core/config/constants.dart';
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
            child: Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: size.width >= 1200 ? 800.0 : double.infinity,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: size.width >= 1200 ? size.width * 0.2 : 16.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                        height: size.width >= 1200 ? 100.0 : size.height * 0.1),
                    _buildHeader(size, context),
                    SizedBox(height: size.width >= 1200 ? 32.0 : 20.h),
                    _buildReferralCodeField(context),
                    SizedBox(height: size.width >= 1200 ? 32.0 : 20.h),
                    if (controller.teamName.value.isNotEmpty) ...[
                      _buildTeamInfo(context),
                      SizedBox(height: size.width >= 1200 ? 32.0 : 20.h),
                    ],
                    _buildForm(size, context),
                    SizedBox(height: size.width >= 1200 ? 60.0 : 40.h),
                    _buildLegalChecks(context),
                    SizedBox(height: size.width >= 1200 ? 32.0 : 20.h),
                    _buildNotificationPermission(context),
                    SizedBox(height: size.width >= 1200 ? 32.0 : 20.h),
                    _buildSignUpButton(context),
                  ],
                ),
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
    final isLargeTablet = size.width >= 1200;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.createTeam,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isLargeTablet ? 42.0 : 30.sp,
          ),
        ),
        Row(
          children: [
            SizedBox(
              width: isLargeTablet ? 200.0 : 150.w,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: AppLocalizations.of(context)!.registerHasAccount,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: isLargeTablet ? 24.0 : 20.sp,
                      ),
                    ),
                    TextSpan(text: isLargeTablet ? '      ' : '    '),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => Get.back(),
                      text: AppLocalizations.of(context)!.login,
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Colors.red[200],
                        fontWeight: FontWeight.bold,
                        fontSize: isLargeTablet ? 20.0 : 16.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: isLargeTablet ? 16.0 : 10.w),
            _buildImageContainer(size),
            _buildImageEditButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildReferralCodeField(BuildContext context) {
    final isLargeTablet = MediaQuery.of(context).size.width >= 1200;

    return Container(
      padding: EdgeInsets.all(isLargeTablet ? 24.0 : 16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(isLargeTablet ? 12.0 : 8.0),
        border: Border.all(
          color: Colors.blue,
          width: isLargeTablet ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.referralCode,
            style: TextStyle(
              color: Colors.black87,
              fontSize: isLargeTablet ? 20.0 : 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isLargeTablet ? 12.0 : 8.0),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.referralCodeController,
                  style: TextStyle(
                    fontSize: isLargeTablet ? 18.0 : 16.sp,
                  ),
                  decoration: InputDecoration(
                    hintText: 'XXXXXXXX',
                    hintStyle: TextStyle(
                      color: Colors.black54,
                      fontSize: isLargeTablet ? 18.0 : 16.sp,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        Icons.info_outline,
                        size: isLargeTablet ? 28.0 : 24.0,
                      ),
                      onPressed: () => _showReferralInfo(context),
                      padding: EdgeInsets.all(isLargeTablet ? 12.0 : 8.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: isLargeTablet ? 20.0 : 16.0,
                      horizontal: isLargeTablet ? 24.0 : 16.0,
                    ),
                  ),
                  inputFormatters: [
                    UpperCaseTextFormatter(),
                    LengthLimitingTextInputFormatter(8),
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                  ],
                  onChanged: (value) => controller.setReferralCode(value),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
            ],
          ),
          SizedBox(height: isLargeTablet ? 12.0 : 8.0),
          Text(
            AppLocalizations.of(context)!.referralCodeOptional,
            style: TextStyle(
              color: Colors.black54,
              fontSize: isLargeTablet ? 14.0 : 12.sp,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  void _showReferralInfo(BuildContext context) {
    final isLargeTablet = MediaQuery.of(context).size.width >= 1200;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.referralCodeTitle,
          style: TextStyle(
            fontSize: isLargeTablet ? 24.0 : 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          width: isLargeTablet ? 600.0 : null,
          child: Text(
            AppLocalizations.of(context)!.referralCodeDescription,
            style: TextStyle(
              fontSize: isLargeTablet ? 18.0 : 16.0,
            ),
          ),
        ),
        contentPadding: EdgeInsets.all(isLargeTablet ? 24.0 : 16.0),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: isLargeTablet ? 16.0 : 12.0,
                horizontal: isLargeTablet ? 24.0 : 16.0,
              ),
            ),
            child: Text(
              AppLocalizations.of(context)!.ok,
              style: TextStyle(
                fontSize: isLargeTablet ? 18.0 : 16.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfo(BuildContext context) {
    final isLargeTablet = MediaQuery.of(context).size.width >= 1200;

    return Container(
      padding: EdgeInsets.all(isLargeTablet ? 24.0 : 16.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(isLargeTablet ? 12.0 : 8.0),
        border: Border.all(
          color: Colors.green,
          width: isLargeTablet ? 2.0 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.joinTeam,
            style: TextStyle(
              color: Colors.black87,
              fontSize: isLargeTablet ? 20.0 : 16.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isLargeTablet ? 12.0 : 8.0),
          Row(
            children: [
              Icon(
                Icons.group,
                color: Colors.green,
                size: isLargeTablet ? 32.0 : 24.sp,
              ),
              SizedBox(width: isLargeTablet ? 12.0 : 8.0),
              Expanded(
                child: Text(
                  controller.teamName.value,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: isLargeTablet ? 24.0 : 18.sp,
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
          _buildNameAndImageSection(size, context),
          const SizedBox(height: 20),
          _buildPasswordField(context),
          const SizedBox(height: 20),
          _buildConfirmPasswordField(context),
          const SizedBox(height: 20),
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
          validator: (value) => value!.isEmpty
              ? AppLocalizations.of(context)!.fieldMissing
              : null,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.registerEmail,
            hintStyle: const TextStyle(color: Colors.white70),
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
          validator: (value) => value!.isEmpty
              ? AppLocalizations.of(context)!.fieldMissing
              : null,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: AppLocalizations.of(context)!.registerName,
            hintStyle: const TextStyle(color: Colors.white70),
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
    final isLargeTablet = size.width >= 1200;
    final containerSize = isLargeTablet ? 200.0 : size.width * 0.24;

    return Padding(
      padding: EdgeInsets.all(isLargeTablet ? 12.0 : 8.0),
      child: Container(
        width: containerSize,
        height: containerSize,
        decoration: BoxDecoration(
          border: Border.all(
            width: isLargeTablet ? 2.0 : 1.0,
            color: Colors.white,
          ),
          borderRadius: BorderRadius.circular(isLargeTablet ? 24.0 : 16.r),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isLargeTablet ? 24.0 : 16.r),
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
                  size: isLargeTablet ? containerSize * 0.5 : size.width * 0.12,
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
    final isLargeTablet = MediaQuery.of(Get.context!).size.width >= 1200;

    return InkWell(
      onTap: () => controller.showImageDialog(),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.pink,
          border: Border.all(
            width: isLargeTablet ? 3.0 : 2.0,
            color: Colors.white,
          ),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.all(isLargeTablet ? 12.0 : 8.0),
          child: Icon(
            controller.imageFile.value == null
                ? Icons.add_a_photo
                : Icons.edit_outlined,
            color: Colors.white,
            size: isLargeTablet ? 24.0 : 18.0,
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
              ? AppLocalizations.of(context)!.invalidPassword
              : null,
          style: const TextStyle(color: Colors.white),
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
            hintStyle: const TextStyle(color: Colors.white70),
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
              ? AppLocalizations.of(context)!.passwordsDoNotMatch
              : null,
          style: const TextStyle(color: Colors.white),
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
            hintStyle: const TextStyle(color: Colors.white70),
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
      validator: (value) =>
          value!.isEmpty ? AppLocalizations.of(context)!.fieldMissing : null,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context)!.registerPhone,
        hintStyle: const TextStyle(color: Colors.white70),
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
        validator: (value) =>
            value!.isEmpty ? AppLocalizations.of(context)!.fieldMissing : null,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          suffixIcon:
              const Icon(Icons.arrow_downward_rounded, color: Colors.white),
          hintText: AppLocalizations.of(context)!.registerPosition,
          hintStyle: const TextStyle(color: Colors.white70),
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

  Widget _buildLegalChecks(BuildContext context) {
    final isLargeTablet = MediaQuery.of(context).size.width >= 1200;

    return Column(
      children: [
        Obx(() => Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.acceptedTerms.value =
                    !controller.acceptedTerms.value,
                child: CheckboxListTile(
                  value: controller.acceptedTerms.value,
                  onChanged: (value) =>
                      controller.acceptedTerms.value = value ?? false,
                  title: Text(
                    AppLocalizations.of(context)!.acceptTerms,
                    style: TextStyle(
                      fontSize: isLargeTablet ? 18.0 : 14.sp,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Wrap(
                    alignment: WrapAlignment.start,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () => Get.toNamed('/terms-of-service'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isLargeTablet ? 12.0 : 8.0,
                            horizontal: isLargeTablet ? 16.0 : 12.0,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.termsOfService,
                          style: TextStyle(
                            fontSize: isLargeTablet ? 16.0 : 12.sp,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                      Text(
                        ' & ',
                        style: TextStyle(
                          fontSize: isLargeTablet ? 16.0 : 12.sp,
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed('/privacy-policy'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: isLargeTablet ? 12.0 : 8.0,
                            horizontal: isLargeTablet ? 16.0 : 12.0,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.privacyPolicy,
                          style: TextStyle(
                            fontSize: isLargeTablet ? 16.0 : 12.sp,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.white,
                  checkColor: Colors.black,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isLargeTablet ? 24.0 : 16.0,
                    vertical: isLargeTablet ? 12.0 : 8.0,
                  ),
                ),
              ),
            )),
        Obx(() => Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.acceptedDataProcessing.value =
                    !controller.acceptedDataProcessing.value,
                child: CheckboxListTile(
                  value: controller.acceptedDataProcessing.value,
                  onChanged: (value) =>
                      controller.acceptedDataProcessing.value = value ?? false,
                  title: Text(
                    AppLocalizations.of(context)!.acceptDataProcessing,
                    style: TextStyle(
                      fontSize: isLargeTablet ? 18.0 : 14.sp,
                      color: Colors.white,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.white,
                  checkColor: Colors.black,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isLargeTablet ? 24.0 : 16.0,
                    vertical: isLargeTablet ? 12.0 : 8.0,
                  ),
                ),
              ),
            )),
        Obx(() => Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => controller.acceptedAgeRestriction.value =
                    !controller.acceptedAgeRestriction.value,
                child: CheckboxListTile(
                  value: controller.acceptedAgeRestriction.value,
                  onChanged: (value) =>
                      controller.acceptedAgeRestriction.value = value ?? false,
                  title: Text(
                    AppLocalizations.of(context)!.acceptAgeRestriction,
                    style: TextStyle(
                      fontSize: isLargeTablet ? 18.0 : 14.sp,
                      color: Colors.white,
                    ),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Colors.white,
                  checkColor: Colors.black,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: isLargeTablet ? 24.0 : 16.0,
                    vertical: isLargeTablet ? 12.0 : 8.0,
                  ),
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildNotificationPermission(BuildContext context) {
    final isLargeTablet = MediaQuery.of(context).size.width >= 1200;

    return Obx(() => Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => controller.acceptedNotifications.value =
                !controller.acceptedNotifications.value,
            child: CheckboxListTile(
              value: controller.acceptedNotifications.value,
              onChanged: (value) =>
                  controller.acceptedNotifications.value = value ?? false,
              title: Text(
                AppLocalizations.of(context)!.notificationPermissionText,
                style: TextStyle(
                  fontSize: isLargeTablet ? 18.0 : 14.sp,
                  color: Colors.white,
                ),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.white,
              checkColor: Colors.black,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isLargeTablet ? 24.0 : 16.0,
                vertical: isLargeTablet ? 12.0 : 8.0,
              ),
            ),
          ),
        ));
  }

  Widget _buildSignUpButton(BuildContext context) {
    final isLargeTablet = MediaQuery.of(context).size.width >= 1200;

    return Obx(() {
      final canSignUp = controller.acceptedTerms.value &&
          controller.acceptedDataProcessing.value &&
          controller.acceptedAgeRestriction.value;

      return ElevatedButton(
        onPressed: canSignUp
            ? () async {
                if (_signUpFormKey.currentState!.validate()) {
                  controller.signUp();
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSignUp ? AppTheme.primaryColor : Colors.grey,
          padding: EdgeInsets.symmetric(
            horizontal: isLargeTablet ? 60.0 : 40.w,
            vertical: isLargeTablet ? 20.0 : 12.h,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isLargeTablet ? 16.0 : 8.0),
          ),
        ),
        child: Text(
          AppLocalizations.of(context)!.register,
          style: TextStyle(
            color: Colors.white,
            fontSize: isLargeTablet ? 20.0 : 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    });
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
