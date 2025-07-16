import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/l10n/app_localizations.dart';

class TermsOfServiceScreen extends StatelessWidget {
  static const routeName = '/terms-of-service';

  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.termsOfService),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.termsOfService,
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
              AppLocalizations.of(context)!.termsAgeRestriction,
              AppLocalizations.of(context)!.termsAgeRestrictionDesc,
            ),
            _buildSection(
              AppLocalizations.of(context)!.accountSecurity,
              AppLocalizations.of(context)!.accountSecurityDesc,
            ),
            _buildSection(
              AppLocalizations.of(context)!.unacceptableBehavior,
              AppLocalizations.of(context)!.unacceptableBehaviorDesc,
            ),
            _buildSection(
              AppLocalizations.of(context)!.contentRights,
              AppLocalizations.of(context)!.contentRightsDesc,
            ),
            _buildSection(
              AppLocalizations.of(context)!.serviceChanges,
              AppLocalizations.of(context)!.serviceChangesDesc,
            ),
            _buildSection(
              AppLocalizations.of(context)!.disclaimer,
              AppLocalizations.of(context)!.disclaimerDesc,
            ),
            _buildSection(
              AppLocalizations.of(context)!.termsContact,
              AppLocalizations.of(context)!.termsContactDesc,
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
