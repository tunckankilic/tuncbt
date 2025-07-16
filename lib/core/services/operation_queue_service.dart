import 'dart:async';
import 'dart:collection';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

enum OperationType {
  joinTeam,
  leaveTeam,
  updateRole,
  removeUser,
  updateTeamSettings,
}

class QueuedOperation {
  final OperationType type;
  final Map<String, dynamic> data;
  final Completer<bool> completer;
  final DateTime timestamp;

  QueuedOperation({
    required this.type,
    required this.data,
    required this.completer,
  }) : timestamp = DateTime.now();
}

class OperationQueueService extends GetxService {
  final RxBool isProcessing = false.obs;
  final RxInt queueLength = 0.obs;
  final RxString currentOperation = ''.obs;

  final Queue<QueuedOperation> _operationQueue = Queue<QueuedOperation>();
  Timer? _queueTimer;

  @override
  void onInit() {
    super.onInit();
    _startQueueProcessor();
  }

  @override
  void onClose() {
    _queueTimer?.cancel();
    super.onClose();
  }

  void _startQueueProcessor() {
    // Her 1 saniyede bir kuyruğu kontrol et
    _queueTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _processQueue();
    });
  }

  Future<void> _processQueue() async {
    if (isProcessing.value || _operationQueue.isEmpty) {
      return;
    }

    try {
      isProcessing.value = true;
      final operation = _operationQueue.first;
      currentOperation.value = operation.type.toString();

      print('OperationQueueService: İşlem başlatılıyor - ${operation.type}');
      print('OperationQueueService: İşlem verisi - ${operation.data}');

      bool success = false;
      switch (operation.type) {
        case OperationType.joinTeam:
          success = await _processJoinTeam(operation.data);
          break;
        case OperationType.leaveTeam:
          success = await _processLeaveTeam(operation.data);
          break;
        case OperationType.updateRole:
          success = await _processUpdateRole(operation.data);
          break;
        case OperationType.removeUser:
          success = await _processRemoveUser(operation.data);
          break;
        case OperationType.updateTeamSettings:
          success = await _processUpdateTeamSettings(operation.data);
          break;
      }

      operation.completer.complete(success);
      _operationQueue.removeFirst();
      queueLength.value = _operationQueue.length;

      print('OperationQueueService: İşlem tamamlandı - Başarı: $success');
    } catch (e) {
      print('OperationQueueService: İşlem hatası - $e');
      if (_operationQueue.isNotEmpty) {
        _operationQueue.first.completer.completeError(e);
        _operationQueue.removeFirst();
        queueLength.value = _operationQueue.length;
      }
    } finally {
      isProcessing.value = false;
      currentOperation.value = '';
    }
  }

  // Add operation to queue
  Future<bool> enqueueOperation(
      OperationType type, Map<String, dynamic> data) async {
    final completer = Completer<bool>();

    _operationQueue.add(QueuedOperation(
      type: type,
      data: data,
      completer: completer,
    ));

    queueLength.value = _operationQueue.length;
    print(
        'OperationQueueService: İşlem kuyruğa eklendi - $type, Kuyruk uzunluğu: ${queueLength.value}');

    return completer.future;
  }

  // Process team join operation
  Future<bool> _processJoinTeam(Map<String, dynamic> data) async {
    try {
      final teamId = data['teamId'] as String;
      final userId = data['userId'] as String;
      final role = data['role'] as String;

      // Önce mevcut üyelik kontrolü
      final existingMembership = await _checkExistingMembership(teamId, userId);
      if (existingMembership) {
        print('OperationQueueService: Kullanıcı zaten takım üyesi');
        return false;
      }

      // Takım kapasitesi kontrolü
      final teamCapacity = await _checkTeamCapacity(teamId);
      if (!teamCapacity) {
        print('OperationQueueService: Takım kapasitesi dolu');
        return false;
      }

      // Üyelik oluştur
      await _createTeamMembership(teamId, userId, role);

      // Kullanıcı bilgilerini güncelle
      await _updateUserTeamInfo(userId, teamId, role);

      print('OperationQueueService: Takıma katılma işlemi başarılı');
      return true;
    } catch (e) {
      print('OperationQueueService: Takıma katılma hatası - $e');
      return false;
    }
  }

  // Process team leave operation
  Future<bool> _processLeaveTeam(Map<String, dynamic> data) async {
    try {
      final teamId = data['teamId'] as String;
      final userId = data['userId'] as String;

      // Üyeliği pasif yap
      await _deactivateTeamMembership(teamId, userId);

      // Kullanıcı bilgilerini temizle
      await _clearUserTeamInfo(userId);

      print('OperationQueueService: Takımdan ayrılma işlemi başarılı');
      return true;
    } catch (e) {
      print('OperationQueueService: Takımdan ayrılma hatası - $e');
      return false;
    }
  }

  // Process role update operation
  Future<bool> _processUpdateRole(Map<String, dynamic> data) async {
    try {
      final teamId = data['teamId'] as String;
      final userId = data['userId'] as String;
      final newRole = data['newRole'] as String;

      // Üyelik rolünü güncelle
      await _updateMembershipRole(teamId, userId, newRole);

      // Kullanıcı rolünü güncelle
      await _updateUserRole(userId, newRole);

      print('OperationQueueService: Rol güncelleme işlemi başarılı');
      return true;
    } catch (e) {
      print('OperationQueueService: Rol güncelleme hatası - $e');
      return false;
    }
  }

  // Process user removal operation
  Future<bool> _processRemoveUser(Map<String, dynamic> data) async {
    try {
      final teamId = data['teamId'] as String;
      final userId = data['userId'] as String;

      // Üyeliği pasif yap
      await _deactivateTeamMembership(teamId, userId);

      // Kullanıcı bilgilerini temizle
      await _clearUserTeamInfo(userId);

      print('OperationQueueService: Kullanıcı çıkarma işlemi başarılı');
      return true;
    } catch (e) {
      print('OperationQueueService: Kullanıcı çıkarma hatası - $e');
      return false;
    }
  }

  // Process team settings update operation
  Future<bool> _processUpdateTeamSettings(Map<String, dynamic> data) async {
    try {
      final teamId = data['teamId'] as String;
      final settings = data['settings'] as Map<String, dynamic>;

      // Takım ayarlarını güncelle
      await _updateTeamSettings(teamId, settings);

      print('OperationQueueService: Takım ayarları güncelleme işlemi başarılı');
      return true;
    } catch (e) {
      print('OperationQueueService: Takım ayarları güncelleme hatası - $e');
      return false;
    }
  }

  // Helper methods for Firebase operations
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> _checkExistingMembership(String teamId, String userId) async {
    try {
      final memberDoc = await _firestore
          .collection('team_members')
          .doc('${teamId}_$userId')
          .get();

      return memberDoc.exists && (memberDoc.data()?['isActive'] ?? false);
    } catch (e) {
      print('OperationQueueService: Üyelik kontrolü hatası - $e');
      return false;
    }
  }

  Future<bool> _checkTeamCapacity(String teamId) async {
    try {
      final teamDoc = await _firestore.collection('teams').doc(teamId).get();

      if (!teamDoc.exists) {
        return false;
      }

      final int currentMembers = teamDoc.data()?['memberCount'] ?? 0;
      final int maxMembers = teamDoc.data()?['maxMembers'] ?? 50;

      return currentMembers < maxMembers;
    } catch (e) {
      print('OperationQueueService: Takım kapasitesi kontrolü hatası - $e');
      return false;
    }
  }

  Future<void> _createTeamMembership(
      String teamId, String userId, String role) async {
    final membershipData = {
      'teamId': teamId,
      'userId': userId,
      'role': role,
      'isActive': true,
      'joinedAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    };

    final batch = _firestore.batch();

    // Create team membership
    batch.set(
      _firestore.collection('team_members').doc('${teamId}_$userId'),
      membershipData,
    );

    // Increment team member count
    batch.update(
      _firestore.collection('teams').doc(teamId),
      {'memberCount': FieldValue.increment(1)},
    );

    await batch.commit();
  }

  Future<void> _updateUserTeamInfo(
      String userId, String teamId, String role) async {
    await _firestore.collection('users').doc(userId).update({
      'teamId': teamId,
      'hasTeam': true,
      'teamRole': role,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _deactivateTeamMembership(String teamId, String userId) async {
    final batch = _firestore.batch();

    // Deactivate membership
    batch.update(
      _firestore.collection('team_members').doc('${teamId}_$userId'),
      {
        'isActive': false,
        'leftAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      },
    );

    // Decrement team member count
    batch.update(
      _firestore.collection('teams').doc(teamId),
      {'memberCount': FieldValue.increment(-1)},
    );

    await batch.commit();
  }

  Future<void> _clearUserTeamInfo(String userId) async {
    await _firestore.collection('users').doc(userId).update({
      'teamId': null,
      'hasTeam': false,
      'teamRole': null,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateMembershipRole(
      String teamId, String userId, String newRole) async {
    await _firestore
        .collection('team_members')
        .doc('${teamId}_$userId')
        .update({
      'role': newRole,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateUserRole(String userId, String newRole) async {
    await _firestore.collection('users').doc(userId).update({
      'teamRole': newRole,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _updateTeamSettings(
      String teamId, Map<String, dynamic> settings) async {
    settings['lastUpdated'] = FieldValue.serverTimestamp();
    await _firestore.collection('teams').doc(teamId).update(settings);
  }

  // Debug methods
  void debugPrintQueue() {
    print('OperationQueueService: Kuyruk durumu:');
    print('İşlem sayısı: ${_operationQueue.length}');
    print('İşleniyor: ${isProcessing.value}');
    print('Mevcut işlem: ${currentOperation.value}');

    var index = 0;
    for (final operation in _operationQueue) {
      print('[$index] ${operation.type} - ${operation.timestamp}');
      index++;
    }
  }
}
