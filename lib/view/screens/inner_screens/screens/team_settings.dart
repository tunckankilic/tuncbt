import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/core/services/team_controller.dart';
import 'package:tuncbt/view/screens/inner_screens/screens/invite_members.dart';

class TeamSettingsScreen extends StatelessWidget {
  static const routeName = "/team-settings";

  const TeamSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final teamController = Get.find<TeamController>();
    final team = teamController.currentTeam;
    final l10n = AppLocalizations.of(context)!;

    if (team == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.teamSettings),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.sp),
        children: [
          _buildTeamInfoSection(context, team, l10n),
          SizedBox(height: 24.h),
          if (teamController.isAdmin) ...[
            _buildMemberManagementSection(context, l10n, team),
            SizedBox(height: 24.h),
          ],
          _buildDangerZoneSection(context, teamController, l10n),
        ],
      ),
    );
  }

  Widget _buildTeamInfoSection(BuildContext context, team, l10n) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.teamInformation,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: const Icon(Icons.group),
              title: Text(l10n.teamName),
              subtitle: Text(team.teamName),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(l10n.teamCreationDate),
              subtitle: Text(
                l10n.lastUpdated(team.createdAt.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberManagementSection(BuildContext context, l10n, team) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.memberManagement,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: Text(l10n.inviteMembers),
              onTap: () => Get.toNamed(InviteMembersScreen.routeName),
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(l10n.shareReferralCode),
              onTap: () => Share.share(
                l10n.shareReferralCodeMessage(team.referralCode),
                subject: l10n.shareReferralCode,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZoneSection(
      BuildContext context, TeamController teamController, l10n) {
    return Card(
      color: Colors.red.shade50,
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dangerZone,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 16.h),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: Text(
                l10n.leaveTeam,
                style: const TextStyle(color: Colors.red),
              ),
              onTap: () => _showLeaveTeamDialog(context, teamController, l10n),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveTeamDialog(
      BuildContext context, TeamController teamController, l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.leaveTeam),
        content: Text(l10n.leaveTeamConfirm),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await teamController.leaveTeam();
              Get.offAllNamed('/auth');
            },
            child: Text(
              l10n.leave,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
