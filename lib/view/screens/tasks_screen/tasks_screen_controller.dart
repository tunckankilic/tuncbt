import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/core/services/team_service_controller.dart';
import 'package:tuncbt/core/services/firebase_listener_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TasksScreenController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString currentFilter = ''.obs;
  final RxString errorMessage = ''.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final TeamServiceController _teamController;
  late final FirebaseListenerService _listenerService;

  TasksScreenController() {
    _teamController = Get.find<TeamServiceController>();
    _listenerService = Get.find<FirebaseListenerService>();
  }

  // Get tasks from FirebaseListenerService (reactive)
  RxList<Map<String, dynamic>> get tasks => _listenerService.teamTasks;

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
    _setupTeamListener();
  }

  void _setupTeamListener() {
    // Listen to team changes using GetX reactivity
    ever(_teamController.currentTeam, (_) => _onTeamChanged());
    ever(_teamController.isInitialized, (_) => _onTeamChanged());
  }

  void _onTeamChanged() {
    if (_teamController.isInitialized.value && _teamController.teamId != null) {
      print(
          'TasksScreenController: Takım değişikliği algılandı - TeamID: ${_teamController.teamId}');
      _setupTasksStream();
    }
  }

  @override
  void onClose() {
    // FirebaseListenerService handles subscription cleanup automatically
    super.onClose();
  }

  Future<void> _initializeUser() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user != null) {
        final userData =
            await _firestore.collection('users').doc(user.uid).get();

        if (userData.exists) {
          currentUser.value = UserModel.fromFirestore(userData);
          if (currentUser.value?.teamId != null) {
            print(
                'TasksScreenController: Kullanıcı takımı bulundu - TeamID: ${currentUser.value?.teamId}');
            _setupTasksStream();
          } else {
            print('TasksScreenController: Kullanıcının takımı yok');
            errorMessage.value = 'Henüz bir takıma ait değilsiniz';
          }
        } else {
          errorMessage.value = 'Kullanıcı bilgileri bulunamadı';
        }
      } else {
        errorMessage.value = 'Oturum açmanız gerekiyor';
      }
    } catch (e) {
      log("Error initializing user: $e");
      errorMessage.value = 'Kullanıcı bilgileri yüklenirken hata oluştu';
    } finally {
      isLoading.value = false;
    }
  }

  void _setupTasksStream() {
    try {
      if (_teamController.teamId == null) {
        errorMessage.value = 'Henüz bir takıma ait değilsiniz';
        print('TasksScreenController: TeamID bulunamadı');
        return;
      }

      print(
          'TasksScreenController: Firebase listener kurulumu... TeamID: ${_teamController.teamId}');
      isLoading.value = true;

      // Setup listeners through FirebaseListenerService
      _listenerService.setupTeamListeners(_teamController.teamId!);

      isLoading.value = false;
      errorMessage.value = '';

      print('TasksScreenController: Firebase listener kurulumu tamamlandı');
    } catch (e) {
      print('TasksScreenController: _setupTasksStream error: $e');
      errorMessage.value = 'Görevler yüklenirken hata oluştu: $e';
      isLoading.value = false;
    }
  }

  void setFilter(String filter) {
    currentFilter.value = filter;
    applyFilter();
  }

  void applyFilter() {
    // Filter is now handled by FirebaseListenerService.getFilteredTasks
    print('TasksScreenController: Filter uygulandı: ${currentFilter.value}');
  }

  // Get filtered tasks
  List<Map<String, dynamic>> getFilteredTasks() {
    if (currentFilter.value.isEmpty) {
      return tasks;
    }

    return _listenerService.getFilteredTasks(
      category: currentFilter.value,
    );
  }

  void refreshTasks() async {
    if (_teamController.teamId != null) {
      _setupTasksStream();
    }
  }

  void addTask(Map<String, dynamic> taskData) async {
    try {
      isLoading.value = true;
      if (_teamController.teamId == null) {
        throw Exception('Takım ID bulunamadı');
      }

      // Görev verilerine ekstra alanlar ekleme
      taskData.addAll({
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid,
        'teamId': _teamController.teamId,
      });

      // Firestore'a görevi ekleme
      await _firestore
          .collection(Constants.teamsCollection)
          .doc(_teamController.teamId)
          .collection(Constants.tasksCollection)
          .add(taskData);

      print('TasksScreenController: Yeni görev başarıyla eklendi');
    } catch (e) {
      errorMessage.value = 'Görev eklenirken hata oluştu: $e';
      print('TasksScreenController: addTask error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateTask(String taskId, Map<String, dynamic> updates) async {
    try {
      isLoading.value = true;
      if (_teamController.teamId == null) {
        throw Exception('Takım ID bulunamadı');
      }

      // Güncelleme zamanını ekleme
      updates['updatedAt'] = FieldValue.serverTimestamp();
      updates['updatedBy'] = _auth.currentUser?.uid;

      // Firestore'da görevi güncelleme
      await _firestore
          .collection(Constants.teamsCollection)
          .doc(_teamController.teamId)
          .collection(Constants.tasksCollection)
          .doc(taskId)
          .update(updates);

      print('TasksScreenController: Görev başarıyla güncellendi: $taskId');
    } catch (e) {
      errorMessage.value = 'Görev güncellenirken hata oluştu: $e';
      print('TasksScreenController: updateTask error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void deleteTask(String taskId) async {
    try {
      isLoading.value = true;
      if (_teamController.teamId == null) {
        throw Exception('Takım ID bulunamadı');
      }

      // Firestore'dan görevi silme
      await _firestore
          .collection(Constants.teamsCollection)
          .doc(_teamController.teamId)
          .collection(Constants.tasksCollection)
          .doc(taskId)
          .delete();

      print('TasksScreenController: Görev başarıyla silindi: $taskId');
    } catch (e) {
      errorMessage.value = 'Görev silinirken hata oluştu: $e';
      print('TasksScreenController: deleteTask error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Category filtering methods
  void filterByCategory(String category) {
    if (category == 'All' || category == 'Tümü') {
      currentFilter.value = '';
    } else {
      currentFilter.value = category;
    }
    applyFilter();
  }

  // Status filtering methods
  void filterByStatus(String status) {
    currentFilter.value = status;
    applyFilter();
  }

  // Get task counts
  int get totalTasks => tasks.length;
  int get completedTasks =>
      tasks.where((task) => task['isDone'] == true).length;
  int get pendingTasks => tasks.where((task) => task['isDone'] == false).length;

  // Get tasks by category
  List<Map<String, dynamic>> getTasksByCategory(String category) {
    return _listenerService.getFilteredTasks(category: category);
  }

  // Get tasks by status
  List<Map<String, dynamic>> getTasksByStatus(bool isDone) {
    return tasks
        .where((task) => task['isDone'] == isDone)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  // Search tasks
  List<Map<String, dynamic>> searchTasks(String query) {
    return _listenerService.getFilteredTasks(searchQuery: query);
  }

  void addTestTask() {
    final testTask = {
      'taskTitle': 'Test Görevi',
      'taskDescription': 'Bu bir test görevidir.',
      'isDone': false,
      'uploadedBy': _auth.currentUser?.uid,
      'taskCategory': 'Genel',
    };
    addTask(testTask);
  }
}
