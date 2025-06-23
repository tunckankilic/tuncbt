import 'dart:developer';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuncbt/core/models/team_member.dart';
import 'package:tuncbt/core/models/user_model.dart';

class AllWorkersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final workers = <UserModel>[].obs;
  final isLoading = true.obs;
  final memberCount = 0.obs;
  final currentTeamId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeTeamData();
  }

  Future<void> _initializeTeamData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;

      // Get current user's team ID
      final userDoc =
          await _firestore.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) return;

      final userData = UserModel.fromFirestore(userDoc);
      if (userData.teamId == null) return;

      currentTeamId.value = userData.teamId!;
      fetchTeamMembers();
    } catch (e) {
      log("Error initializing team data: $e");
      isLoading.value = false;
    }
  }

  void fetchTeamMembers() {
    if (currentTeamId.isEmpty) {
      isLoading.value = false;
      return;
    }

    _firestore
        .collection('team_members')
        .where('teamId', isEqualTo: currentTeamId.value)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snapshot) async {
      try {
        final List<UserModel> teamMembers = [];
        for (var doc in snapshot.docs) {
          final teamMember = TeamMember.fromJson(doc.data());
          final userDoc =
              await _firestore.collection('users').doc(teamMember.userId).get();
          if (userDoc.exists) {
            final userData = UserModel.fromFirestore(userDoc);
            teamMembers.add(userData);
          }
        }
        workers.value = teamMembers;
        memberCount.value = teamMembers.length;
        isLoading.value = false;
      } catch (e) {
        log("Error fetching team members: $e");
        isLoading.value = false;
      }
    }, onError: (error) {
      log("Error in team members stream: $error");
      isLoading.value = false;
    });
  }
}
