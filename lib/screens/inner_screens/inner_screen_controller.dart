import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:tuncbt/constants/constants.dart';

class InnerScreenController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Profile Screen variables
  final RxBool isLoading = false.obs;
  final RxString phoneNumber = "".obs;
  final RxString email = "".obs;
  final RxString name = "".obs;
  final RxString job = ''.obs;
  final RxString imageUrl = "".obs;
  final RxString joinedAt = " ".obs;
  final RxBool isSameUser = false.obs;
  final RxString uploadedBy = "".obs;

  // Task Details Screen variables
  final RxBool isDone = false.obs;
  final RxString taskTitle = "".obs;
  final RxString taskDescription = "".obs;
  final RxString authorName = "".obs;
  final RxString authorPosition = "".obs;
  final RxString userImageUrl = "".obs;
  final RxString postedDate = "".obs;
  final RxString deadlineDate = "".obs;
  final RxBool isDeadlineAvailable = false.obs;
  final isCommenting = false.obs;
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
  Rx<DateTime?> picked = Rx<DateTime?>(null);
  Rx<Timestamp?> deadlineDateTimeStamp = Rx<Timestamp?>(null);

  // Profile Screen methods
  Future<void> getUserData(String userId) async {
    try {
      isLoading.value = true;
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      email.value = userDoc.get('email');
      name.value = userDoc.get('name');
      job.value = userDoc.get('positionInCompany');
      phoneNumber.value = userDoc.get('phoneNumber');
      imageUrl.value = userDoc.get('userImage');
      Timestamp joinedAtTimeStamp = userDoc.get('createdAt');
      var joinedDate = joinedAtTimeStamp.toDate();
      joinedAt.value =
          '${joinedDate.year}-${joinedDate.month}-${joinedDate.day}';

      final User? user = _auth.currentUser;
      final uid = user!.uid;
      isSameUser.value = uid == userId;
    } finally {
      isLoading.value = false;
    }
  }

  void openWhatsAppChat() async {
    final url = 'https://wa.me/${phoneNumber.value}?text=HelloWorld';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar('Error', 'Could not launch WhatsApp');
    }
  }

  void mailTo() async {
    final url = 'mailto:${email.value}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar('Error', 'Could not launch email client');
    }
  }

  void callPhoneNumber() async {
    final url = 'tel://${phoneNumber.value}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar('Error', 'Could not make a call');
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // Task Details Screen methods
  Future<void> getTaskData(String taskId, String taskUploadedBy) async {
    final DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(taskUploadedBy).get();
    authorName.value = userDoc.get('name');
    authorPosition.value = userDoc.get('positionInCompany');
    userImageUrl.value = userDoc.get('userImage');

    final DocumentSnapshot taskDatabase =
        await _firestore.collection('tasks').doc(taskId).get();
    taskTitle.value = taskDatabase.get('taskTitle');
    taskDescription.value = taskDatabase.get('taskDescription');
    isDone.value = taskDatabase.get('isDone');
    Timestamp postedDateTimeStamp = taskDatabase.get('createdAt');
    Timestamp deadlineDateTimeStamp = taskDatabase.get('deadlineDateTimeStamp');
    deadlineDate.value = taskDatabase.get('deadlineDate');
    uploadedBy.value = taskUploadedBy; // Yeni eklenen satır
    var postDate = postedDateTimeStamp.toDate();
    postedDate.value = '${postDate.year}-${postDate.month}-${postDate.day}';

    var date = deadlineDateTimeStamp.toDate();
    isDeadlineAvailable.value = date.isAfter(DateTime.now());
  }

  Future<void> addComment(String taskID) async {
    if (commentController.text.length < 7) {
      Get.snackbar('Error', 'Comment can\'t be less than 7 characters');
      return;
    }

    try {
      final User? user = _auth.currentUser;
      final String uid = user!.uid;
      final String? name = user.displayName;
      final String? userImageUrl = user.photoURL;

      final generatedId = const Uuid().v4();
      await _firestore.collection('tasks').doc(taskID).update({
        'taskComments': FieldValue.arrayUnion([
          {
            'userId': uid,
            'commentId': generatedId,
            'name': name,
            'userImageUrl': userImageUrl,
            'commentBody': commentController.text,
            'time': Timestamp.now(),
          }
        ]),
      });

      await Fluttertoast.showToast(
        msg: "Your comment has been added",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.grey,
        fontSize: 18.0,
      );

      commentController.clear();
      isCommenting.value = false;
    } catch (error) {
      Get.snackbar('Error', 'Failed to add comment: $error');
    }
  }

  void toggleCommenting() {
    isCommenting.value = !isCommenting.value;
  }

  void updateTaskStatus(String taskId, bool newStatus) async {
    User? user = _auth.currentUser;
    final uid = user!.uid;
    if (uid == uploadedBy.value) {
      try {
        await _firestore
            .collection('tasks')
            .doc(taskId)
            .update({'isDone': newStatus});
        isDone.value = newStatus;
        Get.snackbar('Success', 'Task status updated');
      } catch (err) {
        Get.snackbar('Error', 'Action can\'t be performed');
      }
    } else {
      Get.snackbar('Error', 'You can\'t perform this action');
    }
  }

  // Upload Task methods
  void uploadTask() async {
    final taskID = const Uuid().v4();
    User? user = _auth.currentUser;
    final uid = user!.uid;
    final isValid = formKey.currentState!.validate();
    if (isValid) {
      if (deadlineDateController.text == 'Choose task Deadline date' ||
          taskCategoryController.text == 'Choose task category') {
        Get.snackbar('Error', 'Please pick everything');
        return;
      }
      isLoading.value = true;
      try {
        await _firestore.collection('tasks').doc(taskID).set({
          'taskId': taskID,
          'uploadedBy': uid,
          'taskTitle': taskTitleController.text,
          'taskDescription': taskDescriptionController.text,
          'deadlineDate': deadlineDateController.text,
          'deadlineDateTimeStamp': deadlineDateTimeStamp.value,
          'taskCategory': taskCategoryController.text,
          'taskComments': [],
          'isDone': false,
          'createdAt': Timestamp.now(),
        });
        await Fluttertoast.showToast(
            msg: "The task has been uploaded",
            toastLength: Toast.LENGTH_LONG,
            backgroundColor: Colors.grey,
            fontSize: 18.0);
        taskTitleController.clear();
        taskDescriptionController.clear();
        taskCategoryController.text = 'Choose task category';
        deadlineDateController.text = 'Choose task Deadline date';
      } finally {
        isLoading.value = false;
      }
    }
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
      deadlineDateTimeStamp.value = Timestamp.fromMicrosecondsSinceEpoch(
          picked.value!.microsecondsSinceEpoch);
    }
  }
}
