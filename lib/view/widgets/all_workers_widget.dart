import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:tuncbt/core/models/user_model.dart';
import 'package:tuncbt/view/screens/chat/chat_screen.dart';
import 'package:tuncbt/view/screens/inner_screens/inner_screen_controller.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/view/screens/inner_screens/screens/profile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuncbt/l10n/app_localizations.dart';

class AllWorkersWidget extends StatelessWidget {
  final String userID;
  final String userName;
  final String userEmail;
  final String positionInCompany;
  final String phoneNumber;
  final String userImageUrl;
  final String teamRole;

  const AllWorkersWidget({
    Key? key,
    required this.userID,
    required this.userName,
    required this.userEmail,
    required this.positionInCompany,
    required this.phoneNumber,
    required this.userImageUrl,
    required this.teamRole,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      child: OpenContainer(
        transitionDuration: Duration(milliseconds: 500),
        openBuilder: (context, _) {
          final controller = Get.put(InnerScreenController());
          controller.loadUserData(userID);

          return ProfileScreen(
            userId: userID,
            userType: UserType.worker,
          );
        },
        closedElevation: 5,
        closedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        closedColor: Theme.of(context).cardColor,
        closedBuilder: (context, openContainer) => InkWell(
          onTap: openContainer,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
            child: Row(
              children: [
                _buildLeadingAvatar(),
                SizedBox(width: 15.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitle(),
                      SizedBox(height: 5.h),
                      _buildSubtitle(),
                    ],
                  ),
                ),
                _buildTrailingButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingAvatar() {
    return Stack(
      children: [
        Hero(
          tag: 'avatar_$userID',
          child: Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _getRoleColor(),
                width: 2.w,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25.r),
              child: Image.network(
                userImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person,
                  size: 30.sp,
                  color: Theme.of(Get.context!).primaryColor,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: _getRoleColor(),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 1.5.w,
              ),
            ),
            child: Icon(
              _getRoleIcon(),
              size: 10.sp,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Color _getRoleColor() {
    switch (teamRole.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'manager':
        return Colors.orange;
      case 'member':
        return Colors.blue;
      default:
        return Theme.of(Get.context!).colorScheme.secondary;
    }
  }

  IconData _getRoleIcon() {
    switch (teamRole.toLowerCase()) {
      case 'admin':
        return Icons.admin_panel_settings;
      case 'manager':
        return Icons.manage_accounts;
      case 'member':
        return Icons.person;
      default:
        return Icons.person_outline;
    }
  }

  Widget _buildTitle() {
    return Row(
      children: [
        Expanded(
          child: Text(
            userName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: _getRoleColor().withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            teamRole.capitalize!,
            style: TextStyle(
              fontSize: 12.sp,
              color: _getRoleColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubtitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          positionInCompany,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppTheme.secondaryColor,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          phoneNumber,
          style: TextStyle(
            fontSize: 12.sp,
            color: AppTheme.lightTextColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailingButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            Icons.mail_outline,
            size: 24.sp,
            color: AppTheme.accentColor,
          ),
          onPressed: () => _mailTo(context),
          tooltip: l10n.sendEmail,
        ),
        IconButton(
          icon: Icon(
            FontAwesomeIcons.whatsapp,
            size: 24.sp,
            color: Colors.green,
          ),
          onPressed: () => _openWhatsApp(context),
          tooltip: l10n.sendWhatsApp,
        ),
        IconButton(
          icon: Icon(
            Icons.chat_bubble_outline,
            size: 24.sp,
            color: AppTheme.accentColor,
          ),
          onPressed: () => _openChat(context),
          tooltip: l10n.startChat,
        ),
      ],
    );
  }

  void _openChat(BuildContext context) {
    final user = UserModel(
        id: userID,
        name: userName,
        email: userEmail,
        imageUrl: userImageUrl,
        phoneNumber: phoneNumber,
        position: positionInCompany,
        createdAt: DateTime.now());

    Get.toNamed(
      ChatScreen.routeName,
      arguments: user,
    );
  }

  void _openWhatsApp(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    // Telefon numarasından tüm boşlukları ve özel karakterleri kaldır
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // Eğer numara + ile başlamıyorsa ve 0 ile başlıyorsa, 0'ı kaldır ve 90 ekle
    final formattedNumber = cleanNumber.startsWith('+')
        ? cleanNumber.substring(1)
        : cleanNumber.startsWith('0')
            ? '90${cleanNumber.substring(1)}'
            : '90$cleanNumber';

    final whatsappUrl = 'https://wa.me/$formattedNumber';

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl),
          mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.whatsAppError),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _mailTo(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final mailUrl = Uri(
      scheme: 'mailto',
      path: userEmail,
      queryParameters: {
        'subject': l10n.emailSubject,
        'body': l10n.emailBody(userName),
      },
    ).toString();

    if (await canLaunchUrl(Uri.parse(mailUrl))) {
      await launchUrl(Uri.parse(mailUrl), mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.emailError),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
