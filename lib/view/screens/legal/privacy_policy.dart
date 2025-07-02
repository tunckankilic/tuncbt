import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
              'Gizlilik Politikası',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Son güncelleme: ${DateTime.now().toString().split(' ')[0]}',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.lightTextColor,
              ),
            ),
            SizedBox(height: 24.h),
            _buildSection(
              'Veri Toplama ve Kullanım',
              'Uygulamamız, size daha iyi hizmet verebilmek için bazı kişisel verilerinizi toplar ve işler. Bu veriler şunları içerir:\n\n'
                  '• İsim ve e-posta adresi\n'
                  '• Profil fotoğrafı\n'
                  '• Telefon numarası\n'
                  '• Takım ve görev bilgileri\n'
                  '• Kullanım istatistikleri',
            ),
            _buildSection(
              'Veri Güvenliği',
              'Verileriniz Firebase altyapısı kullanılarak güvenli bir şekilde saklanır ve şifrelenir. Verilerinize sadece yetkili kişiler erişebilir.',
            ),
            _buildSection(
              'Veri Paylaşımı',
              'Verileriniz üçüncü taraflarla paylaşılmaz. Sadece takım üyeleri arasında gerekli bilgiler paylaşılır.',
            ),
            _buildSection(
              'Veri Silme',
              'Hesabınızı sildiğinizde, tüm kişisel verileriniz ve ilgili içerikler (mesajlar, yorumlar, görevler) kalıcı olarak silinir.',
            ),
            _buildSection(
              'Çerezler',
              'Uygulamamız, daha iyi bir kullanıcı deneyimi sağlamak için çerezler kullanabilir.',
            ),
            _buildSection(
              'İletişim',
              'Gizlilik politikamız hakkında sorularınız için support@tuncbt.com adresinden bize ulaşabilirsiniz.',
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
