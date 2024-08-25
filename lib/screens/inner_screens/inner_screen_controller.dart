import 'dart:developer';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuncbt/models/comment_model.dart';
import 'package:tuncbt/models/user_model.dart';
import 'package:tuncbt/models/task_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:tuncbt/config/constants.dart';

class InnerScreenController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Common variables
  final RxBool isLoading = false.obs;
  final RxString currentUserId = ''.obs;

  // User related variables
  final Rx<UserModel> currentUser = UserModel.empty().obs;
  final RxBool isSameUser = false.obs;

  // Task related variables
  final Rx<TaskModel> currentTask = TaskModel.empty().obs;
  final RxBool isCommenting = false.obs;
  final commentController = TextEditingController();

  // Upload Task variables
  final TextEditingController taskCategoryController =
      TextEditingController(text: 'Choose task category');
  final TextEditingController taskTitleController = TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();
  final TextEditingController deadlineDateController =
      TextEditingController(text: 'Choose task Deadline date');
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final Rx<DateTime?> picked = Rx<DateTime?>(null);
  final Rx<Timestamp?> deadlineDateTimeStamp = Rx<Timestamp?>(null);

  @override
  void onInit() {
    super.onInit();
    ever(currentUserId, (_) => getUserData(currentUserId.value));
    if (Get.arguments != null && Get.arguments['userId'] != null) {
      currentUserId.value = Get.arguments['userId'];
    } else {
      final User? user = _auth.currentUser;
      if (user != null) {
        currentUserId.value = user.uid;
      } else {
        log("No user ID provided and no user is logged in");
      }
    }
  }

  Future<void> getUserData(String userId) async {
    try {
      isLoading.value = true;
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        currentUser.value = UserModel.fromFirestore(userDoc);
        final User? user = _auth.currentUser;
        isSameUser.value = user?.uid == userId;
      } else {
        log('User document does not exist for userId: $userId');
        currentUser.value = UserModel.empty();
      }
    } catch (e) {
      log('Error retrieving user data: $e');
      Get.snackbar('Error', 'Failed to retrieve user data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar('Error', 'Could not launch $url');
    }
  }

  void openWhatsAppChat() => launchURL(
      'https://wa.me/${currentUser.value.phoneNumber}?text=HelloWorld');
  void mailTo() => launchURL('mailto:${currentUser.value.email}');
  void callPhoneNumber() => launchURL('tel://${currentUser.value.phoneNumber}');

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> getTaskData(String taskId) async {
    try {
      isLoading.value = true;
      final DocumentSnapshot taskDoc =
          await _firestore.collection('tasks').doc(taskId).get();

      if (taskDoc.exists) {
        currentTask.value = TaskModel.fromFirestore(taskDoc);
        await getUserData(currentTask.value.uploadedBy);
      } else {
        log('Task document does not exist for ID: $taskId');
        Get.back(); // Navigate back or show an error message
      }
    } catch (e) {
      log('Error fetching task data: $e');
      Get.snackbar('Error', 'Failed to fetch task data');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addComment(String taskID) async {
    if (commentController.text.length < 7) {
      Get.snackbar('Error', 'Comment can\'t be less than 7 characters');
      return;
    }

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Error', 'User not logged in');
        return;
      }

      CommentModel newComment = CommentModel(
        id: const Uuid().v4(),
        userId: user.uid,
        name: currentUser.value.name,
        userImageUrl: currentUser.value.userImage,
        body: commentController.text,
        time: DateTime.now(),
      );

      await _firestore.collection('tasks').doc(taskID).update({
        'taskComments': FieldValue.arrayUnion([newComment.toMap()]),
      });

      currentTask.update((task) {
        task!.comments.add(newComment);
      });

      log("Comment successfully added to Firestore");

      await Fluttertoast.showToast(
        msg: "Your comment has been added",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.grey,
        fontSize: 18.0,
      );

      commentController.clear();
      isCommenting.value = false;

      log("Comment process completed successfully");
    } catch (error) {
      log("Error adding comment: $error");
      Get.snackbar('Error', 'Failed to add comment: $error');
    }
  }

  void toggleCommenting() {
    isCommenting.value = !isCommenting.value;
  }

  void updateTaskStatus(String taskId, bool newStatus) async {
    User? user = _auth.currentUser;
    final uid = user!.uid;
    if (uid == currentTask.value.uploadedBy) {
      try {
        await _firestore
            .collection('tasks')
            .doc(taskId)
            .update({'isDone': newStatus});
        currentTask.update((task) {
          task!.isDone = newStatus;
        });
        Get.snackbar('Success', 'Task status updated');
      } catch (err) {
        Get.snackbar('Error', 'Action can\'t be performed');
      }
    } else {
      Get.snackbar('Error', 'You can\'t perform this action');
    }
  }

  void uploadTask() async {
    if (!_validateForm()) return;

    isLoading.value = true;
    try {
      await _saveTaskToFirestore();
      _resetForm();
      Fluttertoast.showToast(
          msg: "The task has been uploaded",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0);
    } catch (e) {
      log('Error uploading task: $e');
      Get.snackbar('Error', 'Failed to upload task');
    } finally {
      isLoading.value = false;
    }
  }

  bool _validateForm() {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return false;
    if (deadlineDateController.text == 'Choose task Deadline date' ||
        taskCategoryController.text == 'Choose task category') {
      Get.snackbar('Error', 'Please pick everything');
      return false;
    }
    return true;
  }

  Future<void> _saveTaskToFirestore() async {
    final taskID = const Uuid().v4();
    final uid = _auth.currentUser!.uid;
    final newTask = TaskModel(
      id: taskID,
      uploadedBy: uid,
      title: taskTitleController.text,
      description: taskDescriptionController.text,
      deadline: deadlineDateTimeStamp.value!.toDate(),
      deadlineDate: deadlineDateController.text,
      category: taskCategoryController.text,
      comments: [],
      isDone: false,
      createdAt: DateTime.now(),
    );
    await _firestore.collection('tasks').doc(taskID).set(newTask.toFirestore());
  }

  void _resetForm() {
    taskTitleController.clear();
    taskDescriptionController.clear();
    taskCategoryController.text = 'Choose task category';
    deadlineDateController.text = 'Choose task Deadline date';
  }

  void showTaskCategoriesDialog(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                  taskCategoryController.text =
                      Constants.taskCategoryList[index];
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
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void pickDateDialog(BuildContext context) async {
    picked.value = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 0)),
      lastDate: DateTime(2100),
    );

    if (picked.value != null) {
      deadlineDateController.text =
          '${picked.value!.year}-${picked.value!.month}-${picked.value!.day}';
      deadlineDateTimeStamp.value = Timestamp.fromDate(picked.value!);
    }
  }
}
