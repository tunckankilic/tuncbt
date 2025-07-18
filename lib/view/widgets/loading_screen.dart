import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/core/config/constants.dart';

class LoadingScreen extends StatelessWidget {
  final String? message;
  final bool isLargeTablet;

  const LoadingScreen({
    super.key,
    this.message,
    this.isLargeTablet = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: isLargeTablet ? 48.0 : 36.0,
              height: isLargeTablet ? 48.0 : 36.0,
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                strokeWidth: isLargeTablet ? 4.0 : 3.0,
              ),
            ),
            if (message != null) ...[
              SizedBox(height: isLargeTablet ? 24.0 : 16.h),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeTablet ? 32.0 : 24.w,
                ),
                child: Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isLargeTablet ? 20.0 : 16.sp,
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
