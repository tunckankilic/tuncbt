import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:tuncbt/models/user_model.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tuncbt/config/constants.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:tuncbt/screens/auth/screens/register.dart';
import 'package:tuncbt/screens/screens.dart';

class AuthController extends GetxController with GetTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final forgetPassTextController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final positionCPController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final obscureText = true.obs;
  final isLoading = false.obs;
  final imageFile = Rx<File?>(null);
  final isSocialSignIn = false.obs;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late AnimationController _animationController;
  late Animation<double> _animation;
  final animationValue = 0.0.obs;
  final socialMediaPhotoUrl = ''.obs;
  @override
  void onInit() {
    super.onInit();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20));
    _animation =
        CurvedAnimation(parent: _animationController, curve: Curves.linear)
          ..addListener(() {
            animationValue.value = _animation.value;
          })
          ..addStatusListener((animationStatus) {
            if (animationStatus == AnimationStatus.completed) {
              _animationController.reset();
              _animationController.forward();
            }
          });
    _animationController.forward();
  }

  @override
  void onClose() {
    _animationController.dispose();
    emailController.dispose();
    passwordController.dispose();
    forgetPassTextController.dispose();
    fullNameController.dispose();
    phoneNumberController.dispose();
    positionCPController.dispose();
    super.onClose();
  }

  void toggleObscureText() => obscureText.toggle();

  Future<void> login() async {
    isLoading.value = true;
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text.trim(),
      );
      Get.offAllNamed(TasksScreen.routeName);
    } catch (error) {
      Get.snackbar('Error', error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword() async {
    isLoading.value = true;
    try {
      await _auth.sendPasswordResetEmail(
        email: forgetPassTextController.text.trim().toLowerCase(),
      );
      Get.snackbar('Success', 'Password reset email sent');
      Get.back();
    } catch (error) {
      Get.snackbar('Error', error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUp({bool isSocial = false}) async {
    isLoading.value = true;
    try {
      String uid = _auth.currentUser?.uid ?? '';
      String imageUrl = '';

      if (!isSocial) {
        UserCredential authResult = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim().toLowerCase(),
          password: passwordController.text.trim(),
        );
        uid = authResult.user!.uid;
      }

      if (imageFile.value != null) {
        String fileName = '$uid.jpg';
        Reference storageRef =
            _storage.ref().child('userImages').child(fileName);
        await storageRef.putFile(imageFile.value!);
        imageUrl = await storageRef.getDownloadURL();
      } else if (isSocial) {
        imageUrl = _auth.currentUser?.photoURL ?? '';
      }

      UserModel newUser = UserModel(
        id: uid,
        name: fullNameController.text,
        email: emailController.text,
        userImage: imageUrl,
        phoneNumber: phoneNumberController.text,
        positionInCompany: positionCPController.text,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(uid).set(newUser.toFirestore());

      if (!isSocial) {
        await _auth.currentUser!.updateDisplayName(newUser.name);
        await _auth.currentUser!.updatePhotoURL(newUser.userImage);
        await _auth.currentUser!.reload();
      }

      Get.offAllNamed(TasksScreen.routeName);
    } catch (error) {
      Get.snackbar('Error', error.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser!.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      await _checkAndCreateUser(userCredential.user!);
    } catch (error) {
      Get.snackbar('Error', error.toString());
    }
  }

  Future<void> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      UserCredential userCredential =
          await _auth.signInWithCredential(oauthCredential);
      await _checkAndCreateUser(userCredential.user!);
    } catch (error) {
      Get.snackbar('Error', error.toString());
    }
  }

  Future<void> _checkAndCreateUser(User user) async {
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();

    if (!userDoc.exists ||
        !_isUserDataComplete(userDoc.data() as Map<String, dynamic>?)) {
      isSocialSignIn.value = true;
      fullNameController.text = user.displayName ?? '';
      emailController.text = user.email ?? '';
      if (user.photoURL != null) {
        await _downloadAndSetProfileImage(user.photoURL!);
      }
      Get.offAll(() => SignUp()); // SignUp sayfasına yönlendir
    } else {
      Get.offAllNamed(TasksScreen.routeName);
    }
  }

  bool _isUserDataComplete(Map<String, dynamic>? userData) {
    return userData != null &&
        userData['name'] != null &&
        userData['email'] != null &&
        userData['phoneNumber'] != null &&
        userData['positionInCompany'] != null;
  }

  Future<void> _downloadAndSetProfileImage(String url) async {
    try {
      final response = await http.get(Uri.parse(url));
      final documentDirectory = await getApplicationDocumentsDirectory();
      final file = File('${documentDirectory.path}/profile.jpg');
      file.writeAsBytesSync(response.bodyBytes);
      imageFile.value = file;
    } catch (e) {
      print("Error downloading profile image: $e");
    }
  }

  void showImageDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Please choose an option'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () => getImage(ImageSource.camera),
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.camera, color: Colors.purple),
                  ),
                  Text('Camera', style: TextStyle(color: Colors.purple)),
                ],
              ),
            ),
            InkWell(
              onTap: () => getImage(ImageSource.gallery),
              child: const Row(
                children: [
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.image, color: Colors.purple),
                  ),
                  Text('Gallery', style: TextStyle(color: Colors.purple)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      maxHeight: 1080,
      maxWidth: 1080,
    );
    if (pickedFile != null) {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        maxHeight: 1080,
        maxWidth: 1080,
      );
      if (croppedFile != null) {
        imageFile.value = File(croppedFile.path);
      }
    }
    Get.back();
  }

  void showJobCategoriesDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Choose your Job',
            style: TextStyle(fontSize: 20, color: Colors.pink.shade800)),
        content: SizedBox(
          width: Get.width * 0.9,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: Constants.jobsList.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  positionCPController.text = Constants.jobsList[index];
                  Get.back();
                },
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: Colors.red[900],
                      ),
                      child: Text(
                        index.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        Constants.jobsList[index],
                        style: TextStyle(
                            color: Constants.darkBlue,
                            fontSize: 18,
                            fontStyle: FontStyle.italic),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget defaultImage() {
    return Image.network(
      'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png',
      fit: BoxFit.cover,
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    Get.offAllNamed('/login');
  }
}
