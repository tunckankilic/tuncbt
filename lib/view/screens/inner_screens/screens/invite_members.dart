import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/providers/team_provider.dart';
import 'package:share_plus/share_plus.dart';

class InviteMembersScreen extends StatelessWidget {
  static const routeName = '/invite-members';

  const InviteMembersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context);
    final referralCode = teamProvider.currentTeam?.referralCode ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Üye Davet Et')),
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
                      'Takım Davet Kodu',
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
                              const SnackBar(content: Text('Kod kopyalandı')),
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
                  'TuncBT takımıma katıl! Davet kodum: $referralCode',
                  subject: 'TuncBT Takım Daveti',
                );
              },
              icon: const Icon(Icons.share),
              label: const Text('Davet Kodunu Paylaş'),
            ),
          ],
        ),
      ),
    );
  }
}
