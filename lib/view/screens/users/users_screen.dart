import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:tuncbt/view/screens/screens.dart';
import 'package:tuncbt/view/screens/users/users_controller.dart';
import 'package:tuncbt/view/screens/users/users_repository.dart';

class UsersListView extends GetView<UserController> {
  const UsersListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kullanıcılar'),
      ),
      body: Obx(
        () => ListView.builder(
          itemCount: controller.users.length,
          itemBuilder: (context, index) {
            final user = controller.users[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.imageUrl),
                  radius: 25,
                ),
                title: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.position),
                    Text(
                      'Katılma: ${Jiffy.parse(user.createdAt.toString()).fromNow()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.message),
                  onPressed: () {
                    // Sohbet ekranına yönlendirme
                    Get.toNamed('/chat', arguments: user);
                  },
                ),
                onTap: () {
                  // Kullanıcı profili veya detay sayfasına yönlendirme
                  Get.toNamed(ProfileScreen.routeName, arguments: user);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
