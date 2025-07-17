import 'dart:developer';

import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tuncbt/core/models/comment_model.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/core/models/task_model.dart';
import 'package:tuncbt/core/models/team.dart';
import 'package:tuncbt/core/models/team_member.dart';
import 'package:tuncbt/core/services/team_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:flutter/rendering.dart';

class InnerScreenController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late final TeamController _teamController;

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
  final TextEditingController commentController = TextEditingController();

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

  // Comment editing variables
  final TextEditingController editCommentController = TextEditingController();
  final RxBool isEditingComment = false.obs;
  final RxString editingCommentId = ''.obs;

  InnerScreenController() {
    _teamController = Get.find<TeamController>();
  }

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

      print(
          'InnerScreenController: Görev detayları yükleniyor - TaskID: $taskId');

      // Kullanıcı kontrolü
      final user = _auth.currentUser;
      if (user == null) {
        errorMessage.value = 'Oturum açmanız gerekiyor';
        return;
      }

      // Kullanıcı verilerini al
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        errorMessage.value = 'Kullanıcı bilgileri bulunamadı';
        return;
      }

      final userData = UserModel.fromFirestore(userDoc);
      if (userData.teamId == null || !userData.hasTeam) {
        errorMessage.value = 'Takım bilgisi bulunamadı';
        return;
      }

      print('InnerScreenController: Takım ID: ${userData.teamId}');

      // Görev verilerini al
      final taskDoc = await _firestore
          .collection('teams')
          .doc(userData.teamId)
          .collection('tasks')
          .doc(taskId)
          .get();

      if (!taskDoc.exists) {
        errorMessage.value = 'Görev bulunamadı';
        return;
      }

      final taskData = taskDoc.data()!;
      print('InnerScreenController: Görev verisi: $taskData');

      // Görevi oluşturan kullanıcının bilgilerini al
      final uploaderDoc = await _firestore
          .collection('users')
          .doc(taskData['uploadedBy'])
          .get();

      if (!uploaderDoc.exists) {
        errorMessage.value = 'Görev sahibi bilgileri bulunamadı';
        return;
      }

      final uploaderData = UserModel.fromFirestore(uploaderDoc);
      currentUser.value = uploaderData;

      // Görev modelini oluştur
      currentTask.value = TaskModel(
        id: taskId,
        title: taskData['taskTitle'] ?? '',
        description: taskData['taskDescription'] ?? '',
        isDone: taskData['isDone'] ?? false,
        uploadedBy: taskData['uploadedBy'] ?? '',
        createdAt: (taskData['createdAt'] as Timestamp).toDate(),
        deadline: (taskData['deadlineDate'] as Timestamp?)?.toDate() ??
            DateTime.now(),
        deadlineDate: (taskData['deadlineDate'] as Timestamp?)
                ?.toDate()
                .toString()
                .split(' ')[0] ??
            '',
        comments: await _loadComments(taskData),
        teamId: userData.teamId!,
        category: taskData['taskCategory'] ?? 'Genel',
      );

      // Yorum yapma ve durum güncelleme yetkilerini kontrol et
      canAddComment.value = true; // Tüm üyeler yorum yapabilir
      canUpdateTaskStatus.value = user.uid == taskData['uploadedBy'] ||
          userData.teamRole?.name == 'admin' ||
          userData.teamRole?.name == 'manager';

      print('InnerScreenController: Görev detayları yüklendi');
    } catch (e) {
      print('InnerScreenController Error: $e');
      errorMessage.value = 'Görev detayları yüklenirken hata oluştu: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<CommentModel>> _loadComments(
      Map<String, dynamic> taskData) async {
    try {
      print('_loadComments başlatılıyor...');
      print('Task Data: $taskData');

      final List<CommentModel> comments = [];
      final commentsList =
          List<Map<String, dynamic>>.from(taskData['taskComments'] ?? []);

      print('Yorumlar yükleniyor - Ham veri: $commentsList');
      print('Yorumlar yükleniyor - Toplam: ${commentsList.length}');

      for (var commentData in commentsList) {
        try {
          print('Yorum verisi işleniyor: $commentData');

          // Yorum verilerini kontrol et
          if (commentData == {}) {
            print('Yorum verisi null, atlıyorum');
            continue;
          }

          // ID kontrolü
          String commentId = commentData['id'] as String? ?? '';
          if (commentId.isEmpty) {
            print('Yorum ID boş, yeni ID oluşturuluyor');
            commentId = const Uuid().v4();
          }

          // UserID kontrolü
          final userId = commentData['userId'] as String?;
          if (userId == null || userId.isEmpty) {
            print('UserID boş, bu yorumu atlıyorum');
            continue;
          }

          // Body kontrolü
          String commentBody = commentData['body'] as String? ?? '';
          if (commentBody.isEmpty) {
            print('Yorum içeriği boş, bu yorumu atlıyorum');
            continue;
          }

          // Kullanıcı bilgilerini al
          final userDoc =
              await _firestore.collection('users').doc(userId).get();

          String userName = commentData['name'] as String? ?? '';
          String userImage = commentData['userImageUrl'] as String? ?? '';
          String teamRole = commentData['teamRole'] as String? ?? 'member';
          DateTime commentTime;

          if (commentData['time'] is Timestamp) {
            commentTime = (commentData['time'] as Timestamp).toDate();
          } else {
            commentTime = DateTime.now();
            print('Zaman damgası bulunamadı, şu anki zaman kullanılıyor');
          }

          if (userDoc.exists) {
            final userData = UserModel.fromFirestore(userDoc);
            userName = userData.name;
            userImage = userData.imageUrl;
            teamRole = userData.teamRole?.name ?? teamRole;
            print('Kullanıcı bilgileri Firestore\'dan alındı: $userName');
          } else {
            print('Kullanıcı dokümanı bulunamadı: $userId');
          }

          final comment = CommentModel(
            id: commentId,
            userId: userId,
            name: userName,
            userImageUrl: userImage,
            body: commentBody,
            time: commentTime,
            teamRole: teamRole,
          );

          comments.add(comment);
          print('Yorum başarıyla eklendi: ${comment.body}');
        } catch (e) {
          print('Yorum yükleme hatası: $e');
          continue;
        }
      }

      print('Yorumlar başarıyla yüklendi - Toplam: ${comments.length}');
      print('Yüklenen yorumlar: $comments');
      return comments;
    } catch (e) {
      print('Yorumları yükleme hatası: $e');
      return [];
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
    if (commentController.text.trim().isEmpty) {
      Get.snackbar('Hata', 'Yorum boş olamaz');
      return;
    }

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

      // Kullanıcı verilerini al
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        Get.snackbar('Hata', 'Kullanıcı bilgileri bulunamadı');
        return;
      }

      final userData = UserModel.fromFirestore(userDoc);
      if (userData.teamId == null) {
        Get.snackbar('Hata', 'Takım bilgisi bulunamadı');
        return;
      }

      print('Yorum ekleniyor - TaskID: $taskID, UserID: ${user.uid}');

      final commentId = const Uuid().v4();
      final now = DateTime.now();

      final comment = CommentModel(
        id: commentId,
        userId: user.uid,
        name: userData.name,
        userImageUrl: userData.imageUrl,
        body: commentController.text.trim(),
        time: now,
        teamRole: userData.teamRole?.name ?? 'member',
      );

      // Önce mevcut görevi al
      final taskDoc = await _firestore
          .collection('teams')
          .doc(userData.teamId)
          .collection('tasks')
          .doc(taskID)
          .get();

      if (!taskDoc.exists) {
        Get.snackbar('Hata', 'Görev bulunamadı');
        return;
      }

      // Yorumu tasks koleksiyonuna ekle
      await _firestore
          .collection('teams')
          .doc(userData.teamId)
          .collection('tasks')
          .doc(taskID)
          .update({
        'taskComments': FieldValue.arrayUnion([comment.toMap()]),
      });

      // Yerel listeyi güncelle
      currentTask.update((task) {
        if (task != null) {
          task.comments.add(comment);
        }
      });

      // Yorum kontrollerini sıfırla
      commentController.clear();
      isCommenting.value = false;

      print('Yorum başarıyla eklendi');
      Get.snackbar('Başarılı', 'Yorumunuz eklendi');

      // Yorum bildirimi oluştur
      await _createCommentNotification(taskID, commentId);
    } catch (e) {
      print('Yorum ekleme hatası: $e');
      Get.snackbar('Hata', 'Yorum eklenirken bir hata oluştu');
    }
  }

  Future<void> _createCommentNotification(
      String taskID, String commentId) async {
    try {
      await _firestore.collection('notifications').add({
        'message': 'Yeni yorum eklendi',
        'taskId': taskID,
        'commentId': commentId,
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
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Hata', 'Oturum açmanız gerekiyor');
        return;
      }

      // Kullanıcı verilerini al
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        Get.snackbar('Hata', 'Kullanıcı bilgileri bulunamadı');
        return;
      }

      final userData = UserModel.fromFirestore(userDoc);
      if (userData.teamId == null) {
        Get.snackbar('Hata', 'Takım bilgisi bulunamadı');
        return;
      }

      print(
          'Görev durumu güncelleniyor - TaskID: $taskId, NewStatus: $newStatus');

      // Görevi güncelle
      await _firestore
          .collection('teams')
          .doc(userData.teamId)
          .collection('tasks')
          .doc(taskId)
          .update({'isDone': newStatus});

      // Yerel state'i güncelle
      currentTask.update((task) {
        task!.isDone = newStatus;
      });

      // Bildirim oluştur
      await _createStatusUpdateNotification(taskId, newStatus);

      print('Görev durumu başarıyla güncellendi');
      Get.snackbar(
        'Başarılı',
        'Görev durumu güncellendi',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (err) {
      print('Görev durumu güncelleme hatası: $err');
      Get.snackbar(
        'Hata',
        'İşlem gerçekleştirilemedi: $err',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _createStatusUpdateNotification(
      String taskId, bool newStatus) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = UserModel.fromFirestore(userDoc);
      if (userData.teamId == null) return;

      print('Görev durumu bildirimi oluşturuluyor');

      await _firestore.collection('notifications').add({
        'taskId': taskId,
        'teamId': userData.teamId,
        'type': 'status_update',
        'message':
            'Görev durumu ${newStatus ? "tamamlandı" : "devam ediyor"} olarak güncellendi',
        'updatedBy': user.uid,
        'updaterName': userData.name,
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });

      print('Görev durumu bildirimi oluşturuldu');
    } catch (e) {
      print('Bildirim oluşturma hatası: $e');
    }
  }

  Future<String?> getLastUploadedTaskID() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) return null;

      final userData = UserModel.fromFirestore(userDoc);
      if (userData.teamId == null) return null;

      var querySnapshot = await _firestore
          .collection('teams')
          .doc(userData.teamId)
          .collection('tasks')
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.id;
      }
    } catch (e) {
      print('Son yüklenen görev ID\'si alınamadı: $e');
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

      print('Görev yükleme başladı - UserID: ${user.uid}');

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        Get.snackbar('Hata', 'Kullanıcı bilgileri bulunamadı');
        return;
      }

      final userData = UserModel.fromFirestore(userDoc);
      print('Kullanıcı verileri: ${userData.toFirestore()}');

      if (userData.teamId == null || userData.teamId!.isEmpty) {
        Get.snackbar(
            'Hata', 'Görev eklemek için bir takıma ait olmanız gerekiyor');
        return;
      }

      // Takım üyeliği kontrolü
      final memberDocId = '${userData.teamId}_${user.uid}';
      print('Takım üyeliği kontrolü - DocID: $memberDocId');

      final memberDoc =
          await _firestore.collection('team_members').doc(memberDocId).get();

      print('Takım üyeliği dokümanı: ${memberDoc.data()}');

      if (!memberDoc.exists || !(memberDoc.data()?['isActive'] ?? false)) {
        Get.snackbar('Hata', 'Takım üyeliğiniz aktif değil');
        return;
      }

      final memberRole = memberDoc.data()?['role'] as String? ?? '';
      print('Üye rolü: $memberRole');

      if (memberRole.toLowerCase() != 'admin' &&
          memberRole.toLowerCase() != 'manager') {
        Get.snackbar('Hata', 'Bu işlem için yetkiniz bulunmamaktadır');
        return;
      }

      final taskId = const Uuid().v4();
      final now = DateTime.now();

      print('Görev oluşturuluyor - TaskID: $taskId');

      final taskData = {
        'taskId': taskId,
        'taskTitle': taskTitleController.text,
        'taskDescription': taskDescriptionController.text,
        'taskCategory': taskCategoryController.text,
        'createdAt': Timestamp.fromDate(now),
        'deadlineDate': deadlineDateTimeStamp.value,
        'isDone': false,
        'teamId': userData.teamId,
        'uploadedBy': user.uid,
        'taskComments': [],
      };

      print('Görev verisi: $taskData');

      // Görevi ekle - teams koleksiyonunun altına
      await _firestore
          .collection('teams')
          .doc(userData.teamId)
          .collection('tasks')
          .doc(taskId)
          .set(taskData);

      print('Görev başarıyla eklendi');

      // Bildirim oluştur
      await _createTaskNotification(taskId, userData.teamId!);

      // Başarı mesajı
      Get.snackbar(
        'Başarılı',
        'Görev başarıyla eklendi',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Form alanlarını temizle
      _resetForm();

      // Önceki sayfaya dön
      Get.back();
    } catch (e, stackTrace) {
      print('Görev ekleme hatası: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Hata',
        'Görev eklenirken bir hata oluştu',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createTaskNotification(String taskId, String teamId) async {
    try {
      await _firestore.collection('notifications').add({
        'taskId': taskId,
        'teamId': teamId,
        'type': 'new_task',
        'message': 'Yeni görev eklendi: ${taskTitleController.text}',
        'createdAt': FieldValue.serverTimestamp(),
        'read': false,
      });
      print('Görev bildirimi oluşturuldu');
    } catch (e) {
      print('Bildirim oluşturma hatası: $e');
    }
  }

  bool _validateForm() {
    if (taskTitleController.text.trim().isEmpty) {
      Get.snackbar('Hata', 'Görev başlığı boş olamaz');
      return false;
    }

    if (taskDescriptionController.text.trim().isEmpty) {
      Get.snackbar('Hata', 'Görev açıklaması boş olamaz');
      return false;
    }

    if (taskCategoryController.text == 'Görev kategorisi seçin') {
      Get.snackbar('Hata', 'Lütfen bir kategori seçin');
      return false;
    }

    if (deadlineDateController.text == 'Görev son tarihini seçin') {
      Get.snackbar('Hata', 'Lütfen bir son tarih seçin');
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

  Future<void> deleteComment(String commentId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Hata', 'Oturum açmanız gerekiyor');
        return;
      }

      // Yorumu buluyor
      final comment = currentTask.value.comments.firstWhere(
        (c) => c.id == commentId,
        orElse: () => CommentModel.empty(),
      );

      if (comment.id.isEmpty) {
        Get.snackbar('Hata', 'Yorum bulunamadı');
        return;
      }

      // Yorum sahibi veya admin/manager kontrolü
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = UserModel.fromFirestore(userDoc);
      final isAdmin = userData.teamRole?.name.toLowerCase() == 'admin';
      final isManager = userData.teamRole?.name.toLowerCase() == 'manager';
      final isCommentOwner = comment.userId == user.uid;

      if (!isCommentOwner && !isAdmin && !isManager) {
        Get.snackbar('Hata', 'Bu yorumu silme yetkiniz yok');
        return;
      }

      print('Yorum siliniyor - CommentID: $commentId');

      // Yorumu tasks koleksiyonundan sil
      await _firestore
          .collection('teams')
          .doc(userData.teamId)
          .collection('tasks')
          .doc(currentTask.value.id)
          .update({
        'taskComments': FieldValue.arrayRemove([comment.toMap()]),
      });

      // Yerel listeden yorumu kaldır
      currentTask.update((task) {
        task!.comments.removeWhere((c) => c.id == commentId);
      });

      print('Yorum başarıyla silindi');
      Get.snackbar('Başarılı', 'Yorum silindi');
    } catch (e) {
      print('Yorum silme hatası: $e');
      Get.snackbar('Hata', 'Yorum silinirken hata oluştu');
    }
  }

  void startEditingComment(CommentModel comment) {
    editingCommentId.value = comment.id;
    editCommentController.text = comment.body;
    isEditingComment.value = true;
  }

  Future<void> updateComment(String commentId) async {
    if (editCommentController.text.length < 7) {
      Get.snackbar('Hata', 'Yorum en az 7 karakter olmalıdır');
      return;
    }

    try {
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar('Hata', 'Oturum açmanız gerekiyor');
        return;
      }

      // Yorumu buluyor
      final oldComment = currentTask.value.comments.firstWhere(
        (c) => c.id == commentId,
        orElse: () => CommentModel.empty(),
      );

      if (oldComment.id.isEmpty) {
        Get.snackbar('Hata', 'Yorum bulunamadı');
        return;
      }

      // Yorum sahibi kontrolü
      if (oldComment.userId != user.uid) {
        Get.snackbar('Hata', 'Sadece kendi yorumunuzu düzenleyebilirsiniz');
        return;
      }

      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = UserModel.fromFirestore(userDoc);

      print('Yorum düzenleniyor - CommentID: $commentId');

      // Yeni yorum objesi oluştur
      final updatedComment = CommentModel(
        id: oldComment.id,
        userId: oldComment.userId,
        name: oldComment.name,
        userImageUrl: oldComment.userImageUrl,
        body: editCommentController.text,
        time: DateTime.now(), // Düzenleme zamanını güncelle
        teamRole: oldComment.teamRole,
      );

      // Eski yorumu kaldır ve yenisini ekle
      await _firestore
          .collection('teams')
          .doc(userData.teamId)
          .collection('tasks')
          .doc(currentTask.value.id)
          .update({
        'taskComments': FieldValue.arrayRemove([oldComment.toMap()]),
      });

      await _firestore
          .collection('teams')
          .doc(userData.teamId)
          .collection('tasks')
          .doc(currentTask.value.id)
          .update({
        'taskComments': FieldValue.arrayUnion([updatedComment.toMap()]),
      });

      // Yerel listeyi güncelle
      currentTask.update((task) {
        final index = task!.comments.indexWhere((c) => c.id == commentId);
        if (index != -1) {
          task.comments[index] = updatedComment;
        }
      });

      print('Yorum başarıyla güncellendi');
      Get.snackbar('Başarılı', 'Yorum güncellendi');

      // Düzenleme modunu kapat
      isEditingComment.value = false;
      editingCommentId.value = '';
      editCommentController.clear();
    } catch (e) {
      print('Yorum güncelleme hatası: $e');
      Get.snackbar('Hata', 'Yorum güncellenirken hata oluştu');
    }
  }

  void cancelEditingComment() {
    isEditingComment.value = false;
    editingCommentId.value = '';
    editCommentController.clear();
  }
}
