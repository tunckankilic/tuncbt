import 'dart:developer';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:tuncbt/core/models/team_member.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/providers/team_provider.dart';

class AllWorkersController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final workers = <UserModel>[].obs;
  final isLoading = true.obs;
  final memberCount = 0.obs;

  late final TeamProvider _teamProvider;

  AllWorkersController() {
    _teamProvider = Provider.of<TeamProvider>(Get.context!, listen: false);
  }

  @override
  void onInit() {
    super.onInit();
    fetchTeamMembers();
  }

  void fetchTeamMembers() {
    try {
      if (_teamProvider.teamId == null) {
        isLoading.value = false;
        return;
      }

      _firestore
          .collection('team_members')
          .where('teamId', isEqualTo: _teamProvider.teamId)
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
