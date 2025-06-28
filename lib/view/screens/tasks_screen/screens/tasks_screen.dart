import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/providers/team_provider.dart';
import 'package:tuncbt/view/screens/screens.dart';
import 'package:tuncbt/view/screens/tasks_screen/tasks_screen_controller.dart';
import 'package:tuncbt/view/widgets/drawer_widget.dart';
import 'package:tuncbt/view/widgets/task_widget.dart';

class TasksScreen extends StatefulWidget {
  static const routeName = "/tasks";

  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late final TasksScreenController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TasksScreenController());
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        print('TasksScreen: TeamProvider başlatılıyor...');
        final teamProvider = Provider.of<TeamProvider>(context, listen: false);
        if (!teamProvider.isInitialized) {
          await teamProvider.initializeTeamData();
        }
        print(
            'TasksScreen: TeamProvider başlatma durumu: ${teamProvider.isInitialized}');
      } catch (e) {
        print('TasksScreen Error: $e');
        print('Stack trace: ${StackTrace.current}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context);
    print(
        'TasksScreen build: TeamProvider durumu - initialized: ${teamProvider.isInitialized}, error: ${teamProvider.error}');

    if (teamProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (teamProvider.error != null) {
      print('TasksScreen: TeamProvider hatası: ${teamProvider.error}');
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.sp,
                color: Colors.red,
              ),
              SizedBox(height: 16.h),
              Text(
                teamProvider.error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  Get.offAllNamed('/auth');
                },
                child: Text(AppLocalizations.of(context)!.login),
              ),
            ],
          ),
        ),
      );
    }

    if (teamProvider.teamId == null) {
      print('TasksScreen: Takım ID\'si bulunamadı');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/auth');
        Get.snackbar(
          'Hata',
          'Takım bilgisi bulunamadı. Lütfen tekrar giriş yapın.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 5),
        );
      });
      return const SizedBox.shrink();
    }

    return Scaffold(
      drawer: DrawerWidget(),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, teamProvider),
          _buildTasksList(context),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(teamProvider),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, TeamProvider teamProvider) {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          teamProvider.currentTeam?.teamName ??
              AppLocalizations.of(context)!.teamTasks,
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

  Widget _buildTasksList(BuildContext context) {
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
                  AppLocalizations.of(context)!.noTasks,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: AppTheme.textColor,
                  ),
                ),
                Consumer<TeamProvider>(
                  builder: (context, teamProvider, child) {
                    if (teamProvider.isAdmin || teamProvider.isManager) {
                      return Padding(
                        padding: EdgeInsets.only(top: 8.h),
                        child: Text(
                          AppLocalizations.of(context)!.addTaskHint,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppTheme.textColor.withOpacity(0.7),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
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

  Widget _buildFloatingActionButton(TeamProvider teamProvider) {
    if (!teamProvider.isAdmin && !teamProvider.isManager) {
      return const SizedBox.shrink();
    }

    return FloatingActionButton(
      onPressed: () => Get.toNamed(
        UploadTask.routeName,
        arguments: {'teamId': teamProvider.teamId},
      ),
      backgroundColor: AppTheme.accentColor,
      child: const Icon(Icons.add),
    );
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
