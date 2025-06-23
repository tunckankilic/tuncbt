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
    if (_isInitialized) return;

    try {
      _setLoading(true);
      _error = null;

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
      if (userData.teamId == null) {
        _error = 'Kullanıcı henüz bir takıma ait değil';
        return;
      }

      await loadTeamData(userData.teamId!);
      _isInitialized = true;
    } catch (e) {
      _error = 'Takım bilgileri yüklenirken hata oluştu: $e';
      log('Error initializing team data: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load team data
  Future<void> loadTeamData(String teamId) async {
    try {
      _setLoading(true);
      _error = null;

      final result = await _teamService.getTeamInfo(teamId);
      if (!result.success) {
        _error = result.error?.message;
        return;
      }

      _currentTeam = result.data;

      // Load team members
      final membersResult = await _teamService.getTeamMembers(teamId);
      if (!membersResult.success) {
        _error = membersResult.error?.message;
        return;
      }

      _teamMembers = membersResult.data!;

      // Set user role
      final user = _auth.currentUser;
      if (user != null) {
        final member = _teamMembers.firstWhere(
          (m) => m.userId == user.uid,
          orElse: () => TeamMember(
            teamId: teamId,
            userId: user.uid,
            invitedBy: '',
            joinedAt: DateTime.now(),
            role: TeamRole.member,
          ),
        );
        _userRole = member.role;
      }

      await _cacheTeamData();
      notifyListeners();
    } catch (e) {
      _error = 'Takım bilgileri yüklenirken hata oluştu: $e';
      log('Error loading team data: $e');
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
    if (_currentTeam == null) return;

    try {
      _setLoading(true);
      _error = null;

      // Update team document
      await _firestore.collection('teams').doc(_currentTeam!.teamId).update({
        if (teamName != null) 'teamName': teamName,
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
      });

      // Update team member count
      await _firestore.collection('teams').doc(_currentTeam!.teamId).update({
        'memberCount': FieldValue.increment(-1),
      });

      // Clear local data
      _currentTeam = null;
      _teamMembers = [];
      _userRole = null;
      _isInitialized = false;

      // Clear cached data
      await _prefs.remove('team_data');
      await _prefs.remove('user_role');

      notifyListeners();
    } catch (e) {
      _error = 'Takımdan ayrılırken hata oluştu: $e';
      log('Error leaving team: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Set loading state
  void _setLoading(bool value) {
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
    _currentTeam = null;
    _teamMembers = [];
    _userRole = null;
    _isInitialized = false;
    await _cacheTeamData();
    notifyListeners();
  }

}
