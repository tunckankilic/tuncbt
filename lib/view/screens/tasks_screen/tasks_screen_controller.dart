import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TasksScreenController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList tasks = [].obs;
  final RxString currentFilter = ''.obs;
  final RxString errorMessage = ''.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    _initializeUser();
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
          fetchTasks();
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

  void fetchTasks() {
    try {
      if (currentUser.value?.teamId == null) {
        errorMessage.value = 'Henüz bir takıma ait değilsiniz';
        return;
      }

      isLoading.value = true;
      _firestore
          .collection('tasks')
          .where('teamId', isEqualTo: currentUser.value!.teamId)
          .snapshots()
          .listen(
        (snapshot) {
          tasks.value = snapshot.docs.map((doc) => doc.data()).toList();
          applyFilter();
          isLoading.value = false;
          errorMessage.value = '';
        },
        onError: (error) {
          log("Error fetching tasks: $error");
          errorMessage.value = 'Görevler yüklenirken hata oluştu';
          isLoading.value = false;
        },
      );
    } catch (e) {
      log("Error in fetchTasks: $e");
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
}
