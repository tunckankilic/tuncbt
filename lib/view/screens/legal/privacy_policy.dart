import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  static const routeName = '/privacy-policy';

  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.privacyPolicy),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.privacyPolicy,
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context)!
                  .lastUpdated(DateTime.now().toString().split(' ')[0]),
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.lightTextColor,
              ),
            ),
            SizedBox(height: 24.h),
            _buildSection(
              AppLocalizations.of(context)!.dataCollection,
              AppLocalizations.of(context)!.dataCollectionDesc,
            ),
            _buildSection(
              AppLocalizations.of(context)!.dataSecurity,
              AppLocalizations.of(context)!.dataSecurityDesc,
            ),
            _buildSection(
              AppLocalizations.of(context)!.dataSharing,
              AppLocalizations.of(context)!.dataSharingDesc,
            ),
            _buildSection(
              AppLocalizations.of(context)!.dataDeletion,
              AppLocalizations.of(context)!.dataDeletionDesc,
            ),
            _buildSection(
              AppLocalizations.of(context)!.cookies,
              AppLocalizations.of(context)!.cookiesDesc,
            ),
            _buildSection(
              AppLocalizations.of(context)!.contactInfo,
              AppLocalizations.of(context)!.contactInfoDesc,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppTheme.textColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            content,
            style: TextStyle(
              fontSize: 16.sp,
              color: AppTheme.textColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
