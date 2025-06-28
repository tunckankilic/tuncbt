import 'dart:developer';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tuncbt/core/models/comment_model.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/core/models/task_model.dart';
import 'package:tuncbt/core/models/team.dart';
import 'package:tuncbt/core/models/team_member.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:tuncbt/providers/team_provider.dart';

class InnerScreenController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final TeamProvider _teamProvider;

  InnerScreenController() {
    _teamProvider = Provider.of<TeamProvider>(Get.context!, listen: false);
  }

  // Common variables
  final RxBool isLoading = false.obs;
  final RxString currentUserId = ''.obs;
  final RxString errorMessage = ''.obs;

  // User related variables
  final Rx<UserModel> currentUser = UserModel.empty().obs;
  final RxBool isSameUser = false.obs;

  // Team related variables
  final Rx<Team?> currentTeam = Rx<Team?>(null);
  final Rx<TeamMember?> currentTeamMember = Rx<TeamMember?>(null);
  final RxInt teamMemberCount = 0.obs;
  final RxBool isTeamAdmin = false.obs;

  // Task related variables
  final Rx<TaskModel> currentTask = TaskModel.empty().obs;
  final RxBool isCommenting = false.obs;
  final RxBool canUpdateTaskStatus = false.obs;
  final RxBool canAddComment = false.obs;
  final commentController = TextEditingController();

  // Upload Task variables
  final TextEditingController taskCategoryController =
      TextEditingController(text: 'Görev kategorisi seçin');
  final TextEditingController taskTitleController = TextEditingController();
  final TextEditingController taskDescriptionController =
      TextEditingController();
  final TextEditingController deadlineDateController =
      TextEditingController(text: 'Görev son tarihini seçin');
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

  String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
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

        // Fetch team data
        await _fetchTeamData(userId);
      } else {
        log('User document does not exist for userId: $userId');
        currentUser.value = UserModel.empty();
      }
    } catch (e) {
      log('Error retrieving user data: $e');
      Get.snackbar('Hata', 'Kullanıcı bilgileri alınamadı');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchTeamData(String teamId) async {
    try {
      // Fetch team data
      final teamDoc = await _firestore.collection('teams').doc(teamId).get();
      if (teamDoc.exists) {
        currentTeam.value = Team.fromJson(teamDoc.data()!);
        teamMemberCount.value = currentTeam.value!.memberCount;
      }

      // Fetch team member data
      final teamMemberDoc = await _firestore
          .collection('team_members')
          .where('teamId', isEqualTo: teamId)
          .where('userId', isEqualTo: currentUserId.value)
          .get();

      if (teamMemberDoc.docs.isNotEmpty) {
        currentTeamMember.value =
            TeamMember.fromJson(teamMemberDoc.docs.first.data());
        isTeamAdmin.value =
            currentTeamMember.value!.role.name.toLowerCase() == 'admin';
      }
    } catch (e) {
      log('Error fetching team data: $e');
    }
  }

  Future<void> leaveTeam() async {
    try {
      if (currentUser.value.teamId == null || currentTeamMember.value == null) {
        throw Exception('Takım bilgisi bulunamadı');
      }

      isLoading.value = true;

      // Update team member status
      await _firestore
          .collection('team_members')
          .doc('${currentUser.value.teamId}_${currentUserId.value}')
          .update({'isActive': false});

      // Update user's team ID
      await _firestore
          .collection('users')
          .doc(currentUserId.value)
          .update({'teamId': null, 'teamRole': null});

      // Update team member count
      await _firestore
          .collection('teams')
          .doc(currentUser.value.teamId)
          .update({
        'memberCount': FieldValue.increment(-1),
      });

      // Clear local team data
      currentTeam.value = null;
      currentTeamMember.value = null;
      teamMemberCount.value = 0;
      isTeamAdmin.value = false;

      Get.snackbar(
        'Başarılı',
        'Takımdan ayrıldınız',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      log('Error leaving team: $e');
      Get.snackbar(
        'Hata',
        'Takımdan ayrılırken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void copyReferralCode() {
    if (currentTeam.value != null) {
      Clipboard.setData(
          ClipboardData(text: currentTeam.value!.referralCode ?? ''));
      Get.snackbar(
        'Başarılı',
        'Referans kodu kopyalandı',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    }
  }

  Future<void> launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Get.snackbar('Hata', '$url açılamadı');
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
      errorMessage.value = '';

      // Önce kullanıcının takım üyeliğini kontrol et
      final User? user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Oturum açmanız gerekiyor';
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        errorMessage.value = 'Kullanıcı bilgileri bulunamadı';
        return;
      }

      final userData = UserModel.fromFirestore(userDoc);
      if (userData.teamId != _teamProvider.teamId) {
        errorMessage.value = 'Bu görevi görüntüleme yetkiniz yok';
        return;
      }

      final DocumentSnapshot taskDoc =
          await _firestore.collection('tasks').doc(taskId).get();

      if (taskDoc.exists) {
        currentTask.value = TaskModel.fromFirestore(taskDoc);
        await getUserData(currentTask.value.uploadedBy);

        // Yetkilendirmeleri ayarla
        final bool isAdmin = userData.teamRole?.name == 'admin';
        final bool isManager = userData.teamRole?.name == 'manager';
        final bool isTaskCreator = currentTask.value.uploadedBy == user.uid;

        canUpdateTaskStatus.value = isTaskCreator || isAdmin || isManager;
        canAddComment.value = true; // Tüm takım üyeleri yorum yapabilir
      } else {
        log('Task document does not exist for ID: $taskId');
        errorMessage.value = 'Görev bulunamadı';
      }
    } catch (e) {
      log('Error fetching task data: $e');
      errorMessage.value = 'Görev bilgileri alınırken hata oluştu';
    } finally {
      isLoading.value = false;
    }
  }

  Future<UserModel> getUserById(String userId) async {
    try {
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        log('User document does not exist for userId: $userId');
        return UserModel.empty();
      }
    } catch (e) {
      log('Error retrieving user data: $e');
      throw Exception('Kullanıcı bilgileri alınamadı');
    }
  }

  Future<void> loadUserData(String userId) async {
    try {
      isLoading.value = true;
      final userData = await getUserById(userId);
      currentUser.value = userData;

      final User? user = _auth.currentUser;
      isSameUser.value = user?.uid == userId;
    } catch (e) {
      log('Error loading user data: $e');
      Get.snackbar('Hata', 'Kullanıcı bilgileri yüklenemedi');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addComment(String taskID) async {
    if (commentController.text.length < 7) {
      Get.snackbar('Hata', 'Yorum en az 7 karakter olmalıdır');
      return;
    }

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Hata', 'Oturum açmanız gerekiyor');
        return;
      }

      // Kullanıcının takım rolünü al
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        Get.snackbar('Hata', 'Kullanıcı bilgileri bulunamadı');
        return;
      }

      final userData = UserModel.fromFirestore(userDoc);
      if (userData.teamId != currentTask.value.teamId) {
        Get.snackbar('Hata', 'Bu göreve yorum yapma yetkiniz yok');
        return;
      }

      final teamRole = userData.teamRole?.name ?? 'member';

      CommentModel newComment = CommentModel(
        id: const Uuid().v4(),
        userId: user.uid,
        name: currentUser.value.name,
        userImageUrl: currentUser.value.imageUrl,
        body: commentController.text,
        time: DateTime.now(),
        teamRole: teamRole,
      );

      await _firestore.collection('tasks').doc(taskID).update({
        'taskComments': FieldValue.arrayUnion([newComment.toMap()]),
      });

      currentTask.update((task) {
        task!.comments.add(newComment);
      });

      // Yorum bildirimi oluştur
      await _createCommentNotification(taskID, newComment);

      log("Comment successfully added to Firestore");

      await Fluttertoast.showToast(
        msg: "Yorumunuz eklendi",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.grey,
        fontSize: 18.0,
      );

      commentController.clear();
      isCommenting.value = false;

      log("Comment process completed successfully");
    } catch (error) {
      log("Error adding comment: $error");
      Get.snackbar('Hata', 'Yorum eklenirken hata oluştu: $error');
    }
  }

  Future<void> _createCommentNotification(
      String taskID, CommentModel comment) async {
    try {
      await _firestore.collection('notifications').add({
        'message': '${comment.name} bir göreve yorum yaptı',
        'taskId': taskID,
        'commentId': comment.id,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'type': 'new_comment',
      });
      log("Comment notification created successfully");
    } catch (e) {
      log('Error creating comment notification: $e');
    }
  }

  Future<void> updateUserName(String newName) async {
    try {
      final User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'name': newName,
        });
        currentUser.update((val) {
          val!.name = newName;
        });
        Get.snackbar('Başarılı', 'İsim güncellendi');
      } else {
        Get.snackbar('Hata', 'Kullanıcı bulunamadı');
      }
    } catch (e) {
      log('Error updating user name: $e');
      Get.snackbar('Hata', 'İsim güncellenirken hata oluştu');
    }
  }

  void toggleCommenting() {
    isCommenting.value = !isCommenting.value;
  }

  Future<void> updateTaskStatus(String taskId, bool newStatus) async {
    if (!canUpdateTaskStatus.value) {
      Get.snackbar('Hata', 'Bu işlemi gerçekleştirme yetkiniz yok');
      return;
    }

    try {
      await _firestore
          .collection('tasks')
          .doc(taskId)
          .update({'isDone': newStatus});

      currentTask.update((task) {
        task!.isDone = newStatus;
      });

      // Create Notification
      await _createStatusUpdateNotification(taskId, newStatus);

      Get.snackbar('Başarılı', 'Görev durumu güncellendi');
    } catch (err) {
      log('Error updating task status: $err');
      Get.snackbar('Hata', 'İşlem gerçekleştirilemedi');
    }
  }

  Future<void> _createStatusUpdateNotification(
      String taskId, bool newStatus) async {
    try {
      await _firestore.collection('notifications').add({
        'message':
            'Görev durumu ${newStatus ? "tamamlandı" : "devam ediyor"} olarak güncellendi',
        'taskId': taskId,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
        'type': 'status_update',
      });
    } catch (e) {
      log('Error creating status update notification: $e');
    }
  }

  Future<String?> getLastUploadedTaskID() async {
    try {
      var querySnapshot = await _firestore
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
    } catch (e) {
      log('Error getting last uploaded task ID: $e');
    }
    return null;
  }

  Future<void> uploadTask() async {
    if (!_validateForm()) return;

    try {
      isLoading.value = true;

      // Kullanıcı ve takım kontrolü
      final User? user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Hata', 'Oturum açmanız gerekiyor');
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        Get.snackbar('Hata', 'Kullanıcı bilgileri bulunamadı');
        return;
      }

      final userData = UserModel.fromFirestore(userDoc);
      if (userData.teamId == null) {
        Get.snackbar(
            'Hata', 'Görev eklemek için bir takıma ait olmanız gerekiyor');
        return;
      }

      if (userData.teamRole?.name != 'admin' &&
          userData.teamRole?.name != 'manager') {
        Get.snackbar('Hata', 'Görev ekleme yetkiniz yok');
        return;
      }

      // Save To Firestore
      String taskID = await _saveTaskToFirestore(userData.teamId!);

      // Create Notification
      await _createNotification(taskID);

      _resetForm();
      Fluttertoast.showToast(
          msg: "Görev başarıyla eklendi",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.grey,
          fontSize: 18.0);

      Get.back(); // Görev listesi ekranına dön
    } catch (e) {
      log('Error uploading task: $e');
      Get.snackbar('Hata', 'Görev eklenirken hata oluştu');
    } finally {
      isLoading.value = false;
    }
  }

  Future<String> _saveTaskToFirestore(String teamId) async {
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
      teamId: teamId,
    );
    await _firestore.collection('tasks').doc(taskID).set(newTask.toFirestore());
    return taskID;
  }

  Future<void> _createNotification(String taskId) async {
    await _firestore.collection('notifications').add({
      'message': 'Yeni görev eklendi',
      'taskId': taskId,
      'createdAt': FieldValue.serverTimestamp(),
      'read': false,
    });
  }

  bool _validateForm() {
    final isValid = formKey.currentState!.validate();
    if (!isValid) return false;
    if (deadlineDateController.text == 'Görev son tarihini seçin' ||
        taskCategoryController.text == 'Görev kategorisi seçin') {
      Get.snackbar('Hata', 'Lütfen tüm alanları doldurun');
      return false;
    }
    return true;
  }

  void _resetForm() {
    taskTitleController.clear();
    taskDescriptionController.clear();
    taskCategoryController.text = 'Görev kategorisi seçin';
    deadlineDateController.text = 'Görev son tarihini seçin';
  }

  void showTaskCategoriesDialog(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
            child: const Text('İptal'),
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
