import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:tuncbt/view/screens/screens.dart';
import 'package:tuncbt/view/screens/users/users_controller.dart';

class UsersListView extends GetView<UserController> {
  const UsersListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcılar'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeTablet = constraints.maxWidth >= 1200;
          final horizontalPadding =
              isLargeTablet ? constraints.maxWidth * 0.2 : 16.0;

          return Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isLargeTablet ? 800.0 : double.infinity,
              ),
              child: Obx(
                () => ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isLargeTablet ? 24.0 : 16.0,
                  ),
                  itemCount: controller.users.length,
                  itemBuilder: (context, index) {
                    final user = controller.users[index];
                    return Card(
                      elevation: 2,
                      margin: EdgeInsets.symmetric(
                        horizontal: isLargeTablet ? 16.0 : 8.0,
                        vertical: isLargeTablet ? 8.0 : 4.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(isLargeTablet ? 16.0 : 12.0),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: isLargeTablet ? 24.0 : 16.0,
                          vertical: isLargeTablet ? 16.0 : 8.0,
                        ),
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(user.imageUrl),
                          radius: isLargeTablet ? 35.0 : 25.0,
                        ),
                        title: Text(
                          user.name,
                          style: TextStyle(
                            fontSize: isLargeTablet ? 20.0 : 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.position,
                              style: TextStyle(
                                fontSize: isLargeTablet ? 16.0 : 14.0,
                              ),
                            ),
                            Text(
                              'Katılma: ${Jiffy.parse(user.createdAt.toString()).fromNow()}',
                              style: TextStyle(
                                fontSize: isLargeTablet ? 14.0 : 12.0,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(
                            Icons.message,
                            size: isLargeTablet ? 32.0 : 24.0,
                          ),
                          onPressed: () {
                            Get.toNamed('/chat', arguments: user);
                          },
                          padding: EdgeInsets.all(isLargeTablet ? 12.0 : 8.0),
                        ),
                        onTap: () {
                          Get.toNamed(ProfileScreen.routeName, arguments: user);
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
