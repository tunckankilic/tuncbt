import 'dart:developer';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuncbt/core/models/team.dart';
import 'package:tuncbt/core/models/team_member.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/core/services/team_service.dart';
import 'package:tuncbt/core/enums/team_role.dart';

class TeamController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TeamService _teamService = TeamService();
  final SharedPreferences _prefs = Get.find<SharedPreferences>();

  // State variables
  final Rx<Team?> _currentTeam = Rx<Team?>(null);
  final RxList<TeamMember> _teamMembers = <TeamMember>[].obs;
  final Rx<TeamRole?> _userRole = Rx<TeamRole?>(null);
  final RxBool _isLoading = false.obs;
  final RxString _error = ''.obs;
  final RxBool _isInitialized = false.obs;

  // Getters
  Team? get currentTeam => _currentTeam.value;
  List<TeamMember> get teamMembers => _teamMembers;
  TeamRole? get userRole => _userRole.value;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  bool get isInitialized => _isInitialized.value;
  bool get isAdmin => _userRole.value?.name.toLowerCase() == 'admin';
  bool get isManager => _userRole.value?.name.toLowerCase() == 'manager';
  String? get teamId => _currentTeam.value?.teamId;

  @override
  void onInit() {
    super.onInit();
    _loadCachedData();
  }

  // Load cached team data from SharedPreferences
  Future<void> _loadCachedData() async {
    try {
      final teamJson = _prefs.getString('team_data');
      if (teamJson != null) {
        _currentTeam.value =
            Team.fromJson(Map<String, dynamic>.from(jsonDecode(teamJson)));
      }

      final roleStr = _prefs.getString('user_role');
      if (roleStr != null) {
        _userRole.value = TeamRole.values.firstWhere(
          (e) => e.toString().split('.').last == roleStr,
          orElse: () => TeamRole.member,
        );
      }
    } catch (e) {
      log('Error loading cached data: $e');
    }
  }

  // Cache team data to SharedPreferences
  Future<void> _cacheTeamData() async {
    try {
      if (_currentTeam.value != null) {
        await _prefs.setString(
            'team_data', jsonEncode(_currentTeam.value!.toJson()));
        await _prefs.setString('team_id', _currentTeam.value!.teamId);
      } else {
        await _prefs.remove('team_data');
        await _prefs.remove('team_id');
      }

      if (_userRole.value != null) {
        await _prefs.setString(
            'user_role', _userRole.value.toString().split('.').last);
      } else {
        await _prefs.remove('user_role');
      }
    } catch (e) {
      log('Error caching team data: $e');
    }
  }

  // Get cached team ID
  static Future<String?> getCachedTeamId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('team_id');
  }

  // Initialize team data
  Future<void> initializeTeamData() async {
    try {
      _setLoading(true);
      _error.value = '';

      final user = _auth.currentUser;
      if (user == null) {
        _error.value = 'Kullanıcı oturumu bulunamadı';
        print('TeamController: Kullanıcı oturumu bulunamadı');
        return;
      }

      // Kullanıcı verilerini al
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        _error.value = 'Kullanıcı bilgileri bulunamadı';
        print('TeamController: Kullanıcı dokümanı bulunamadı');
        await _clearTeamData();
        return;
      }

      final userData = UserModel.fromFirestore(userDoc);
      print(
          'TeamController: Kullanıcı verileri yüklendi: ${userData.toFirestore()}');

      // Takım ID'si kontrolü
      final teamId = userData.teamId;
      if (teamId == null || teamId.isEmpty) {
        _error.value = 'Henüz bir takıma ait değilsiniz';
        print('TeamController: Takım ID\'si bulunamadı');
        await _clearTeamData();
        return;
      }

      // Takım üyeliğini kontrol et ve gerekirse oluştur
      final membershipResult =
          await _teamService.checkAndCreateTeamMembership();
      if (!membershipResult.success) {
        _error.value = membershipResult.error?.message ??
            'Takım üyeliği kontrol edilirken hata oluştu';
        print(
            'TeamController: Takım üyeliği kontrolü başarısız - Error: ${_error.value}');
        await _clearTeamData();
        return;
      }

      // Takım verilerini yükle
      print('TeamController: Takım verileri yükleniyor...');
      final result = await _teamService.getTeamInfo(teamId);
      if (!result.success || result.data == null) {
        _error.value = result.error?.message ?? 'Takım bilgileri alınamadı';
        print(
            'TeamController: Takım bilgileri alınamadı - Error: ${_error.value}');
        await _clearTeamData();
        return;
      }

      _currentTeam.value = result.data;

      // Kullanıcı rolünü ayarla
      if (userData.teamRole != null) {
        _userRole.value = userData.teamRole;
        print('TeamController: Kullanıcı rolü ayarlandı: ${_userRole.value}');
      } else {
        _error.value = 'Kullanıcı rol bilgisi bulunamadı';
        print('TeamController: Kullanıcı rolü bulunamadı');
        await _clearTeamData();
        return;
      }

      // Takım üyelerini yükle
      final membersResult = await _teamService.getTeamMembers(teamId);
      if (!membersResult.success || membersResult.data == null) {
        _error.value =
            membersResult.error?.message ?? 'Takım üyeleri alınamadı';
        print(
            'TeamController: Takım üyeleri alınamadı - Error: ${_error.value}');
        return;
      }

      _teamMembers.value = membersResult.data!;

      // Önbelleğe kaydet
      await _cacheTeamData();

      _isInitialized.value = true;
      print(
          'TeamController: Başlatma işlemi tamamlandı - Team: ${_currentTeam.value?.teamName}, Role: ${_userRole.value}, Members: ${_teamMembers.length}');
    } catch (e, stackTrace) {
      _error.value = 'Beklenmeyen bir hata oluştu: $e';
      print('TeamController Error: $e');
      print('Stack trace: $stackTrace');
      await _clearTeamData();
    } finally {
      _setLoading(false);
    }
  }

  // Load team data
  Future<void> loadTeamData(String teamId) async {
    try {
      _setLoading(true);
      _error.value = '';

      // Önce kullanıcı bilgilerini kontrol et
      final user = _auth.currentUser;
      if (user == null) {
        _error.value = 'Kullanıcı oturumu bulunamadı';
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        _error.value = 'Kullanıcı bilgileri bulunamadı';
        return;
      }

      final userData = UserModel.fromFirestore(userDoc);

      // Takım üyeliği durumunu kontrol et
      final memberDoc = await _firestore
          .collection('team_members')
          .doc('${teamId}_${user.uid}')
          .get();

      if (!memberDoc.exists || !(memberDoc.data()?['isActive'] ?? false)) {
        _error.value = 'Takım üyeliğiniz aktif değil';
        print('TeamController: Takım üyeliği aktif değil');

        // Kullanıcı verilerini düzelt
        await _firestore.collection('users').doc(user.uid).update({
          'hasTeam': false,
          'teamId': null,
          'teamRole': null,
        });
        return;
      }

      if (!userData.hasTeam || userData.teamId != teamId) {
        _error.value = 'Henüz bir takıma ait değilsiniz';
        print(
            'TeamController: Kullanıcı takım bilgileri uyuşmuyor - HasTeam: ${userData.hasTeam}, TeamID: ${userData.teamId}');

        // Kullanıcı verilerini düzelt
        await _firestore.collection('users').doc(user.uid).update({
          'hasTeam': false,
          'teamId': null,
          'teamRole': null,
        });
        return;
      }

      // Takım bilgilerini yükle
      final result = await _teamService.getTeamInfo(teamId);
      if (!result.success || result.data == null) {
        _error.value = result.error?.message ?? 'Takım bilgileri alınamadı';
        return;
      }

      _currentTeam.value = result.data;

      // Kullanıcı rolünü ayarla
      if (userData.teamRole != null) {
        _userRole.value = userData.teamRole;
        print('TeamController: Kullanıcı rolü ayarlandı: ${_userRole.value}');
      } else {
        _error.value = 'Kullanıcı rol bilgisi bulunamadı';
        return;
      }

      // Takım üyelerini yükle
      final membersResult = await _teamService.getTeamMembers(teamId);
      if (!membersResult.success || membersResult.data == null) {
        _error.value =
            membersResult.error?.message ?? 'Takım üyeleri alınamadı';
        return;
      }

      _teamMembers.value = membersResult.data!;

      await _cacheTeamData();
      print(
          'TeamController: Takım verileri başarıyla yüklendi - Team: ${_currentTeam.value?.teamName}, Role: ${_userRole.value}');
    } catch (e, stackTrace) {
      _error.value = 'Beklenmeyen bir hata oluştu: $e';
      print('TeamController - loadTeamData hatası: $e');
      print('Stack trace: $stackTrace');
    } finally {
      _setLoading(false);
    }
  }

  // Update team information
  Future<void> updateTeamInfo({
    String? teamName,
    String? description,
    Map<String, dynamic>? settings,
  }) async {
    if (_currentTeam.value == null) return;

    try {
      _setLoading(true);
      _error.value = '';

      // Update team document
      await _firestore
          .collection('teams')
          .doc(_currentTeam.value!.teamId)
          .update({
        if (teamName != null) 'name': teamName,
        if (description != null) 'description': description,
        if (settings != null) 'settings': settings,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Reload team data
      await loadTeamData(_currentTeam.value!.teamId);
    } catch (e) {
      _error.value = 'Takım bilgileri güncellenirken hata oluştu: $e';
      log('Error updating team info: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Leave team
  Future<void> leaveTeam() async {
    if (_currentTeam.value == null) return;

    try {
      _setLoading(true);
      _error.value = '';

      final user = _auth.currentUser;
      if (user == null) {
        _error.value = 'Kullanıcı oturumu bulunamadı';
        return;
      }

      // Update team member status
      await _firestore
          .collection('team_members')
          .doc('${_currentTeam.value!.teamId}_${user.uid}')
          .update({'isActive': false});

      // Update user's team ID
      await _firestore.collection('users').doc(user.uid).update({
        'teamId': null,
        'teamRole': null,
        'hasTeam': false,
      });

      // Update team member count
      await _firestore
          .collection('teams')
          .doc(_currentTeam.value!.teamId)
          .update({
        'memberCount': FieldValue.increment(-1),
      });

      // Clear local data
      await _clearTeamData();
    } catch (e) {
      _error.value = 'Takımdan ayrılırken hata oluştu: $e';
      log('Error leaving team: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Set loading state
  void _setLoading(bool value) {
    _isLoading.value = value;
  }

  // Clear error
  void clearError() {
    _error.value = '';
  }

  // Clear team data
  Future<void> clearTeamData() async {
    await _clearTeamData();
  }

  // Clear team data
  Future<void> _clearTeamData() async {
    _currentTeam.value = null;
    _teamMembers.clear();
    _userRole.value = null;
    _isInitialized.value = false;
    await _cacheTeamData();
  }
}
