import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/core/enums/team_role.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:tuncbt/view/screens/auth/screens/login.dart';
import 'package:tuncbt/view/screens/auth/screens/register.dart';
import 'package:tuncbt/view/screens/screens.dart';

class AuthController extends GetxController with GetTickerProviderStateMixin {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final forgetPassTextController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final positionCPController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final obscureText = true.obs;
  final isLoading = false.obs;
  final imageFile = Rx<File?>(null);
  final isSocialSignIn = false.obs;
  String? intialNameValue;
  String? initialEmailValue;

  final GlobalKey<FormState> emailKey = GlobalKey<FormState>();
  final GlobalKey<FormState> passKay = GlobalKey<FormState>();
  final GlobalKey<FormState> passRKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  late Animation<double> _animation;
  final animationValue = 0.0.obs;
  final socialMediaPhotoUrl = ''.obs;

  final teamName = ''.obs;
  final isTeamLoading = false.obs;
  final hasTeam = false.obs;
  String? _referralCode;
  String? _teamId;
  String? _invitedBy;

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
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleObscureText() => obscureText.toggle();

  String _getReadableAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'email-already-in-use':
        return 'This email address is already in use.';
      case 'operation-not-allowed':
        return 'This operation is not allowed at the moment.';
      case 'weak-password':
        return 'The password is too weak. Please choose a stronger password.';
      case 'network-request-failed':
        return 'Network connection error. Please check your internet connection.';
      case 'too-many-requests':
        return 'Too many failed login attempts. Please try again later.';
      case 'invalid-credential':
        return 'Invalid credentials.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with this email using a different sign-in method.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID.';
      case 'quota-exceeded':
        return 'Quota exceeded. Please try again later.';
      case 'credential-already-in-use':
        return 'These credentials are already associated with another account.';
      case 'requires-recent-login':
        return 'This operation requires a recent login. Please log out and log in again.';
      default:
        return 'An error occurred. Please try again.';
    }
  }

  void _showLoadingOverlay() {
    Get.dialog(
      Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
  }

  void _hideLoadingOverlay() {
    if (Get.isDialogOpen!) {
      Get.back();
    }
  }

  Future<void> _checkTeamStatus(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final userData = UserModel.fromFirestore(userDoc);
      hasTeam.value = userData.hasTeam;

      if (userData.hasTeam && userData.teamId != null) {
        final teamDoc =
            await _firestore.collection('teams').doc(userData.teamId).get();
        if (!teamDoc.exists) {
          // Takım silinmiş, kullanıcı bilgilerini güncelle
          await _firestore.collection('users').doc(userId).update({
            'hasTeam': false,
            'teamId': null,
            'teamRole': null,
          });
          hasTeam.value = false;
        }
      }
    } catch (e) {
      print('Error checking team status: $e');
      hasTeam.value = false;
    }
  }

  Future<void> login() async {
    if (isLoading.value) return;
    if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
      isLoading.value = true;
      _showLoadingOverlay();
      try {
        final userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim().toLowerCase(),
          password: passwordController.text.trim(),
        );

        await _checkTeamStatus(userCredential.user!.uid);

        emailController.text = "";
        passwordController.text = "";

        if (hasTeam.value) {
          Get.offAllNamed(TasksScreen.routeName);
        } else {
          Get.offAllNamed('/auth/referral');
        }
      } on FirebaseAuthException catch (e) {
        Get.snackbar('Giriş Başarısız', _getReadableAuthError(e));
      } catch (error) {
        Get.snackbar(
            'Hata', 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.');
      } finally {
        isLoading.value = false;
        _hideLoadingOverlay();
      }
    } else {
      Get.snackbar("Hata", "Lütfen tüm alanları doldurun",
          colorText: Colors.white);
      return;
    }
  }

  Future<void> resetPassword() async {
    if (isLoading.value) return;
    isLoading.value = true;
    _showLoadingOverlay();
    try {
      await _auth.sendPasswordResetEmail(
        email: forgetPassTextController.text.trim().toLowerCase(),
      );
      Get.snackbar('Success', 'Password reset email sent');
      Get.toNamed(Login.routeName);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Password Reset Failed', _getReadableAuthError(e));
    } catch (error) {
      Get.snackbar('Error', 'An unexpected error occurred. Please try again.');
    } finally {
      isLoading.value = false;
      _hideLoadingOverlay();
    }
  }

  void setReferralCode(String code) async {
    _referralCode = code;
    await _validateAndLoadTeamInfo();
  }

  Future<void> _validateAndLoadTeamInfo() async {
    if (_referralCode == null) return;

    isTeamLoading.value = true;
    try {
      final referralDoc = await _firestore
          .collection('referral_codes')
          .doc(_referralCode)
          .get();

      if (referralDoc.exists && !referralDoc.data()?['isUsed']) {
        _teamId = referralDoc.data()?['teamId'];
        _invitedBy = referralDoc.data()?['createdBy'];

        if (_teamId != null) {
          final teamDoc =
              await _firestore.collection('teams').doc(_teamId).get();

          if (teamDoc.exists) {
            teamName.value = teamDoc.data()?['name'] ?? '';
          }
        }
      }
    } catch (e) {
      print('Error validating referral code: $e');
      Get.snackbar(
        'Hata',
        'Referans kodu doğrulanırken bir hata oluştu.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isTeamLoading.value = false;
    }
  }

  Future<void> signUp({bool isSocial = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    _showLoadingOverlay();
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
        imageUrl: imageUrl,
        phoneNumber: phoneNumberController.text,
        position: positionCPController.text,
        createdAt: DateTime.now(),
        hasTeam: _teamId != null,
        teamId: _teamId,
        invitedBy: _invitedBy,
        teamRole: _teamId != null ? TeamRole.member : null,
      );

      await _firestore.collection('users').doc(uid).set(newUser.toFirestore());

      if (_referralCode != null) {
        await _firestore
            .collection('referral_codes')
            .doc(_referralCode)
            .update({
          'isUsed': true,
          'usedBy': uid,
          'usedAt': FieldValue.serverTimestamp(),
        });
      }

      if (!isSocial) {
        await _auth.currentUser!.updateDisplayName(newUser.name);
        await _auth.currentUser!.updatePhotoURL(newUser.imageUrl);
        await _auth.currentUser!.reload();
      }

      Get.offAllNamed(TasksScreen.routeName);
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Kayıt Başarısız', _getReadableAuthError(e));
    } catch (error) {
      Get.snackbar(
          'Hata', 'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.');
    } finally {
      isLoading.value = false;
      _hideLoadingOverlay();
    }
  }

  // Future<void> signInWithGoogle() async {
  //   if (isLoading.value) return;
  //   isLoading.value = true;
  //   _showLoadingOverlay();
  //   try {
  //     final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser!.authentication;
  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //     initialEmailValue = googleUser.email;
  //     intialNameValue = googleUser.displayName;
  //     UserCredential userCredential =
  //         await _auth.signInWithCredential(credential);
  //     await _checkAndCreateUser(userCredential.user!);
  //   } on FirebaseAuthException catch (e) {
  //     Get.snackbar('Google Sign In Failed', _getReadableAuthError(e));
  //   } catch (error) {
  //     Get.snackbar('Error',
  //         'An error occurred during Google sign in. Please try again.');
  //   } finally {
  //     isLoading.value = false;
  //     _hideLoadingOverlay();
  //   }
  // }

  // Future<void> signInWithApple() async {
  //   if (isLoading.value) return;
  //   isLoading.value = true;
  //   _showLoadingOverlay();
  //   try {
  //     final appleCredential = await SignInWithApple.getAppleIDCredential(
  //       scopes: [
  //         AppleIDAuthorizationScopes.email,
  //         AppleIDAuthorizationScopes.fullName,
  //       ],
  //     );
  //     final oauthCredential = OAuthProvider("apple.com").credential(
  //       idToken: appleCredential.identityToken,
  //       accessToken: appleCredential.authorizationCode,
  //     );
  //     UserCredential userCredential =
  //         await _auth.signInWithCredential(oauthCredential);
  //     await _checkAndCreateUser(userCredential.user!);
  //   } on FirebaseAuthException catch (e) {
  //     Get.snackbar('Apple Sign In Failed', _getReadableAuthError(e));
  //   } catch (error) {
  //     Get.snackbar(
  //         'Error', 'An error occurred during Apple sign in. Please try again.');
  //   } finally {
  //     isLoading.value = false;
  //     _hideLoadingOverlay();
  //   }
  // }

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
      Get.offAll(() => SignUp());
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
      // Direkt olarak File nesnesini kullan
      imageFile.value = File(pickedFile.path);
      Get.back();
    }
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
    try {
      await _auth.signOut();
      hasTeam.value = false;
      Get.offAllNamed('/login');
    } catch (error) {
      Get.snackbar(
          'Hata', 'Çıkış yapılırken bir hata oluştu. Lütfen tekrar deneyin.');
    }
  }
}
