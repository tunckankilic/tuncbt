import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeamSync extends GetxService {
  static const String _pendingOperationsKey = 'pending_operations';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late SharedPreferences _prefs;
  Timer? _syncTimer;

  @override
  void onInit() {
    super.onInit();
    _initSync();
    _startSyncTimer();
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    super.onClose();
  }

  Future<void> _initSync() async {
    _prefs = await SharedPreferences.getInstance();
    await _processPendingOperations();
  }

  void _startSyncTimer() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      _processPendingOperations();
    });
  }

  Future<void> queueOperation(
    String teamId,
    String operationType,
    Map<String, dynamic> data,
  ) async {
    final operations = _prefs.getStringList(_pendingOperationsKey) ?? [];
    operations.add('$teamId|$operationType|${data.toString()}');
    await _prefs.setStringList(_pendingOperationsKey, operations);
  }

  Future<void> _processPendingOperations() async {
    final operations = _prefs.getStringList(_pendingOperationsKey) ?? [];
    if (operations.isEmpty) return;

    for (final operation in operations) {
      final parts = operation.split('|');
      if (parts.length != 3) continue;

      final teamId = parts[0];
      final operationType = parts[1];
      final data = _parseData(parts[2]);

      try {
        await _executeOperation(teamId, operationType, data);
        operations.remove(operation);
      } catch (e) {
        print('Error processing operation: $e');
        // Hata durumunda işlemi kuyrukta tut
        continue;
      }
    }

    await _prefs.setStringList(_pendingOperationsKey, operations);
  }

  Map<String, dynamic> _parseData(String dataString) {
    try {
      final cleanString = dataString
          .replaceAll('{', '')
          .replaceAll('}', '')
          .replaceAll(' ', '');
      final pairs = cleanString.split(',');
      final map = <String, dynamic>{};

      for (final pair in pairs) {
        final keyValue = pair.split(':');
        if (keyValue.length != 2) continue;
        map[keyValue[0]] = keyValue[1];
      }

      return map;
    } catch (e) {
      print('Error parsing data: $e');
      return {};
    }
  }

  Future<void> _executeOperation(
    String teamId,
    String operationType,
    Map<String, dynamic> data,
  ) async {
    final teamRef = _firestore.collection('teams').doc(teamId);

    switch (operationType) {
      case 'update':
        await teamRef.update(data);
        break;
      case 'delete':
        await teamRef.delete();
        break;
      case 'set':
        await teamRef.set(data, SetOptions(merge: true));
        break;
      default:
        throw Exception('Unknown operation type: $operationType');
    }
  }
}
