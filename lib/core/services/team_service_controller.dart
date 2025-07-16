import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuncbt/core/models/team.dart';
import 'package:tuncbt/core/models/team_member.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/core/services/team_service.dart';
import 'package:tuncbt/core/services/auth_service.dart';
import 'package:tuncbt/core/enums/team_role.dart';

class TeamServiceController extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TeamService _teamService = TeamService();
  final SharedPreferences _prefs = Get.find<SharedPreferences>();

  late final AuthService _authService;

  // Observable state variables
  final Rx<Team?> currentTeam = Rx<Team?>(null);
  final RxList<TeamMember> teamMembers = <TeamMember>[].obs;
  final Rx<TeamRole?> userRole = Rx<TeamRole?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxBool isInitialized = false.obs;

  // Getters
  bool get isAdmin => userRole.value?.name.toLowerCase() == 'admin';
  bool get isManager => userRole.value?.name.toLowerCase() == 'manager';
  String? get teamId => currentTeam.value?.teamId;
  bool get hasError => error.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _authService = Get.find<AuthService>();

    // Listen to auth state changes
    ever(_authService.currentUser, _onUserChanged);

    // Load cached data on init
    _loadCachedData();
  }

  void _onUserChanged(UserModel? user) {
    if (user == null) {
      _clearTeamData();
    } else if (user.hasTeam && user.teamId != null) {
      initializeTeamData();
    }
  }

  // Load cached team data from SharedPreferences
  Future<void> _loadCachedData() async {
    try {
      final teamJson = _prefs.getString('team_data');
      if (teamJson != null) {
        final teamData = Map<String, dynamic>.from(jsonDecode(teamJson));
        currentTeam.value = Team.fromJson(teamData);
      }

      final roleStr = _prefs.getString('user_role');
      if (roleStr != null) {
        userRole.value = TeamRole.values.firstWhere(
          (e) => e.toString().split('.').last == roleStr,
          orElse: () => TeamRole.member,
        );
      }
    } catch (e) {
      print('TeamServiceController: Error loading cached data: $e');
    }
  }

  // Cache team data to SharedPreferences
  Future<void> _cacheTeamData() async {
    try {
      if (currentTeam.value != null) {
        await _prefs.setString(
            'team_data', jsonEncode(currentTeam.value!.toJson()));
        await _prefs.setString('team_id', currentTeam.value!.teamId);
      } else {
        await _prefs.remove('team_data');
        await _prefs.remove('team_id');
      }

      if (userRole.value != null) {
        await _prefs.setString(
            'user_role', userRole.value.toString().split('.').last);
      } else {
        await _prefs.remove('user_role');
      }
    } catch (e) {
      print('TeamServiceController: Error caching team data: $e');
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
      isLoading.value = true;
      error.value = '';

      final user = _authService.currentUser.value;
      if (user == null || !user.hasTeam || user.teamId == null) {
        error.value = 'Henüz bir takıma ait değilsiniz';
        print('TeamServiceController: Kullanıcı takım bilgisi bulunamadı');
        await _clearTeamData();
        return;
      }

      final teamId = user.teamId!;

      // Team membership check and create if needed
      final membershipResult =
          await _teamService.checkAndCreateTeamMembership();
      if (!membershipResult.success) {
        error.value = membershipResult.error?.message ??
            'Takım üyeliği kontrol edilirken hata oluştu';
        print(
            'TeamServiceController: Takım üyeliği kontrolü başarısız - Error: ${error.value}');
        await _clearTeamData();
        return;
      }

      // Load team data
      print('TeamServiceController: Takım verileri yükleniyor...');
      final result = await _teamService.getTeamInfo(teamId);
      if (!result.success || result.data == null) {
        error.value = result.error?.message ?? 'Takım bilgileri alınamadı';
        print(
            'TeamServiceController: Takım bilgileri alınamadı - Error: ${error.value}');
        await _clearTeamData();
        return;
      }

      currentTeam.value = result.data;

      // Set user role
      if (user.teamRole != null) {
        userRole.value = user.teamRole;
        print(
            'TeamServiceController: Kullanıcı rolü ayarlandı: ${userRole.value}');
      } else {
        error.value = 'Kullanıcı rol bilgisi bulunamadı';
        print('TeamServiceController: Kullanıcı rolü bulunamadı');
        await _clearTeamData();
        return;
      }

      // Load team members
      final membersResult = await _teamService.getTeamMembers(teamId);
      if (!membersResult.success || membersResult.data == null) {
        error.value = membersResult.error?.message ?? 'Takım üyeleri alınamadı';
        print(
            'TeamServiceController: Takım üyeleri alınamadı - Error: ${error.value}');
        return;
      }

      teamMembers.value = membersResult.data!;

      // Cache data
      await _cacheTeamData();

      isInitialized.value = true;
      print(
          'TeamServiceController: Başlatma işlemi tamamlandı - Team: ${currentTeam.value?.teamName}, Role: ${userRole.value}, Members: ${teamMembers.length}');
    } catch (e, stackTrace) {
      error.value = 'Beklenmeyen bir hata oluştu: $e';
      print('TeamServiceController Error: $e');
      print('Stack trace: $stackTrace');
      await _clearTeamData();
    } finally {
      isLoading.value = false;
    }
  }

  // Load team data
  Future<void> loadTeamData(String teamId) async {
    try {
      isLoading.value = true;
      error.value = '';

      // Check user authentication
      final user = _authService.currentUser.value;
      if (user == null) {
        error.value = 'Kullanıcı oturumu bulunamadı';
        return;
      }

      // Check team membership status
      final memberDoc = await _firestore
          .collection('team_members')
          .doc('${teamId}_${user.id}')
          .get();

      if (!memberDoc.exists || !(memberDoc.data()?['isActive'] ?? false)) {
        error.value = 'Takım üyeliğiniz aktif değil';
        print('TeamServiceController: Takım üyeliği aktif değil');

        // Fix user data
        await _firestore.collection('users').doc(user.id).update({
          'hasTeam': false,
          'teamId': null,
          'teamRole': null,
        });
        return;
      }

      if (!user.hasTeam || user.teamId != teamId) {
        error.value = 'Henüz bir takıma ait değilsiniz';
        print(
            'TeamServiceController: Kullanıcı takım bilgileri uyuşmuyor - HasTeam: ${user.hasTeam}, TeamID: ${user.teamId}');

        // Fix user data
        await _firestore.collection('users').doc(user.id).update({
          'hasTeam': false,
          'teamId': null,
          'teamRole': null,
        });
        return;
      }

      // Load team info
      final result = await _teamService.getTeamInfo(teamId);
      if (!result.success || result.data == null) {
        error.value = result.error?.message ?? 'Takım bilgileri alınamadı';
        return;
      }

      currentTeam.value = result.data;

      // Set user role
      if (user.teamRole != null) {
        userRole.value = user.teamRole;
        print(
            'TeamServiceController: Kullanıcı rolü ayarlandı: ${userRole.value}');
      } else {
        error.value = 'Kullanıcı rol bilgisi bulunamadı';
        return;
      }

      // Load team members
      final membersResult = await _teamService.getTeamMembers(teamId);
      if (!membersResult.success || membersResult.data == null) {
        error.value = membersResult.error?.message ?? 'Takım üyeleri alınamadı';
        return;
      }

      teamMembers.value = membersResult.data!;

      await _cacheTeamData();
      print(
          'TeamServiceController: Takım verileri başarıyla yüklendi - Team: ${currentTeam.value?.teamName}, Role: ${userRole.value}');
    } catch (e, stackTrace) {
      error.value = 'Beklenmeyen bir hata oluştu: $e';
      print('TeamServiceController - loadTeamData hatası: $e');
      print('Stack trace: $stackTrace');
    } finally {
      isLoading.value = false;
    }
  }

  // Update team information
  Future<void> updateTeamInfo({
    String? teamName,
    String? description,
    Map<String, dynamic>? settings,
  }) async {
    if (currentTeam.value == null) return;

    try {
      isLoading.value = true;
      error.value = '';

      // Update team document
      await _firestore
          .collection('teams')
          .doc(currentTeam.value!.teamId)
          .update({
        if (teamName != null) 'name': teamName,
        if (description != null) 'description': description,
        if (settings != null) 'settings': settings,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Reload team data
      await loadTeamData(currentTeam.value!.teamId);
    } catch (e) {
      error.value = 'Takım bilgileri güncellenirken hata oluştu: $e';
      print('TeamServiceController: Error updating team info: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Leave team
  Future<void> leaveTeam() async {
    if (currentTeam.value == null) return;

    try {
      isLoading.value = true;
      error.value = '';

      final user = _authService.currentUser.value;
      if (user == null) {
        error.value = 'Kullanıcı oturumu bulunamadı';
        return;
      }

      // Update team member status
      await _firestore
          .collection('team_members')
          .doc('${currentTeam.value!.teamId}_${user.id}')
          .update({'isActive': false});

      // Update user's team ID
      await _firestore.collection('users').doc(user.id).update({
        'teamId': null,
        'teamRole': null,
        'hasTeam': false,
      });

      // Update team member count
      await _firestore
          .collection('teams')
          .doc(currentTeam.value!.teamId)
          .update({
        'memberCount': FieldValue.increment(-1),
      });

      // Clear local data
      await _clearTeamData();

      // Refresh AuthService to update user data
      await _authService.refreshUserData();
    } catch (e) {
      error.value = 'Takımdan ayrılırken hata oluştu: $e';
      print('TeamServiceController: Error leaving team: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Clear error
  void clearError() {
    error.value = '';
  }

  // Clear team data
  Future<void> clearTeamData() async {
    await _clearTeamData();
  }

  // Private clear team data
  Future<void> _clearTeamData() async {
    currentTeam.value = null;
    teamMembers.clear();
    userRole.value = null;
    isInitialized.value = false;
    await _cacheTeamData();
  }
}
