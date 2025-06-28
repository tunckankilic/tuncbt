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
import 'package:tuncbt/view/widgets/loading_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tuncbt/core/services/team_service.dart';

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
      _initializeTeamProvider();
    });
  }

  Future<void> _initializeTeamProvider() async {
    if (!mounted) return;

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
    final teamProvider = Provider.of<TeamProvider>(context);
    print(
        'TasksScreen build: TeamProvider durumu - initialized: ${teamProvider.isInitialized}, error: ${teamProvider.error}');

    if (_isInitializing || teamProvider.isLoading) {
      return const LoadingScreen(
        message: 'Takım bilgileri yükleniyor...',
      );
    }

    if (!teamProvider.isInitialized || teamProvider.teamId == null) {
      return _buildNoTeamScreen();
    }

    return Scaffold(
      drawer: DrawerWidget(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundColor.withOpacity(0.95),
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            await teamProvider.initializeTeamData();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, teamProvider),
              _buildTasksList(context),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(teamProvider),
    );
  }

  Widget _buildNoTeamScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.05),
              AppTheme.accentColor.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Card(
              margin: EdgeInsets.all(24.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
              elevation: 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.white.withOpacity(0.9),
                    ],
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.group_off_outlined,
                          size: 48.sp,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'Henüz bir takıma ait değilsiniz',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Görevleri görüntülemek için bir takıma katılmanız gerekiyor.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppTheme.lightTextColor,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 32.h),
                      ElevatedButton(
                        onPressed: () {
                          Get.offAllNamed('/auth');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 32.w, vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 2,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.login, size: 20.sp),
                            SizedBox(width: 8.w),
                            Text(
                              'Giriş Yap',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, TeamProvider teamProvider) {
    return SliverAppBar(
      expandedHeight: 180.h,
      floating: false,
      pinned: true,
      stretch: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          teamProvider.currentTeam?.teamName ??
              AppLocalizations.of(context)!.teamTasks,
          style: TextStyle(
            color: AppTheme.textColor,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryColor.withOpacity(0.9),
                AppTheme.accentColor.withOpacity(0.9),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -50.w,
                top: -50.h,
                child: Container(
                  width: 200.w,
                  height: 200.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                left: -30.w,
                bottom: -60.h,
                child: Container(
                  width: 150.w,
                  height: 150.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 40.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Görevler',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTasksList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return SliverFillRemaining(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
        );
      } else if (controller.errorMessage.value.isNotEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 48.sp,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 16.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Text(
                    controller.errorMessage.value,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppTheme.textColor,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
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
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.task_outlined,
                    size: 48.sp,
                    color: AppTheme.accentColor,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  AppLocalizations.of(context)!.noTasks,
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.w500,
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
                            height: 1.5,
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
        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                final task = controller.tasks[index];
                return AnimatedSlideTransition(
                  index: index,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    child: TaskWidget(
                      taskTitle: task['taskTitle'],
                      taskDescription: task['taskDescription'],
                      taskId: task['taskId'],
                      uploadedBy: task['uploadedBy'],
                      isDone: task['isDone'],
                      teamId: task['teamId'],
                    ),
                  ),
                );
              },
              childCount: controller.tasks.length,
            ),
          ),
        );
      }
    });
  }

  Widget _buildFloatingActionButton(TeamProvider teamProvider) {
    if (!teamProvider.isAdmin && !teamProvider.isManager) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: () => controller.addTestTask(),
          backgroundColor: AppTheme.primaryColor,
          heroTag: 'test_task',
          child: const Icon(Icons.bug_report),
        ),
        SizedBox(width: 16.w),
        FloatingActionButton.extended(
          onPressed: () => Get.toNamed(
            UploadTask.routeName,
            arguments: {'teamId': teamProvider.teamId},
          ),
          backgroundColor: AppTheme.accentColor,
          elevation: 4,
          heroTag: 'new_task',
          icon: const Icon(Icons.add),
          label: Text(
            'Yeni Görev',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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
