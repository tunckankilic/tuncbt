import 'dart:developer';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncbt/core/models/team_member.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/core/services/team_service_controller.dart';

class AllWorkersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final workers = <UserModel>[].obs;
  final isLoading = true.obs;
  final memberCount = 0.obs;

  late final TeamServiceController _teamController;

  AllWorkersController() {
    _teamController = Get.find<TeamServiceController>();
  }

  @override
  void onInit() {
    super.onInit();
    fetchTeamMembers();
  }

  void fetchTeamMembers() {
    try {
      if (_teamController.teamId == null) {
        isLoading.value = false;
        return;
      }

      _firestore
          .collection('team_members')
          .where('teamId', isEqualTo: _teamController.teamId)
          .where('isActive', isEqualTo: true)
          .snapshots()
          .listen((snapshot) async {
        try {
          final List<UserModel> teamMembers = [];
          for (var doc in snapshot.docs) {
            final teamMember = TeamMember.fromJson(doc.data());
            final userDoc = await _firestore
                .collection('users')
                .doc(teamMember.userId)
                .get();
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
    } catch (e) {
      log("Error in fetchTeamMembers: $e");
      isLoading.value = false;
    }
  }
}
