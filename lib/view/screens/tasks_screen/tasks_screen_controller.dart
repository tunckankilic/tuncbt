import 'dart:developer';

import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncbt/core/config/constants.dart';

class TasksScreenController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList tasks = [].obs;
  final RxString currentFilter = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTasks();
  }

  void fetchTasks() {
    isLoading.value = true;
    FirebaseFirestore.instance.collection('tasks').snapshots().listen(
        (snapshot) {
      tasks.value = snapshot.docs.map((doc) => doc.data()).toList();
      applyFilter();
      isLoading.value = false;
    }, onError: (error) {
      log("Error fetching tasks: $error");
      isLoading.value = false;
    });
  }

  void showTaskCategoriesDialog(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    Get.dialog(
      AlertDialog(
        title: Text(
          'Task Category',
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
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              currentFilter.value = '';
              applyFilter();
              Get.back();
            },
            child: const Text('Cancel filter'),
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
