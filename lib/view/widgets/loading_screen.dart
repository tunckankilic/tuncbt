import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/core/config/constants.dart';

class LoadingScreen extends StatelessWidget {
  final String? message;

  const LoadingScreen({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
            if (message != null) ...[
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppTheme.textColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
