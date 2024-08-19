import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_icon_class/font_awesome_icon_class.dart';
import 'package:tuncbt/constants/constants.dart';
import 'package:tuncbt/screens/inner_screens/inner_screen_controller.dart';
import 'package:tuncbt/user_state.dart';
import 'package:tuncbt/widgets/drawer_widget.dart';

class ProfileScreen extends GetView<InnerScreenController> {
  static const routeName = "/profile";

  final String userID;

  ProfileScreen({Key? key, required this.userID}) : super(key: key) {
    controller.getUserData(userID);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 0),
                  child: Stack(
                    children: [
                      _buildProfileCard(context),
                      _buildProfileImage(size, context),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(30),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            Align(
              alignment: Alignment.center,
              child: Text(
                controller.name.value,
                style: const TextStyle(
                    fontSize: 22,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.center,
              child: Text(
                '${controller.job.value} Since joined ${controller.joinedAt.value}',
                style: TextStyle(
                  color: Constants.darkBlue,
                  fontSize: 18,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Divider(thickness: 1),
            const SizedBox(height: 20),
            Text(
              'Contact Info',
              style: _titleTextStyle,
            ),
            const SizedBox(height: 15),
            _userInfo(title: 'Email:', content: controller.email.value),
            _userInfo(
                title: 'Phone number:', content: controller.phoneNumber.value),
            const SizedBox(height: 15),
            if (!controller.isSameUser.value) ...[
              const Divider(thickness: 1),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _contactBy(
                    color: Colors.green,
                    fct: controller.openWhatsAppChat,
                    icon: FontAwesomeIcons.whatsapp,
                  ),
                  _contactBy(
                    color: Colors.red,
                    fct: controller.mailTo,
                    icon: Icons.mail_outline,
                  ),
                  _contactBy(
                    color: Colors.purple,
                    fct: controller.callPhoneNumber,
                    icon: Icons.call_outlined,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 25),
            const Divider(thickness: 1),
            const SizedBox(height: 25),
            if (controller.isSameUser.value)
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: MaterialButton(
                    onPressed: () {
                      controller.signOut();
                      Get.offAll(() => const UserState());
                    },
                    color: Colors.pink.shade700,
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.logout, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Logout',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(Size size, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: size.width * 0.26,
          height: size.width * 0.26,
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
            border: Border.all(
              width: 8,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            image: DecorationImage(
              image: NetworkImage(controller.imageUrl.value),
              fit: BoxFit.fill,
            ),
          ),
        ),
      ],
    );
  }

  Widget _contactBy(
      {required Color color, required Function fct, required IconData icon}) {
    return CircleAvatar(
      backgroundColor: color,
      radius: 25,
      child: CircleAvatar(
        radius: 23,
        backgroundColor: Colors.white,
        child: IconButton(
          icon: Icon(icon, color: color),
          onPressed: () => fct(),
        ),
      ),
    );
  }

  Widget _userInfo({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        children: [
          Text(title, style: _titleTextStyle),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              content,
              style: TextStyle(
                color: Constants.darkBlue,
                fontSize: 18,
                fontStyle: FontStyle.normal,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextStyle get _titleTextStyle => const TextStyle(
        fontSize: 22,
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.bold,
      );
}
