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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeTablet = constraints.maxWidth >= 1200;
          final horizontalPadding =
              isLargeTablet ? constraints.maxWidth * 0.2 : 16.sp;

          return Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isLargeTablet ? 800.0 : double.infinity,
              ),
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: isLargeTablet ? 32.0 : 16.sp,
                ),
                children: [
                  _buildTeamInfoSection(context, team, l10n, isLargeTablet),
                  SizedBox(height: isLargeTablet ? 32.0 : 24.h),
                  if (teamController.isAdmin) ...[
                    _buildMemberManagementSection(
                        context, l10n, team, isLargeTablet),
                    SizedBox(height: isLargeTablet ? 32.0 : 24.h),
                  ],
                  _buildDangerZoneSection(
                      context, teamController, l10n, isLargeTablet),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTeamInfoSection(
      BuildContext context, team, l10n, bool isLargeTablet) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isLargeTablet ? 16.0 : 12.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(isLargeTablet ? 24.0 : 16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.teamInformation,
              style: TextStyle(
                fontSize: isLargeTablet ? 24.0 : 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isLargeTablet ? 24.0 : 16.h),
            ListTile(
              leading: Icon(
                Icons.group,
                size: isLargeTablet ? 32.0 : 24.0,
              ),
              title: Text(
                l10n.teamName,
                style: TextStyle(
                  fontSize: isLargeTablet ? 18.0 : 16.0,
                ),
              ),
              subtitle: Text(
                team.teamName,
                style: TextStyle(
                  fontSize: isLargeTablet ? 16.0 : 14.0,
                ),
              ),
            ),
            ListTile(
              leading: Icon(
                Icons.calendar_today,
                size: isLargeTablet ? 32.0 : 24.0,
              ),
              title: Text(
                l10n.teamCreationDate,
                style: TextStyle(
                  fontSize: isLargeTablet ? 18.0 : 16.0,
                ),
              ),
              subtitle: Text(
                l10n.lastUpdated(team.createdAt.toString()),
                style: TextStyle(
                  fontSize: isLargeTablet ? 16.0 : 14.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberManagementSection(
      BuildContext context, l10n, team, bool isLargeTablet) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isLargeTablet ? 16.0 : 12.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(isLargeTablet ? 24.0 : 16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.memberManagement,
              style: TextStyle(
                fontSize: isLargeTablet ? 24.0 : 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isLargeTablet ? 24.0 : 16.h),
            ListTile(
              leading: Icon(
                Icons.person_add,
                size: isLargeTablet ? 32.0 : 24.0,
              ),
              title: Text(
                l10n.inviteMembers,
                style: TextStyle(
                  fontSize: isLargeTablet ? 18.0 : 16.0,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isLargeTablet ? 24.0 : 16.0,
                vertical: isLargeTablet ? 12.0 : 8.0,
              ),
              onTap: () => Get.toNamed(InviteMembersScreen.routeName),
            ),
            ListTile(
              leading: Icon(
                Icons.share,
                size: isLargeTablet ? 32.0 : 24.0,
              ),
              title: Text(
                l10n.shareReferralCode,
                style: TextStyle(
                  fontSize: isLargeTablet ? 18.0 : 16.0,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isLargeTablet ? 24.0 : 16.0,
                vertical: isLargeTablet ? 12.0 : 8.0,
              ),
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

  Widget _buildDangerZoneSection(BuildContext context,
      TeamController teamController, l10n, bool isLargeTablet) {
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isLargeTablet ? 16.0 : 12.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(isLargeTablet ? 24.0 : 16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.dangerZone,
              style: TextStyle(
                fontSize: isLargeTablet ? 24.0 : 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: isLargeTablet ? 24.0 : 16.h),
            ListTile(
              leading: Icon(
                Icons.exit_to_app,
                color: Colors.red,
                size: isLargeTablet ? 32.0 : 24.0,
              ),
              title: Text(
                l10n.leaveTeam,
                style: TextStyle(
                  color: Colors.red,
                  fontSize: isLargeTablet ? 18.0 : 16.0,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isLargeTablet ? 24.0 : 16.0,
                vertical: isLargeTablet ? 12.0 : 8.0,
              ),
              onTap: () => _showLeaveTeamDialog(
                  context, teamController, l10n, isLargeTablet),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveTeamDialog(BuildContext context, TeamController teamController,
      l10n, bool isLargeTablet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          l10n.leaveTeam,
          style: TextStyle(
            fontSize: isLargeTablet ? 24.0 : 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Container(
          width: isLargeTablet ? 600.0 : null,
          child: Text(
            l10n.leaveTeamConfirm,
            style: TextStyle(
              fontSize: isLargeTablet ? 18.0 : 16.0,
            ),
          ),
        ),
        contentPadding: EdgeInsets.all(isLargeTablet ? 24.0 : 16.0),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: isLargeTablet ? 16.0 : 12.0,
                horizontal: isLargeTablet ? 24.0 : 16.0,
              ),
            ),
            child: Text(
              l10n.cancel,
              style: TextStyle(
                fontSize: isLargeTablet ? 18.0 : 16.0,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await teamController.leaveTeam();
              Get.offAllNamed('/auth');
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(
                vertical: isLargeTablet ? 16.0 : 12.0,
                horizontal: isLargeTablet ? 24.0 : 16.0,
              ),
            ),
            child: Text(
              l10n.leave,
              style: TextStyle(
                color: Colors.red,
                fontSize: isLargeTablet ? 18.0 : 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
