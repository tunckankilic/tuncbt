import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncbt/screens/all_workers/all_workers_controller.dart';
import 'package:tuncbt/widgets/all_workers_widget.dart';
import 'package:tuncbt/widgets/drawer_widget.dart';

class AllWorkersScreen extends GetView<AllWorkersController> {
  static const routeName = "/all-workers";
  AllWorkersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          'All workers',
          style: TextStyle(color: Colors.pink),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.workers.isEmpty) {
          return const Center(child: Text('There are no users'));
        } else {
          return ListView.builder(
            itemCount: controller.workers.length,
            itemBuilder: (BuildContext context, int index) {
              final worker = controller.workers[index];
              return AllWorkersWidget(
                userID: worker['id'],
                userName: worker['name'],
                userEmail: worker['email'],
                phoneNumber: worker['phoneNumber'],
                positionInCompany: worker['positionInCompany'],
                userImageUrl: worker['userImage'],
              );
            },
          );
        }
      }),
    );
  }
}
