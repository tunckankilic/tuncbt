import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/core/enums/team_role.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/view/screens/auth/screens/login.dart';
import 'package:tuncbt/view/screens/auth/screens/register.dart';
import 'package:tuncbt/view/screens/screens.dart';
import 'package:tuncbt/core/config/constants.dart' as app_constants;
import 'package:tuncbt/core/config/firebase_constants.dart';
import 'package:tuncbt/utils/team_errors.dart';
import 'package:mime/mime.dart';
import 'package:tuncbt/view/widgets/loading_screen.dart';
import 'package:tuncbt/core/services/referral_service.dart';
import 'package:tuncbt/core/models/team.dart';

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
  final referralCodeController = TextEditingController();

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

  // Legal checks
  final acceptedTerms = false.obs;
  final acceptedDataProcessing = false.obs;
  final acceptedAgeRestriction = false.obs;
  final acceptedNotifications = false.obs;

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
    referralCodeController.dispose();
    super.onClose();
  }

  void toggleObscureText() => obscureText.toggle();

  String _getReadableAuthError(FirebaseAuthException e) {
    final context = Get.context!;
    switch (e.code) {
      case 'user-not-found':
        return AppLocalizations.of(context)!.authErrorUserNotFound;
      case 'wrong-password':
        return AppLocalizations.of(context)!.authErrorWrongPassword;
      case 'invalid-email':
        return AppLocalizations.of(context)!.authErrorInvalidEmail;
      case 'user-disabled':
        return AppLocalizations.of(context)!.authErrorUserDisabled;
      case 'email-already-in-use':
        return AppLocalizations.of(context)!.authErrorEmailInUse;
      case 'operation-not-allowed':
        return AppLocalizations.of(context)!.authErrorOperationNotAllowed;
      case 'weak-password':
        return AppLocalizations.of(context)!.authErrorWeakPassword;
      case 'network-request-failed':
        return AppLocalizations.of(context)!.authErrorNetworkFailed;
      case 'too-many-requests':
        return AppLocalizations.of(context)!.authErrorTooManyRequests;
      case 'invalid-credential':
        return AppLocalizations.of(context)!.authErrorInvalidCredential;
      case 'account-exists-with-different-credential':
        return AppLocalizations.of(context)!.authErrorAccountExists;
      case 'invalid-verification-code':
        return AppLocalizations.of(context)!.authErrorInvalidVerificationCode;
      case 'invalid-verification-id':
        return AppLocalizations.of(context)!.authErrorInvalidVerificationId;
      case 'quota-exceeded':
        return AppLocalizations.of(context)!.authErrorQuotaExceeded;
      case 'credential-already-in-use':
        return AppLocalizations.of(context)!.authErrorCredentialInUse;
      case 'requires-recent-login':
        return AppLocalizations.of(context)!.authErrorRequiresRecentLogin;
      default:
        return AppLocalizations.of(context)!.authErrorGeneric;
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
    if (code.isEmpty) {
      teamName.value = '';
      _referralCode = null;
      _teamId = null;
      _invitedBy = null;
      return;
    }

    _referralCode = code;
    await _validateAndLoadTeamInfo();
  }

  Future<void> _validateAndLoadTeamInfo() async {
    if (_referralCode == null) return;

    isTeamLoading.value = true;
    try {
      final referralService = ReferralService();
      final validationResult =
          await referralService.validateCode(_referralCode!);

      if (validationResult.isValid && validationResult.teamId != null) {
        _teamId = validationResult.teamId;
        _invitedBy = validationResult.createdBy;

        final teamDoc = await _firestore.collection('teams').doc(_teamId).get();
        if (teamDoc.exists) {
          teamName.value = teamDoc.data()?['name'] ?? '';
        }
      } else {
        teamName.value = '';
        _teamId = null;
        _invitedBy = null;

        if (validationResult.error != null) {
          Get.snackbar(
            'Hata',
            validationResult.error!.message,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
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

  Future<String?> _uploadProfileImage(String uid, File imageFile) async {
    try {
      print('Profil resmi yükleme işlemi başlatılıyor...');

      // Resim boyutunu kontrol et
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Resim boyutu 10MB\'dan büyük olamaz');
      }

      // Resim formatını kontrol et
      final fileType = lookupMimeType(imageFile.path);
      if (fileType == null || !fileType.startsWith('image/')) {
        throw Exception(
            'Geçersiz dosya formatı. Sadece resim dosyaları yüklenebilir.');
      }

      // Storage referansını oluştur
      final fileName = '$uid.jpg';
      final storageRef =
          _storage.ref().child('profilePics').child(uid).child(fileName);

      // Resmi yükle
      print('Resim yükleniyor...');
      final uploadTask = await storageRef.putFile(
        imageFile,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': uid,
            'timestamp': DateTime.now().toIso8601String(),
          },
        ),
      );

      if (uploadTask.state == TaskState.success) {
        // Download URL'yi al
        final downloadUrl = await storageRef.getDownloadURL();
        print('Profil resmi başarıyla yüklendi: $downloadUrl');
        return downloadUrl;
      } else {
        throw Exception('Resim yükleme başarısız oldu');
      }
    } catch (e) {
      print('Profil resmi yükleme hatası: $e');
      rethrow;
    }
  }

  Future<void> signUp({bool isSocial = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;

    try {
      String uid = _auth.currentUser?.uid ?? '';
      String imageUrl = '';

      // Loading ekranını göster
      Get.to(() => LoadingScreen(
            message: AppLocalizations.of(Get.context!)!.creatingTeam,
          ));

      if (!isSocial) {
        print('Kayıt işlemi başlatılıyor...');
        UserCredential authResult = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim().toLowerCase(),
          password: passwordController.text.trim(),
        );
        uid = authResult.user!.uid;
        print('Firebase Auth kaydı başarılı. UID: $uid');
      }

      if (imageFile.value != null) {
        print('Profil resmi yükleniyor...');
        try {
          imageUrl = await _uploadProfileImage(uid, imageFile.value!) ?? '';
        } catch (e) {
          print('Profil resmi yükleme hatası: $e');
        }
      } else if (isSocial) {
        imageUrl = _auth.currentUser?.photoURL ?? '';
      }

      if (_referralCode == null) {
        print('Yeni takım oluşturuluyor...');
        // Yeni takım oluştur
        DocumentReference teamRef = await _firestore.collection('teams').add({
          'name': '${fullNameController.text}\'s Team',
          'createdAt': FieldValue.serverTimestamp(),
          'createdBy': uid,
          'memberCount': 1,
          'isActive': true,
        });
        print('Takım oluşturuldu. Team ID: ${teamRef.id}');

        // Kullanıcıyı admin olarak kaydet
        UserModel newUser = UserModel(
          id: uid,
          name: fullNameController.text,
          email: emailController.text,
          imageUrl: imageUrl,
          phoneNumber: phoneNumberController.text,
          position: positionCPController.text,
          createdAt: DateTime.now(),
          hasTeam: true,
          teamId: teamRef.id,
          teamRole: TeamRole.admin,
        );

        print('Kullanıcı bilgileri Firestore\'a kaydediliyor...');
        await _firestore
            .collection('users')
            .doc(uid)
            .set(newUser.toFirestore());
        print('Kullanıcı bilgileri kaydedildi');

        // Takım üyeleri koleksiyonuna ekle
        print('Takım üyeliği oluşturuluyor...');
        await _firestore
            .collection('team_members')
            .doc('${teamRef.id}_$uid')
            .set({
          'userId': uid,
          'teamId': teamRef.id,
          'role': TeamRole.admin.toString().split('.').last,
          'joinedAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });
        print('Takım üyeliği oluşturuldu');
      } else {
        print('Mevcut takıma katılma işlemi başlatılıyor...');
        print('Referans kodu: $_referralCode, Team ID: $_teamId');

        if (_teamId == null) {
          throw TeamValidationException('Team not found');
        }

        // Takımın var olduğunu kontrol et
        final teamDoc = await _firestore.collection('teams').doc(_teamId).get();
        if (!teamDoc.exists || !(teamDoc.data()?['isActive'] ?? false)) {
          throw TeamValidationException('Team not found or inactive');
        }

        print('Takım kontrolü başarılı. Takım aktif.');

        // Takım kapasitesini kontrol et
        final currentMemberCount = teamDoc.data()?['memberCount'] ?? 0;
        if (currentMemberCount >= app_constants.Constants.maxTeamSize) {
          throw TeamCapacityException();
        }

        UserModel newUser = UserModel(
          id: uid,
          name: fullNameController.text,
          email: emailController.text,
          imageUrl: imageUrl,
          phoneNumber: phoneNumberController.text,
          position: positionCPController.text,
          createdAt: DateTime.now(),
          hasTeam: true,
          teamId: _teamId,
          invitedBy: _invitedBy,
          teamRole: TeamRole.member,
        );

        print('Kullanıcı bilgileri Firestore\'a kaydediliyor...');
        await _firestore
            .collection('users')
            .doc(uid)
            .set(newUser.toFirestore());
        print('Kullanıcı bilgileri kaydedildi');

        print('Takım üyeliği oluşturuluyor...');
        await _firestore.collection('team_members').doc('${_teamId}_$uid').set({
          'userId': uid,
          'teamId': _teamId,
          'role': TeamRole.member.toString().split('.').last,
          'joinedAt': FieldValue.serverTimestamp(),
          'isActive': true,
          'invitedBy': _invitedBy,
        });
        print('Takım üyeliği oluşturuldu');

        print('Takım üye sayısı güncelleniyor...');
        await _firestore.collection('teams').doc(_teamId).update({
          'memberCount': FieldValue.increment(1),
        });
        print('Takım üye sayısı güncellendi');

        if (_referralCode != null) {
          print('Referans kodu güncelleniyor...');
          await _firestore
              .collection('referral_codes')
              .doc(_referralCode)
              .update({
            'usedBy': uid,
            'usedAt': FieldValue.serverTimestamp(),
            'isActive': false,
          });
          print('Referans kodu güncellendi');
        }
      }

      if (!isSocial) {
        print('Firebase Auth profili güncelleniyor...');
        await _auth.currentUser!.updateDisplayName(fullNameController.text);
        await _auth.currentUser!.updatePhotoURL(imageUrl);
        await _auth.currentUser!.reload();
        print('Firebase Auth profili güncellendi');
      }

      print('Kayıt işlemi başarılı, TasksScreen\'e yönlendiriliyor...');
      await Future.delayed(const Duration(seconds: 1));
      Get.offAllNamed(TasksScreen.routeName);
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      Get.back(); // Loading ekranını kapat
      Get.snackbar(
        'Kayıt Başarısız',
        _getReadableAuthError(e),
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } catch (error) {
      print('Beklenmeyen hata: $error');
      print('Hata detayı: ${error.toString()}');
      print('Stack trace: ${StackTrace.current}');
      Get.back(); // Loading ekranını kapat
      Get.snackbar(
        'Hata',
        'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isLoading.value = false;
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
