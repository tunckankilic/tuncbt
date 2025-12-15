import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:tuncbt/core/models/user_model.dart';

enum AuthStatus {
  unknown,
  authenticated,
  unauthenticated,
  authenticatedWithoutTeam,
}

class AuthService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable state
  final Rx<AuthStatus> authStatus = AuthStatus.unknown.obs;
  final Rx<User?> firebaseUser = Rx<User?>(null);
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool hasTeam = false.obs;
  final RxBool isLoading = false.obs;

  // Kayıt işlemi devam ediyor bayrağı
  bool _registrationInProgress = false;

  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeAuthState();
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  void _initializeAuthState() {
    // Firebase auth state changes'i dinle
    _authSubscription = _auth.authStateChanges().listen(_handleAuthStateChange);
  }

  Future<void> _handleAuthStateChange(User? user) async {
    print('AuthService: Auth state değişti - User: ${user?.uid}');

    firebaseUser.value = user;

    if (user == null) {
      // Kullanıcı çıkış yapmış
      authStatus.value = AuthStatus.unauthenticated;
      currentUser.value = null;
      hasTeam.value = false;
      return;
    }

    isLoading.value = true;

    try {
      // Kullanıcı bilgilerini yükle
      await _loadUserData(user.uid);

      // Team durumunu kontrol et
      await _checkTeamStatus(user.uid);

      // Auth status'u belirle
      if (hasTeam.value) {
        authStatus.value = AuthStatus.authenticated;
      } else {
        authStatus.value = AuthStatus.authenticatedWithoutTeam;
      }
    } catch (e) {
      print('AuthService Error: $e');
      authStatus.value = AuthStatus.unauthenticated;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadUserData(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        currentUser.value = UserModel.fromFirestore(userDoc);
        print(
            'AuthService: Kullanıcı verileri yüklendi - ${currentUser.value?.name}');
      } else {
        print('AuthService: Kullanıcı dokümanı bulunamadı');

        // Eğer kayıt işlemi devam ediyorsa, bekle
        if (_registrationInProgress) {
          print(
              'AuthService: Kayıt işlemi devam ediyor, otomatik çıkış yapılmayacak');
          return;
        }

        print(
            'AuthService: Kullanıcı Firebase Auth\'da var ama Firestore\'da yok - Otomatik çıkış yapılıyor');

        // Kullanıcı Firebase Auth'da var ama Firestore'da yok
        // Bu durum kayıt sırasında hata olduğunu gösterir
        // Kullanıcıyı çıkış yaptır
        currentUser.value = null;
        await _auth.signOut();
        return;
      }
    } catch (e) {
      print('AuthService: Kullanıcı verileri yüklenirken hata: $e');
      currentUser.value = null;

      // Kayıt işlemi devam ediyorsa çıkış yapma
      if (_registrationInProgress) {
        print(
            'AuthService: Kayıt işlemi devam ediyor, hata durumunda da çıkış yapılmayacak');
        return;
      }

      // Kritik bir hata durumunda da çıkış yap
      try {
        await _auth.signOut();
      } catch (signOutError) {
        print('AuthService: Çıkış yapılırken hata: $signOutError');
      }
    }
  }

  Future<void> _checkTeamStatus(String userId) async {
    try {
      if (currentUser.value == null) {
        hasTeam.value = false;
        return;
      }

      final userData = currentUser.value!;

      // Kullanıcının takım bilgisi var mı?
      if (!userData.hasTeam || userData.teamId == null) {
        hasTeam.value = false;
        return;
      }

      // Takım hala var mı?
      final teamDoc =
          await _firestore.collection('teams').doc(userData.teamId).get();

      if (!teamDoc.exists || !(teamDoc.data()?['isActive'] ?? true)) {
        // Takım silinmiş, kullanıcı bilgilerini güncelle
        await _firestore.collection('users').doc(userId).update({
          'hasTeam': false,
          'teamId': null,
          'teamRole': null,
        });

        // Local state'i güncelle
        await _loadUserData(userId);
        hasTeam.value = false;
        return;
      }

      hasTeam.value = true;
      print('AuthService: Takım durumu - HasTeam: ${hasTeam.value}');
    } catch (e) {
      print('AuthService: Takım durumu kontrolünde hata: $e');
      hasTeam.value = false;
    }
  }

  // Public methods for auth operations
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      // Auth state change listener otomatik olarak handle edecek
    } catch (e) {
      print('AuthService: Çıkış hatası: $e');
      rethrow;
    }
  }

  Future<void> refreshUserData() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _handleAuthStateChange(user);
    }
  }

  // Kayıt işlemi kontrolü için metodlar
  void setRegistrationInProgress(bool value) {
    _registrationInProgress = value;
    print('AuthService: Kayıt işlemi bayrağı: $_registrationInProgress');
  }

  // Getter methods
  bool get isAuthenticated => authStatus.value == AuthStatus.authenticated;
  bool get isUnauthenticated => authStatus.value == AuthStatus.unauthenticated;
  bool get needsTeam => authStatus.value == AuthStatus.authenticatedWithoutTeam;
  bool get isUnknown => authStatus.value == AuthStatus.unknown;
  String? get userId => firebaseUser.value?.uid;
}
