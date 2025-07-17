import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/core/services/team_controller.dart';
import 'package:tuncbt/view/screens/screens.dart';
import 'package:tuncbt/view/screens/tasks_screen/tasks_screen_controller.dart';
import 'package:tuncbt/view/widgets/drawer_widget.dart';
import 'package:tuncbt/view/widgets/loading_screen.dart';
import 'package:tuncbt/view/widgets/modern_card_widget.dart';
import 'package:tuncbt/view/widgets/glassmorphic_button.dart';
import 'package:tuncbt/view/widgets/task_widget.dart';
import 'package:tuncbt/view/screens/inner_screens/screens/upload_task.dart';

class TasksScreen extends StatefulWidget {
  static const routeName = "/tasks";

  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late final TasksScreenController controller;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TasksScreenController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTeamController();
    });
  }

  Future<void> _initializeTeamController() async {
    if (!mounted) return;

    try {
      print('TasksScreen: TeamController başlatılıyor...');
      final teamController = Get.find<TeamController>();
      if (!teamController.isInitialized) {
        await teamController.initializeTeamData();
      }
      print(
          'TasksScreen: TeamController başlatma durumu: ${teamController.isInitialized}');
    } catch (e) {
      print('TasksScreen Error: $e');
      print('Stack trace: ${StackTrace.current}');
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamController = Get.find<TeamController>();
    print(
        'TasksScreen build: TeamController durumu - initialized: ${teamController.isInitialized}, error: ${teamController.error}');

    if (_isInitializing || teamController.isLoading) {
      return LoadingScreen(
        message: AppLocalizations.of(context)!.loadingTeamData,
      );
    }

    if (!teamController.isInitialized || teamController.teamId == null) {
      return _buildNoTeamScreen();
    }

    return Scaffold(
      drawer: DrawerWidget(),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: Constants.backgroundGradient,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            await teamController.initializeTeamData();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, teamController),
              _buildStatsSection(context),
              _buildTasksList(context),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(teamController),
    );
  }

  Widget _buildNoTeamScreen() {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_off,
              size: 64.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              AppLocalizations.of(context)!.noTeamYet,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppLocalizations.of(context)!.tasksRequireTeam,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(
      BuildContext context, TeamController teamController) {
    return SliverAppBar(
      expandedHeight: 200.h,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => Text(
                  teamController.currentTeam?.teamName ??
                      AppLocalizations.of(context)!.teamTasks,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                )),
            Obx(() => Text(
                  AppLocalizations.of(context)!
                      .teamMemberCount(teamController.teamMembers.length),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.sp,
                  ),
                )),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.task_alt,
              size: 80.sp,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.quickActions,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: ModernStatsCard(
                    title: AppLocalizations.of(context)!.totalTasks,
                    value: controller.tasks.length.toString(),
                    icon: Icons.assignment,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ModernStatsCard(
                    title: AppLocalizations.of(context)!.completedTasks,
                    value: controller.tasks
                        .where((task) => task['isCompleted'] ?? false)
                        .length
                        .toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: ModernStatsCard(
                    title: AppLocalizations.of(context)!.pendingTasks,
                    value: controller.tasks
                        .where((task) => !(task['isCompleted'] ?? false))
                        .length
                        .toString(),
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                ),
                SizedBox(width: 16.w),
                const Expanded(child: SizedBox()),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksList(BuildContext context) {
    final teamController = Get.find<TeamController>();
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.tasks.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context)!.noTasks,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  AppLocalizations.of(context)!.addTaskHint,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final task = controller.tasks[index];
            return TaskWidget(
              taskTitle: task['title'] ?? AppLocalizations.of(context)!.noTitle,
              taskDescription: task['description'] ??
                  AppLocalizations.of(context)!.noDescription,
              taskId: task['id'],
              uploadedBy: task['createdBy'] ?? '',
              isDone: task['isCompleted'] ?? false,
              teamId: teamController.teamId ?? '',
            );
          },
          childCount: controller.tasks.length,
        ),
      );
    });
  }

  Widget _buildFloatingActionButton(TeamController teamController) {
    return Obx(() {
      if (!teamController.isAdmin && !teamController.isManager) {
        return const SizedBox.shrink();
      }

      return ModernGlassButton(
        text: '',
        onPressed: () {
          Get.toNamed(UploadTaskScreen.routeName);
        },
        icon: Icon(
          Icons.add,
          color: Colors.white,
          size: 24.sp,
        ),
      );
    });
  }
}
