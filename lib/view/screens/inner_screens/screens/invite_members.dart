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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeTablet = constraints.maxWidth >= 1200;
          final horizontalPadding =
              isLargeTablet ? constraints.maxWidth * 0.2 : 16.w;

          return Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isLargeTablet ? 800.0 : double.infinity,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: isLargeTablet ? 32.0 : 16.w,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(isLargeTablet ? 16.0 : 12.0),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(isLargeTablet ? 32.0 : 16.w),
                      child: Column(
                        children: [
                          Text(
                            AppLocalizations.of(context)!.referralCode,
                            style: TextStyle(
                              fontSize: isLargeTablet ? 24.0 : 16.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: isLargeTablet ? 16.0 : 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                referralCode,
                                style: TextStyle(
                                  fontSize: isLargeTablet ? 36.0 : 24.sp,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.copy,
                                  size: isLargeTablet ? 32.0 : 24.0,
                                ),
                                padding:
                                    EdgeInsets.all(isLargeTablet ? 12.0 : 8.0),
                                onPressed: () {
                                  Clipboard.setData(
                                      ClipboardData(text: referralCode));
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        AppLocalizations.of(context)!
                                            .codeCopied,
                                        style: TextStyle(
                                          fontSize: isLargeTablet ? 16.0 : 14.0,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isLargeTablet ? 32.0 : 16.h),
                  ElevatedButton.icon(
                    onPressed: () {
                      Share.share(
                        AppLocalizations.of(context)!
                            .shareReferralCodeMessage(referralCode),
                        subject:
                            AppLocalizations.of(context)!.teamInviteSubject,
                      );
                    },
                    icon: Icon(
                      Icons.share,
                      size: isLargeTablet ? 28.0 : 24.0,
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isLargeTablet ? 20.0 : 16.0,
                        horizontal: isLargeTablet ? 32.0 : 24.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(isLargeTablet ? 16.0 : 12.0),
                      ),
                    ),
                    label: Text(
                      AppLocalizations.of(context)!.shareReferralCode,
                      style: TextStyle(
                        fontSize: isLargeTablet ? 20.0 : 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
