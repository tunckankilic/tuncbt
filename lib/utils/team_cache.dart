import 'dart:async';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuncbt/core/models/team.dart';
import 'package:tuncbt/core/models/team_member.dart';

class TeamCache extends GetxService {
  static const String _teamCacheKey = 'team_cache';
  static const String _membersCacheKey = 'team_members_cache';
  static const Duration _cacheExpiration = Duration(minutes: 15);

  final _teamCache = <String, Team>{}.obs;
  final _membersCache = <String, List<TeamMember>>{}.obs;
  final _lastUpdated = <String, DateTime>{}.obs;

  late SharedPreferences _prefs;
  Timer? _cleanupTimer;

  @override
  void onInit() {
    super.onInit();
    _initCache();
    _startCleanupTimer();
  }

  @override
  void onClose() {
    _cleanupTimer?.cancel();
    super.onClose();
  }

  Future<void> _initCache() async {
    _prefs = await SharedPreferences.getInstance();
    _loadCachedData();
  }

  void _startCleanupTimer() {
    _cleanupTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _cleanExpiredCache();
    });
  }

  void _cleanExpiredCache() {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    _lastUpdated.forEach((key, timestamp) {
      if (now.difference(timestamp) > _cacheExpiration) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      _teamCache.remove(key);
      _membersCache.remove(key);
      _lastUpdated.remove(key);
    }

    if (expiredKeys.isNotEmpty) {
      _saveCachedData();
    }
  }

  Future<void> _saveCachedData() async {
    final teamData =
        _teamCache.map((key, value) => MapEntry(key, value.toJson()));
    final membersData = _membersCache.map(
      (key, value) => MapEntry(key, value.map((m) => m.toJson()).toList()),
    );

    await _prefs.setString(_teamCacheKey, teamData.toString());
    await _prefs.setString(_membersCacheKey, membersData.toString());
  }

  void _loadCachedData() {
    final teamData = _prefs.getString(_teamCacheKey);
    final membersData = _prefs.getString(_membersCacheKey);

    if (teamData != null) {
      try {
        final Map<String, dynamic> teamMap = Map<String, dynamic>.from(
          Map.from(teamData as Map<String, dynamic>),
        );
        _teamCache.value = Map.fromEntries(
          teamMap.entries.map(
            (entry) => MapEntry(
              entry.key,
              Team.fromJson(entry.value as Map<String, dynamic>),
            ),
          ),
        );
      } catch (e) {
        print('Takım verilerini yüklerken hata: $e');
        _teamCache.value = {};
      }
    }

    if (membersData != null) {
      try {
        final Map<String, dynamic> membersMap = Map<String, dynamic>.from(
          Map.from(membersData as Map<String, dynamic>),
        );
        _membersCache.value = Map.fromEntries(
          membersMap.entries.map(
            (entry) => MapEntry(
              entry.key,
              (entry.value as List)
                  .map((m) => TeamMember.fromJson(m as Map<String, dynamic>))
                  .toList(),
            ),
          ),
        );
      } catch (e) {
        print('Takım üyesi verilerini yüklerken hata: $e');
        _membersCache.value = {};
      }
    }
  }

  Future<Team?> getTeam(String teamId) async {
    final team = _teamCache[teamId];
    if (team != null && !_isCacheExpired(teamId)) {
      return team;
    }
    return null;
  }

  Future<List<TeamMember>?> getTeamMembers(String teamId,
      {int page = 0, int pageSize = 20}) async {
    final members = _membersCache[teamId];
    if (members != null && !_isCacheExpired(teamId)) {
      final start = page * pageSize;
      final end = start + pageSize;
      if (start >= members.length) return [];
      return members.sublist(start, end.clamp(0, members.length));
    }
    return null;
  }

  void cacheTeam(String teamId, Team team) {
    _teamCache[teamId] = team;
    _updateTimestamp(teamId);
    _saveCachedData();
  }

  void cacheTeamMembers(String teamId, List<TeamMember> members) {
    _membersCache[teamId] = members;
    _updateTimestamp(teamId);
    _saveCachedData();
  }

  void invalidateCache(String teamId) {
    _teamCache.remove(teamId);
    _membersCache.remove(teamId);
    _lastUpdated.remove(teamId);
    _saveCachedData();
  }

  void _updateTimestamp(String teamId) {
    _lastUpdated[teamId] = DateTime.now();
  }

  bool _isCacheExpired(String teamId) {
    final timestamp = _lastUpdated[teamId];
    if (timestamp == null) return true;
    return DateTime.now().difference(timestamp) > _cacheExpiration;
  }
}
