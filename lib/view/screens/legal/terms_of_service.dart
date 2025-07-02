import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
              'Kullanım Şartları',
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
              'Yaş Sınırlaması',
              'Bu uygulamayı kullanmak için en az 13 yaşında olmanız gerekmektedir. 13 yaşından küçükseniz, ebeveyn veya yasal vasi gözetiminde kullanmanız gerekir.',
            ),
            _buildSection(
              'Hesap Güvenliği',
              'Hesap güvenliğinizden siz sorumlusunuz. Şifrenizi kimseyle paylaşmayın ve güvenli bir şekilde saklayın.',
            ),
            _buildSection(
              'Kabul Edilemez Davranışlar',
              '• Yasadışı içerik paylaşımı\n'
                  '• Spam veya istenmeyen içerik\n'
                  '• Taciz veya zorbalık\n'
                  '• Başkalarının kişisel verilerini izinsiz paylaşma\n'
                  '• Sistemin kötüye kullanımı',
            ),
            _buildSection(
              'İçerik Hakları',
              'Paylaştığınız içeriklerin haklarının size ait olduğunu veya paylaşma hakkına sahip olduğunuzu teyit etmelisiniz.',
            ),
            _buildSection(
              'Hizmet Değişiklikleri',
              'Hizmetlerimizi önceden haber vermeksizin değiştirme, askıya alma veya sonlandırma hakkını saklı tutarız.',
            ),
            _buildSection(
              'Sorumluluk Reddi',
              'Uygulama "olduğu gibi" sunulmaktadır. Kesintisiz veya hatasız çalışacağına dair garanti vermiyoruz.',
            ),
            _buildSection(
              'İletişim',
              'Kullanım şartları hakkında sorularınız için support@tuncbt.com adresinden bize ulaşabilirsiniz.',
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
