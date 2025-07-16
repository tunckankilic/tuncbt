import 'dart:developer';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuncbt/core/models/team.dart';
import 'package:tuncbt/core/models/team_member.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/core/services/team_service.dart';
import 'package:tuncbt/core/enums/team_role.dart';

class TeamProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TeamService _teamService = TeamService();
  final SharedPreferences _prefs;

  // State variables
  Team? _currentTeam;
  List<TeamMember> _teamMembers = [];
  TeamRole? _userRole;
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  // Getters
  Team? get currentTeam => _currentTeam;
  List<TeamMember> get teamMembers => _teamMembers;
  TeamRole? get userRole => _userRole;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;
  bool get isAdmin => _userRole?.name.toLowerCase() == 'admin';
  bool get isManager => _userRole?.name.toLowerCase() == 'manager';
  String? get teamId => _currentTeam?.teamId;

  TeamProvider(this._prefs) {
    _loadCachedData();
  }

  // Load cached team data from SharedPreferences
  Future<void> _loadCachedData() async {
    try {
      final teamJson = _prefs.getString('team_data');
      if (teamJson != null) {
        _currentTeam =
            Team.fromJson(Map<String, dynamic>.from(jsonDecode(teamJson)));
      }

      final roleStr = _prefs.getString('user_role');
      if (roleStr != null) {
        _userRole = TeamRole.values.firstWhere(
          (e) => e.toString().split('.').last == roleStr,
          orElse: () => TeamRole.member,
        );
      }

      notifyListeners();
    } catch (e) {
      log('Error loading cached data: $e');
    }
  }

  // Cache team data to SharedPreferences
  Future<void> _cacheTeamData() async {
    try {
      if (_currentTeam != null) {
        await _prefs.setString('team_data', jsonEncode(_currentTeam!.toJson()));
        await _prefs.setString('team_id', _currentTeam!.teamId);
      } else {
        await _prefs.remove('team_data');
        await _prefs.remove('team_id');
      }

      if (_userRole != null) {
        await _prefs.setString(
            'user_role', _userRole.toString().split('.').last);
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
      _error = null;

      final user = _auth.currentUser;
      if (user == null) {
        _error = 'Kullanıcı oturumu bulunamadı';
        print('TeamProvider: Kullanıcı oturumu bulunamadı');
        return;
      }

      // Kullanıcı verilerini al
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        _error = 'Kullanıcı bilgileri bulunamadı';
        print('TeamProvider: Kullanıcı dokümanı bulunamadı');
        await _clearTeamData();
        return;
      }

      final userData = UserModel.fromFirestore(userDoc);
      print(
          'TeamProvider: Kullanıcı verileri yüklendi: ${userData.toFirestore()}');

      // Takım ID'si kontrolü
      final teamId = userData.teamId;
      if (teamId == null || teamId.isEmpty) {
        _error = 'Henüz bir takıma ait değilsiniz';
        print('TeamProvider: Takım ID\'si bulunamadı');
        await _clearTeamData();
        return;
      }

      // Takım üyeliğini kontrol et ve gerekirse oluştur
      final membershipResult =
          await _teamService.checkAndCreateTeamMembership();
      if (!membershipResult.success) {
        _error = membershipResult.error?.message ??
            'Takım üyeliği kontrol edilirken hata oluştu';
        print(
            'TeamProvider: Takım üyeliği kontrolü başarısız - Error: $_error');
        await _clearTeamData();
        return;
      }

      // Takım verilerini yükle
      print('TeamProvider: Takım verileri yükleniyor...');
      final result = await _teamService.getTeamInfo(teamId);
      if (!result.success || result.data == null) {
        _error = result.error?.message ?? 'Takım bilgileri alınamadı';
        print('TeamProvider: Takım bilgileri alınamadı - Error: $_error');
        await _clearTeamData();
        return;
      }

      _currentTeam = result.data;

      // Kullanıcı rolünü ayarla
      if (userData.teamRole != null) {
        _userRole = userData.teamRole;
        print('TeamProvider: Kullanıcı rolü ayarlandı: $_userRole');
      } else {
        _error = 'Kullanıcı rol bilgisi bulunamadı';
        print('TeamProvider: Kullanıcı rolü bulunamadı');
        await _clearTeamData();
        return;
      }

      // Takım üyelerini yükle
      final membersResult = await _teamService.getTeamMembers(teamId);
      if (!membersResult.success || membersResult.data == null) {
        _error = membersResult.error?.message ?? 'Takım üyeleri alınamadı';
        print('TeamProvider: Takım üyeleri alınamadı - Error: $_error');
        return;
      }

      _teamMembers = membersResult.data!;

      // Önbelleğe kaydet
      await _cacheTeamData();

      _isInitialized = true;
      print(
          'TeamProvider: Başlatma işlemi tamamlandı - Team: ${_currentTeam?.teamName}, Role: $_userRole, Members: ${_teamMembers.length}');
    } catch (e, stackTrace) {
      _error = 'Beklenmeyen bir hata oluştu: $e';
      print('TeamProvider Error: $e');
      print('Stack trace: $stackTrace');
      await _clearTeamData();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Load team data
  Future<void> loadTeamData(String teamId) async {
    try {
      _setLoading(true);
      _error = null;

      // Önce kullanıcı bilgilerini kontrol et
      final user = _auth.currentUser;
      if (user == null) {
        _error = 'Kullanıcı oturumu bulunamadı';
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        _error = 'Kullanıcı bilgileri bulunamadı';
        return;
      }

      final userData = UserModel.fromFirestore(userDoc);

      // Takım üyeliği durumunu kontrol et
      final memberDoc = await _firestore
          .collection('team_members')
          .doc('${teamId}_${user.uid}')
          .get();

      if (!memberDoc.exists || !(memberDoc.data()?['isActive'] ?? false)) {
        _error = 'Takım üyeliğiniz aktif değil';
        print('TeamProvider: Takım üyeliği aktif değil');

        // Kullanıcı verilerini düzelt
        await _firestore.collection('users').doc(user.uid).update({
          'hasTeam': false,
          'teamId': null,
          'teamRole': null,
        });
        return;
      }

      if (!userData.hasTeam || userData.teamId != teamId) {
        _error = 'Henüz bir takıma ait değilsiniz';
        print(
            'TeamProvider: Kullanıcı takım bilgileri uyuşmuyor - HasTeam: ${userData.hasTeam}, TeamID: ${userData.teamId}');

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
        _error = result.error?.message ?? 'Takım bilgileri alınamadı';
        return;
      }

      _currentTeam = result.data;

      // Kullanıcı rolünü ayarla
      if (userData.teamRole != null) {
        _userRole = userData.teamRole;
        print('TeamProvider: Kullanıcı rolü ayarlandı: $_userRole');
      } else {
        _error = 'Kullanıcı rol bilgisi bulunamadı';
        return;
      }

      // Takım üyelerini yükle
      final membersResult = await _teamService.getTeamMembers(teamId);
      if (!membersResult.success || membersResult.data == null) {
        _error = membersResult.error?.message ?? 'Takım üyeleri alınamadı';
        return;
      }

      _teamMembers = membersResult.data!;

      await _cacheTeamData();
      print(
          'TeamProvider: Takım verileri başarıyla yüklendi - Team: ${_currentTeam?.teamName}, Role: $_userRole');
    } catch (e, stackTrace) {
      _error = 'Beklenmeyen bir hata oluştu: $e';
      print('TeamProvider - loadTeamData hatası: $e');
      print('Stack trace: $stackTrace');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Update team information
  Future<void> updateTeamInfo({
    String? teamName,
    String? description,
    Map<String, dynamic>? settings,
  }) async {
    if (_currentTeam == null) return;

    try {
      _setLoading(true);
      _error = null;

      // Update team document
      await _firestore.collection('teams').doc(_currentTeam!.teamId).update({
        if (teamName != null) 'name': teamName,
        if (description != null) 'description': description,
        if (settings != null) 'settings': settings,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Reload team data
      await loadTeamData(_currentTeam!.teamId);
    } catch (e) {
      _error = 'Takım bilgileri güncellenirken hata oluştu: $e';
      log('Error updating team info: $e');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Leave team
  Future<void> leaveTeam() async {
    if (_currentTeam == null) return;

    try {
      _setLoading(true);
      _error = null;

      final user = _auth.currentUser;
      if (user == null) {
        _error = 'Kullanıcı oturumu bulunamadı';
        return;
      }

      // Update team member status
      await _firestore
          .collection('team_members')
          .doc('${_currentTeam!.teamId}_${user.uid}')
          .update({'isActive': false});

      // Update user's team ID
      await _firestore.collection('users').doc(user.uid).update({
        'teamId': null,
        'teamRole': null,
        'hasTeam': false,
      });

      // Update team member count
      await _firestore.collection('teams').doc(_currentTeam!.teamId).update({
        'memberCount': FieldValue.increment(-1),
      });

      // Clear local data
      await _clearTeamData();
    } catch (e) {
      _error = 'Takımdan ayrılırken hata oluştu: $e';
      log('Error leaving team: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Set loading state
  void _setLoading(bool value) {
    if (_isLoading == value) return;
    _isLoading = value;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear team data
  Future<void> clearTeamData() async {
    await _clearTeamData();
  }

  // Clear team data
  Future<void> _clearTeamData() async {
    _currentTeam = null;
    _teamMembers = [];
    _userRole = null;
    _isInitialized = false;
    await _cacheTeamData();
    notifyListeners();
  }
}
