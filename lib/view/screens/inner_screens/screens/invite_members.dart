import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/core/services/team_controller.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tuncbt/l10n/app_localizations.dart';

class InviteMembersScreen extends StatelessWidget {
  static const routeName = '/invite-members';

  const InviteMembersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final teamController = Get.find<TeamController>();
    final referralCode = teamController.currentTeam?.referralCode ?? '';

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.inviteMembers)),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.referralCode,
                      style: TextStyle(fontSize: 16.sp),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          referralCode,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: referralCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(AppLocalizations.of(context)!
                                      .codeCopied)),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: () {
                Share.share(
                  AppLocalizations.of(context)!
                      .shareReferralCodeMessage(referralCode),
                  subject: AppLocalizations.of(context)!.teamInviteSubject,
                );
              },
              icon: const Icon(Icons.share),
              label: Text(AppLocalizations.of(context)!.shareReferralCode),
            ),
          ],
        ),
      ),
    );
  }
}
