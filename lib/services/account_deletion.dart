import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:tuncbt/screens/auth/screens/login.dart';

class AccountDeletionService extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<void> deleteAccount(LoginType loginType) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in.');
      }

      // Reauth from user
      await _reauthenticateUser(loginType);

      // Delete from firestore
      await _deleteUserData(user.uid);

      // LoginType deletion
      switch (loginType) {
        case LoginType.apple:
          await _deleteAppleAccount(user);
          break;
        case LoginType.google:
          await _deleteGoogleAccount(user);
          break;
        case LoginType.email:
          await _deleteEmailAccount(user);
          break;
      }

      // Delete from FA
      await user.delete();

      Get.snackbar('Success', 'Your account has been successfully deleted.');
      Get.offAll(() => Login()); //To Login
    } catch (e) {
      print('Error deleting account: $e');
      Get.snackbar('Error', 'Failed to delete account. Please try again.');
    }
  }

  Future<void> _reauthenticateUser(LoginType loginType) async {
    User? user = _auth.currentUser;
    if (user == null) return;

    try {
      switch (loginType) {
        case LoginType.apple:
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
          await user.reauthenticateWithCredential(oauthCredential);
          break;
        case LoginType.google:
          final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
          final GoogleSignInAuthentication? googleAuth =
              await googleUser?.authentication;
          final credential = GoogleAuthProvider.credential(
            accessToken: googleAuth?.accessToken,
            idToken: googleAuth?.idToken,
          );
          await user.reauthenticateWithCredential(credential);
          break;
        case LoginType.email:
          String email = user.email ?? '';
          String password = await _getPasswordFromUser();
          AuthCredential credential =
              EmailAuthProvider.credential(email: email, password: password);
          await user.reauthenticateWithCredential(credential);
          break;
      }
    } catch (e) {
      print('Error during reauthentication: $e');
      throw Exception('Reauthentication failed. Please try again.');
    }
  }

  Future<void> _deleteUserData(String uid) async {
    try {
      // Delete user doc
      await _firestore.collection('users').doc(uid).delete();

      // Delete user related stuff
      await _firestore
          .collection('tasks')
          .where('uploadedBy', isEqualTo: uid)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      await _firestore
          .collection('comments')
          .where('userId', isEqualTo: uid)
          .get()
          .then((snapshot) {
        for (DocumentSnapshot doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      // Diğer ilişkili koleksiyonlar için benzer işlemleri yapın
    } catch (e) {
      throw Exception('Failed to delete user data. Please try again.');
    }
  }

  Future<void> _deleteAppleAccount(User user) async {
    // Apple hesabı için Firebase'de özel bir işlem gerekmez
    // Kullanıcı zaten Firebase Authentication'dan silinecek
    print('Deleting Apple account for user: ${user.uid}');
  }

  Future<void> _deleteGoogleAccount(User user) async {
    try {
      // Google hesabını Firebase'den ayır
      await _googleSignIn.disconnect();
      print('Deleting Google account for user: ${user.uid}');
    } catch (e) {
      print('Error disconnecting Google account: $e');
      // Hata olsa bile ana silme işlemine devam et
    }
  }

  Future<void> _deleteEmailAccount(User user) async {
    // Email hesabı için Firebase'de özel bir işlem gerekmez
    // Kullanıcı zaten Firebase Authentication'dan silinecek
    print('Deleting Email account for user: ${user.uid}');
  }

  Future<String> _getPasswordFromUser() async {
    String password = '';
    await Get.dialog(
      AlertDialog(
        title: Text('Confirm Password'),
        content: TextField(
          obscureText: true,
          onChanged: (value) {
            password = value;
          },
          decoration: InputDecoration(hintText: "Enter your password"),
        ),
        actions: [
          TextButton(
            child: Text('Confirm'),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
    return password;
  }
}

enum LoginType { email, google, apple }
