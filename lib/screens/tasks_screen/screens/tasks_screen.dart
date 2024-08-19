import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tuncbt/constants/constants.dart';
import 'package:tuncbt/screens/tasks_screen/tasks_screen_controller.dart';
import 'package:tuncbt/widgets/drawer_widget.dart';
import 'package:tuncbt/widgets/task_widget.dart';

class TasksScreen extends GetView<TasksScreenController> {
  static const routeName = "/tasks";

  TasksScreen({Key? key}) : super(key: key);

  final TasksScreenController controller = Get.put(TasksScreenController());

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      drawer: DrawerWidget(),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text('Tasks', style: TextStyle(color: Colors.pink)),
        actions: [
          IconButton(
            onPressed: () => controller.showTaskCategoriesDialog(context),
            icon: const Icon(Icons.filter_list_outlined, color: Colors.black),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.tasks.isEmpty) {
          return const Center(child: Text('There are no tasks'));
        } else {
          return ListView.builder(
            itemCount: controller.tasks.length,
            itemBuilder: (BuildContext context, int index) {
              final task = controller.tasks[index];
              return TaskWidget(
                taskTitle: task['taskTitle'],
                taskDescription: task['taskDescription'],
                taskId: task['taskId'],
                uploadedBy: task['uploadedBy'],
                isDone: task['isDone'],
              );
            },
          );
        }
      }),
    );
  }
}
