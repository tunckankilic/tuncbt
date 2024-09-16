import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tuncbt/screens/auth/auth_controller.dart';

class SignUp extends GetView<AuthController> {
  static const routeName = "/register";

  SignUp({Key? key}) : super(key: key);

  final _signUpFormKey = GlobalKey<FormState>();

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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              children: [
                SizedBox(height: size.height * 0.1),
                Text(
                  controller.isSocialSignIn.value
                      ? 'Complete Your Profile'
                      : 'Register',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30.sp),
                ),
                const SizedBox(height: 10),
                if (!controller.isSocialSignIn.value)
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Already have an account',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 24.sp),
                        ),
                        const TextSpan(text: '    '),
                        TextSpan(
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => Get.back(),
                          text: 'Login',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            color: Colors.red[200],
                            fontWeight: FontWeight.bold,
                            fontSize: 20.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 20.h),
                Form(
                  key: _signUpFormKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: TextFormField(
                              controller: controller.fullNameController,
                              validator: (value) => value!.isEmpty
                                  ? "This Field is missing"
                                  : null,
                              style: const TextStyle(color: Colors.black),
                              decoration: const InputDecoration(
                                hintText: 'Full name',
                                hintStyle: TextStyle(color: Colors.black),
                                enabledBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                errorBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red)),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: size.width * 0.24,
                              height: size.width * 0.24,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.white),
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
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                        Icons.person,
                                        size: size.width * 0.12,
                                        color: Colors.grey,
                                      ),
                                    );
                                  }
                                }),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () => controller.showImageDialog(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.pink,
                                  border:
                                      Border.all(width: 2, color: Colors.white),
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
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (!controller.isSocialSignIn.value)
                        Obx(() => TextFormField(
                              controller: controller.passwordController,
                              obscureText: controller.obscureText.value,
                              validator: (value) =>
                                  value!.isEmpty || value.length < 7
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
                                hintText: 'Password',
                                hintStyle: const TextStyle(color: Colors.black),
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                focusedBorder: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                errorBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red)),
                              ),
                            )),
                      const SizedBox(height: 20),
                      if (!controller.isSocialSignIn.value)
                        Obx(() => TextFormField(
                              controller: controller.passwordController,
                              obscureText: controller.obscureText.value,
                              validator: (value) =>
                                  value!.isEmpty || value.length < 7
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
                                hintText: 'Password',
                                hintStyle: const TextStyle(color: Colors.black),
                                enabledBorder: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                focusedBorder: const UnderlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.white)),
                                errorBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red)),
                              ),
                            )),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: controller.phoneNumberController,
                        validator: (value) =>
                            value!.isEmpty ? "This Field is missing" : null,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          hintText: 'Phone number',
                          hintStyle: TextStyle(color: Colors.black),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          errorBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.red)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => controller.showJobCategoriesDialog(),
                        child: TextFormField(
                          enabled: false,
                          controller: controller.positionCPController,
                          validator: (value) =>
                              value!.isEmpty ? "This field is missing" : null,
                          style: const TextStyle(color: Colors.black),
                          decoration: const InputDecoration(
                            suffixIcon: Icon(Icons.arrow_downward_rounded,
                                color: Colors.black),
                            hintText: 'Position in the company',
                            hintStyle: TextStyle(color: Colors.black),
                            enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                            errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red)),
                            disabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                Obx(() => controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : MaterialButton(
                        onPressed: () {
                          if (_signUpFormKey.currentState!.validate()) {
                            controller.signUp(
                                isSocial: controller.isSocialSignIn.value);
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
                                    : 'SignUp',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.sp),
                              ),
                              SizedBox(width: 16.r),
                              Icon(Icons.person_add,
                                  color: Colors.white, size: 30.r),
                            ],
                          ),
                        ),
                      )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
