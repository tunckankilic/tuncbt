import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncbt/core/services/team_service_controller.dart';
import 'package:tuncbt/core/services/firebase_listener_service.dart';
import 'package:tuncbt/core/services/cache_service.dart';

class LogoutService extends GetxService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Services
  late final TeamServiceController _teamService;
  late final FirebaseListenerService _listenerService;
  late final CacheService _cacheService;

  // State
  final RxBool isLoggingOut = false.obs;
  final RxString logoutError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  void _initializeServices() {
    _teamService = Get.find<TeamServiceController>();
    _listenerService = Get.find<FirebaseListenerService>();
    _cacheService = Get.find<CacheService>();
  }

  Future<bool> logout() async {
    if (isLoggingOut.value) {
      print('LogoutService: Çıkış işlemi zaten devam ediyor');
      return false;
    }

    try {
      isLoggingOut.value = true;
      logoutError.value = '';

      print('LogoutService: Çıkış işlemi başlatılıyor...');

      // 1. Update online status
      await _updateOnlineStatus(false);

      // 2. Clear team listeners
      _listenerService.clearTeamListeners();

      // 3. Clear team data
      await _teamService.clearTeamData();

      // 4. Clear cache
      await _cacheService.clearAllCache();

      // 5. Sign out from Firebase
      await _auth.signOut();

      // 6. AuthService will handle navigation via UserState - no need to navigate manually
      // UserState is listening to AuthService and will automatically navigate to Login
      print('LogoutService: Çıkış işlemi başarılı');
      return true;
    } catch (e) {
      print('LogoutService: Çıkış hatası - $e');
      logoutError.value = 'Çıkış yapılırken bir hata oluştu: $e';
      return false;
    } finally {
      isLoggingOut.value = false;
    }
  }

  Future<void> _updateOnlineStatus(bool isOnline) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final batch = _firestore.batch();

      // Update user document
      batch.update(
        _firestore.collection('users').doc(user.uid),
        {
          'isOnline': isOnline,
          'lastSeen': FieldValue.serverTimestamp(),
        },
      );

      // Update team member document if exists
      final teamId = _teamService.teamId;
      if (teamId != null) {
        batch.update(
          _firestore.collection('team_members').doc('${teamId}_${user.uid}'),
          {
            'isOnline': isOnline,
            'lastSeen': FieldValue.serverTimestamp(),
          },
        );
      }

      await batch.commit();
      print('LogoutService: Online durumu güncellendi - isOnline: $isOnline');
    } catch (e) {
      print('LogoutService: Online durumu güncelleme hatası - $e');
    }
  }

  // Force logout (for account deletion, ban, etc.)
  Future<bool> forceLogout({String? reason}) async {
    print('LogoutService: Zorunlu çıkış başlatılıyor - Sebep: $reason');

    try {
      // Clear all data first
      await _cacheService.clearAllCache();
      _listenerService.clearTeamListeners();
      await _teamService.clearTeamData();

      // Then sign out
      await _auth.signOut();

      // UserState will handle navigation automatically
      // Show message via snackbar
      Get.snackbar(
        'Bildirim',
        reason ?? 'Oturumunuz sonlandırıldı',
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );

      print('LogoutService: Zorunlu çıkış başarılı');
      return true;
    } catch (e) {
      print('LogoutService: Zorunlu çıkış hatası - $e');
      return false;
    }
  }

  // Handle session timeout
  Future<bool> handleSessionTimeout() async {
    print('LogoutService: Oturum zaman aşımı');
    return forceLogout(reason: 'Oturum zaman aşımına uğradı');
  }

  // Handle account deletion
  Future<bool> handleAccountDeletion() async {
    print('LogoutService: Hesap silindi');
    return forceLogout(reason: 'Hesabınız silindi');
  }

  // Handle account ban
  Future<bool> handleAccountBan() async {
    print('LogoutService: Hesap engellendi');
    return forceLogout(reason: 'Hesabınız engellendi');
  }

  // Handle multiple device logout
  Future<bool> handleMultipleDeviceLogout() async {
    print('LogoutService: Başka bir cihazdan giriş yapıldı');
    return forceLogout(
      reason:
          'Başka bir cihazdan giriş yapıldığı için oturumunuz sonlandırıldı',
    );
  }
}
