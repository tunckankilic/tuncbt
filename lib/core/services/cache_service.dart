import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuncbt/core/models/team.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/core/enums/team_role.dart';

class CacheService extends GetxService {
  final SharedPreferences _prefs;

  // Cache keys
  static const String _teamDataKey = 'team_data';
  static const String _teamIdKey = 'team_id';
  static const String _userRoleKey = 'user_role';
  static const String _userDataKey = 'user_data';
  static const String _teamMembersKey = 'team_members';
  static const String _lastSyncKey = 'last_sync';

  CacheService(this._prefs);

  // Team data caching
  Future<void> cacheTeamData(Team? team) async {
    try {
      if (team != null) {
        final teamJson = jsonEncode(team.toJson());
        await _prefs.setString(_teamDataKey, teamJson);
        await _prefs.setString(_teamIdKey, team.teamId);
        print('CacheService: Takım verisi önbelleğe alındı - ${team.teamName}');
      } else {
        await clearTeamCache();
        print('CacheService: Takım verisi önbellekten silindi');
      }
    } catch (e) {
      print('CacheService: Takım verisi önbellekleme hatası - $e');
      await clearTeamCache();
    }
  }

  Team? getTeamData() {
    try {
      final teamJson = _prefs.getString(_teamDataKey);
      if (teamJson != null) {
        final teamData = jsonDecode(teamJson) as Map<String, dynamic>;
        return Team.fromJson(teamData);
      }
    } catch (e) {
      print('CacheService: Takım verisi okuma hatası - $e');
      clearTeamCache();
    }
    return null;
  }

  // User role caching
  Future<void> cacheUserRole(TeamRole? role) async {
    try {
      if (role != null) {
        await _prefs.setString(_userRoleKey, role.toString());
      } else {
        await _prefs.remove(_userRoleKey);
      }
    } catch (e) {
      print('CacheService: Kullanıcı rolü önbellekleme hatası - $e');
    }
  }

  TeamRole? getUserRole() {
    try {
      final roleStr = _prefs.getString(_userRoleKey);
      if (roleStr != null) {
        return TeamRole.values.firstWhere(
          (e) => e.toString() == roleStr,
          orElse: () => TeamRole.member,
        );
      }
    } catch (e) {
      print('CacheService: Kullanıcı rolü okuma hatası - $e');
    }
    return null;
  }

  // User data caching
  Future<void> cacheUserData(UserModel? user) async {
    try {
      if (user != null) {
        final userJson = jsonEncode(user.toJson());
        await _prefs.setString(_userDataKey, userJson);
      } else {
        await _prefs.remove(_userDataKey);
      }
    } catch (e) {
      print('CacheService: Kullanıcı verisi önbellekleme hatası - $e');
    }
  }

  UserModel? getUserData() {
    try {
      final userJson = _prefs.getString(_userDataKey);
      if (userJson != null) {
        final userData = jsonDecode(userJson) as Map<String, dynamic>;
        return UserModel.fromJson(userData);
      }
    } catch (e) {
      print('CacheService: Kullanıcı verisi okuma hatası - $e');
    }
    return null;
  }

  // Team members caching
  Future<void> cacheTeamMembers(List<UserModel> members) async {
    try {
      final membersJson = jsonEncode(members.map((m) => m.toJson()).toList());
      await _prefs.setString(_teamMembersKey, membersJson);
      print(
          'CacheService: Takım üyeleri önbelleğe alındı - ${members.length} üye');
    } catch (e) {
      print('CacheService: Takım üyeleri önbellekleme hatası - $e');
    }
  }

  List<UserModel> getTeamMembers() {
    try {
      final membersJson = _prefs.getString(_teamMembersKey);
      if (membersJson != null) {
        final membersList =
            (jsonDecode(membersJson) as List).cast<Map<String, dynamic>>();
        return membersList.map((m) => UserModel.fromJson(m)).toList();
      }
    } catch (e) {
      print('CacheService: Takım üyeleri okuma hatası - $e');
    }
    return [];
  }

  // Last sync time tracking
  Future<void> updateLastSync() async {
    await _prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  DateTime? getLastSync() {
    final timestamp = _prefs.getInt(_lastSyncKey);
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  // Clear all cache
  Future<void> clearAllCache() async {
    try {
      await Future.wait([
        _prefs.remove(_teamDataKey),
        _prefs.remove(_teamIdKey),
        _prefs.remove(_userRoleKey),
        _prefs.remove(_userDataKey),
        _prefs.remove(_teamMembersKey),
        _prefs.remove(_lastSyncKey),
      ]);
      print('CacheService: Tüm önbellek temizlendi');
    } catch (e) {
      print('CacheService: Önbellek temizleme hatası - $e');
    }
  }

  // Clear team related cache
  Future<void> clearTeamCache() async {
    try {
      await Future.wait([
        _prefs.remove(_teamDataKey),
        _prefs.remove(_teamIdKey),
        _prefs.remove(_userRoleKey),
        _prefs.remove(_teamMembersKey),
      ]);
      print('CacheService: Takım önbelleği temizlendi');
    } catch (e) {
      print('CacheService: Takım önbelleği temizleme hatası - $e');
    }
  }

  // Check if cache is stale
  bool isCacheStale() {
    final lastSync = getLastSync();
    if (lastSync == null) return true;

    final now = DateTime.now();
    final difference = now.difference(lastSync);

    // Cache 1 saatten eski ise yenile
    return difference.inHours >= 1;
  }

  // Get cached team ID
  String? getTeamId() {
    return _prefs.getString(_teamIdKey);
  }

  // Debug methods
  void debugPrintCache() {
    print('\nCacheService: Önbellek durumu:');
    print('Team Data: ${_prefs.getString(_teamDataKey)}');
    print('Team ID: ${_prefs.getString(_teamIdKey)}');
    print('User Role: ${_prefs.getString(_userRoleKey)}');
    print('User Data: ${_prefs.getString(_userDataKey)}');
    print('Team Members Count: ${getTeamMembers().length}');
    print('Last Sync: ${getLastSync()}');
    print('Cache Stale: ${isCacheStale()}\n');
  }
}
