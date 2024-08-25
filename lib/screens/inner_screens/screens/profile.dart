import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tuncbt/config/constants.dart';
import 'package:tuncbt/screens/inner_screens/inner_screen_controller.dart';
import 'package:tuncbt/user_state.dart';
import 'package:tuncbt/widgets/drawer_widget.dart';

class ProfileScreen extends GetView<InnerScreenController> {
  static const routeName = "/profile";

  ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      body: Obx(
        () => controller.isLoading.value
            ? Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  _buildSliverAppBar(context),
                  SliverToBoxAdapter(
                    child: _buildProfileContent(context),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.h,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          controller.currentUser.value.name,
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              controller.currentUser.value.userImage,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildJobInfo(),
          SizedBox(height: 20.h),
          _buildContactInfo(),
          SizedBox(height: 20.h),
          if (!controller.isSameUser.value) _buildContactButtons(),
          if (controller.isSameUser.value) _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildJobInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Job Information',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 10.h),
            _infoRow(
                Icons.work, controller.currentUser.value.positionInCompany),
            _infoRow(Icons.calendar_today,
                'Joined ${controller.currentUser.value.createdAt.toString().split(' ')[0]}'),
          ],
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            SizedBox(height: 10.h),
            _infoRow(Icons.email, controller.currentUser.value.email),
            _infoRow(Icons.phone, controller.currentUser.value.phoneNumber),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.secondaryColor, size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 16.sp, color: AppTheme.textColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _contactButton(
          color: Colors.green,
          icon: FontAwesomeIcons.whatsapp,
          onPressed: controller.openWhatsAppChat,
        ),
        _contactButton(
          color: Colors.red,
          icon: Icons.mail_outline,
          onPressed: controller.mailTo,
        ),
        _contactButton(
          color: Colors.purple,
          icon: Icons.call_outlined,
          onPressed: controller.callPhoneNumber,
        ),
      ],
    );
  }

  Widget _contactButton({
    required Color color,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: CircleBorder(),
        padding: EdgeInsets.all(16.w),
      ),
      child: Icon(icon, color: Colors.white, size: 24.sp),
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () {
          controller.signOut();
          Get.offAll(() => const UserState());
        },
        icon: Icon(Icons.logout, color: Colors.white),
        label: Text(
          'Logout',
          style: TextStyle(color: Colors.white, fontSize: 16.sp),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.pink.shade700,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
        ),
      ),
    );
  }
}
