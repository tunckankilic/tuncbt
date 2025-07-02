import 'dart:async';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/providers/team_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TasksScreenController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList tasks = [].obs;
  final RxString currentFilter = ''.obs;
  final RxString errorMessage = ''.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late final TeamProvider _teamProvider;
  StreamSubscription? _tasksSubscription;

  TasksScreenController() {
    _teamProvider = Provider.of<TeamProvider>(Get.context!, listen: false);
  }

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
    _setupTeamListener();
  }

  void _setupTeamListener() {
    _teamProvider.addListener(_onTeamProviderChanged);
  }

  void _onTeamProviderChanged() {
    if (_teamProvider.isInitialized && _teamProvider.teamId != null) {
      print(
          'TasksScreenController: Takım değişikliği algılandı - TeamID: ${_teamProvider.teamId}');
      _setupTasksStream();
    }
  }

  @override
  void onClose() {
    _tasksSubscription?.cancel();
    _teamProvider.removeListener(_onTeamProviderChanged);
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
      if (_teamProvider.teamId == null) {
        errorMessage.value = 'Henüz bir takıma ait değilsiniz';
        print('TasksScreenController: TeamID bulunamadı');
        return;
      }

      print(
          'TasksScreenController: Görevler dinleniyor... TeamID: ${_teamProvider.teamId}');
      isLoading.value = true;

      final tasksRef = _firestore
          .collection('teams')
          .doc(_teamProvider.teamId)
          .collection('tasks');

      print('TasksScreenController: Görev koleksiyonu yolu: ${tasksRef.path}');

      // Önceki subscription'ı iptal et
      _tasksSubscription?.cancel();

      // Yeni subscription oluştur
      _tasksSubscription =
          tasksRef.orderBy('createdAt', descending: true).snapshots().listen(
        (snapshot) {
          print(
              'TasksScreenController: Görev snapshot alındı - Doküman sayısı: ${snapshot.docs.length}');

          tasks.value = snapshot.docs.map((doc) {
            final data = doc.data();
            data['taskId'] = doc.id;
            // Eksik alanlar için varsayılan değerler ekle
            data['teamId'] = data['teamId'] ?? _teamProvider.teamId;
            data['taskTitle'] = data['taskTitle'] ?? '';
            data['taskDescription'] = data['taskDescription'] ?? '';
            data['taskCategory'] = data['taskCategory'] ?? 'Genel';
            data['uploadedBy'] = data['uploadedBy'] ?? '';
            data['isDone'] = data['isDone'] ?? false;
            data['createdAt'] = data['createdAt'] ?? Timestamp.now();
            data['taskComments'] = data['taskComments'] ?? [];
            print('TasksScreenController: Görev verisi: $data');
            return data;
          }).toList();

          print('TasksScreenController: ${tasks.length} görev güncellendi');
          applyFilter();
          isLoading.value = false;
          errorMessage.value = '';
        },
        onError: (error) {
          log("Error fetching tasks: $error");
          print('TasksScreenController: Görev yükleme hatası: $error');
          errorMessage.value = 'Görevler yüklenirken hata oluştu: $error';
          isLoading.value = false;
        },
      );
    } catch (e) {
      log("Error in setupTasksStream: $e");
      print('TasksScreenController: Beklenmeyen hata: $e');
      errorMessage.value = 'Görevler yüklenirken beklenmeyen bir hata oluştu';
      isLoading.value = false;
    }
  }

  void showTaskCategoriesDialog(BuildContext context) {
    if (currentUser.value?.teamId == null) {
      Get.snackbar(
        'Hata',
        'Kategori filtrelemesi için bir takıma ait olmanız gerekiyor',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final Size size = MediaQuery.of(context).size;

    Get.dialog(
      AlertDialog(
        title: Text(
          'Görev Kategorisi',
          style: TextStyle(fontSize: 20, color: Colors.pink.shade800),
        ),
        content: SizedBox(
          width: size.width * 0.9,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: Constants.taskCategoryList.length,
            itemBuilder: (ctx, index) {
              return InkWell(
                onTap: () {
                  filterTasks(Constants.taskCategoryList[index]);
                  Get.back();
                },
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Colors.red.shade200,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        Constants.taskCategoryList[index],
                        style: TextStyle(
                          color: Constants.darkBlue,
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Kapat'),
          ),
          TextButton(
            onPressed: () {
              currentFilter.value = '';
              applyFilter();
              Get.back();
            },
            child: const Text('Filtreyi Kaldır'),
          ),
        ],
      ),
    );
  }

  void filterTasks(String category) {
    currentFilter.value = category;
    applyFilter();
  }

  void applyFilter() {
    if (currentFilter.value.isEmpty) {
      // If no filter, show all tasks
      tasks.refresh();
    } else {
      // Filter tasks based on the selected category
      tasks.value = tasks
          .where((task) => task['taskCategory'] == currentFilter.value)
          .toList();
    }
  }

  // Test için örnek görev ekleme fonksiyonu
  Future<void> addTestTask() async {
    try {
      if (_teamProvider.teamId == null) {
        errorMessage.value = 'Henüz bir takıma ait değilsiniz';
        return;
      }

      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Oturum açmanız gerekiyor';
        return;
      }

      print(
          'TasksScreenController: Test görevi ekleniyor... TeamID: ${_teamProvider.teamId}');

      final taskData = {
        'taskTitle': 'Test Görevi',
        'taskDescription': 'Bu bir test görevidir.',
        'taskCategory': 'Genel',
        'isDone': false,
        'uploadedBy': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final tasksRef = _firestore
          .collection('teams')
          .doc(_teamProvider.teamId)
          .collection('tasks');

      print('TasksScreenController: Görev koleksiyonu yolu: ${tasksRef.path}');

      final docRef = await tasksRef.add(taskData);
      print(
          'TasksScreenController: Test görevi eklendi - TaskID: ${docRef.id}');
    } catch (e) {
      log("Error adding test task: $e");
      print('TasksScreenController: Test görevi ekleme hatası: $e');
      errorMessage.value = 'Test görevi eklenirken hata oluştu';
    }
  }
}
