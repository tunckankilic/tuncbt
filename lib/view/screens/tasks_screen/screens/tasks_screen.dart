import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/view/screens/screens.dart';
import 'package:tuncbt/view/screens/tasks_screen/tasks_screen_controller.dart';
import 'package:tuncbt/view/widgets/drawer_widget.dart';
import 'package:tuncbt/view/widgets/task_widget.dart';

class TasksScreen extends GetView<TasksScreenController> {
  static const routeName = "/tasks";

  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(TasksScreenController());
    return Scaffold(
      drawer: DrawerWidget(),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          _buildTasksList(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'Takım Görevleri',
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryColor, AppTheme.accentColor],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTasksList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        );
      } else if (controller.errorMessage.value.isNotEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48.sp,
                  color: Colors.red,
                ),
                SizedBox(height: 16.h),
                Text(
                  controller.errorMessage.value,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: AppTheme.textColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      } else if (controller.tasks.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.task_outlined,
                  size: 48.sp,
                  color: AppTheme.accentColor,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Henüz takım görevi bulunmuyor',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: AppTheme.textColor,
                  ),
                ),
                if (controller.currentUser.value?.teamRole?.name == 'admin' ||
                    controller.currentUser.value?.teamRole?.name == 'manager')
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Text(
                      'Yeni görev eklemek için + butonuna tıklayın',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppTheme.textColor.withOpacity(0.7),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      } else {
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              final task = controller.tasks[index];
              return AnimatedSlideTransition(
                index: index,
                child: TaskWidget(
                  taskTitle: task['taskTitle'],
                  taskDescription: task['taskDescription'],
                  taskId: task['taskId'],
                  uploadedBy: task['uploadedBy'],
                  isDone: task['isDone'],
                  teamId: task['teamId'],
                ),
              );
            },
            childCount: controller.tasks.length,
          ),
        );
      }
    });
  }

  Widget _buildFloatingActionButton() {
    return Obx(() {
      final userRole = controller.currentUser.value?.teamRole?.name;
      final bool canAddTask = userRole == 'admin' || userRole == 'manager';

      if (!canAddTask || controller.currentUser.value?.teamId == null) {
        return const SizedBox.shrink();
      }

      return FloatingActionButton(
        onPressed: () => Get.toNamed(UploadTask.routeName),
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.add),
      );
    });
  }
}

class AnimatedSlideTransition extends StatelessWidget {
  final int index;
  final Widget child;

  const AnimatedSlideTransition(
      {super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutQuad,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 50 * value),
          child: Opacity(
            opacity: 1 - value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
