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
import 'package:tuncbt/view/widgets/loading_screen.dart';
import 'package:tuncbt/view/widgets/modern_card_widget.dart';
import 'package:tuncbt/view/widgets/glassmorphic_button.dart';

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
            await teamProvider.initializeTeamData();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, teamProvider),
              _buildStatsSection(context),
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
                        AppLocalizations.of(context)!.noTeamYet,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textColor,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        AppLocalizations.of(context)!.tasksRequireTeam,
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
      expandedHeight: 200.h,
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
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: const Offset(0, 2),
                blurRadius: 4,
                color: Colors.black.withOpacity(0.3),
              ),
            ],
          ),
        ),
        background: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: Constants.primaryGradient,
                ),
              ),
            ),
            // Glassmorphic overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            // Decorative circles
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
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
            ),
            // Content
            Positioned(
              bottom: 60.h,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.task_alt,
                      size: 32.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Takım Görevleri',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Obx(() {
          final totalTasks = controller.totalTasks;
          final completedTasks = controller.completedTasks;
          final pendingTasks = controller.pendingTasks;

          return Row(
            children: [
              Expanded(
                child: ModernStatsCard(
                  title: AppLocalizations.of(context)!.totalTasks,
                  value: totalTasks.toString(),
                  icon: Icons.task_alt,
                  color: AppTheme.primaryColor,
                  onTap: () {
                    // Filter all tasks
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ModernStatsCard(
                  title: AppLocalizations.of(context)!.completedTasks,
                  value: completedTasks.toString(),
                  icon: Icons.check_circle,
                  color: AppTheme.successColor,
                  onTap: () {
                    // Filter completed tasks
                  },
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ModernStatsCard(
                  title: AppLocalizations.of(context)!.pendingTasks,
                  value: pendingTasks.toString(),
                  icon: Icons.pending,
                  color: AppTheme.warningColor,
                  onTap: () {
                    // Filter pending tasks
                  },
                ),
              ),
            ],
          );
        }),
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
                  child: ModernTaskCard(
                    isCompleted: task['isDone'] ?? false,
                    accentColor: task['isDone'] == true
                        ? AppTheme.successColor
                        : AppTheme.primaryColor,
                    onTap: () {
                      // Navigate to task details
                      print('Task tapped: ${task['taskId']}');
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48.w,
                              height: 48.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: (task['isDone'] == true
                                        ? AppTheme.successColor
                                        : AppTheme.primaryColor)
                                    .withOpacity(0.1),
                              ),
                              child: Icon(
                                task['isDone'] == true
                                    ? Icons.check_circle
                                    : Icons.access_time,
                                color: task['isDone'] == true
                                    ? AppTheme.successColor
                                    : AppTheme.primaryColor,
                                size: 24.sp,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['taskTitle'] ??
                                        AppLocalizations.of(context)!.noTitle,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.onSurfaceColor,
                                      decoration: task['isDone'] == true
                                          ? TextDecoration.lineThrough
                                          : null,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    task['taskDescription'] ??
                                        AppLocalizations.of(context)!
                                            .noDescription,
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppTheme.onSurfaceVariantColor,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.keyboard_arrow_right,
                              color: AppTheme.onSurfaceVariantColor,
                              size: 24.sp,
                            ),
                          ],
                        ),
                      ],
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          onPressed: () => controller.addTestTask(),
          backgroundColor: AppTheme.secondaryColor,
          heroTag: 'test_task',
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: const Icon(
            Icons.bug_report,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16.h),
        ModernPrimaryButton(
          text: 'Yeni Görev',
          icon: const Icon(
            Icons.add,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Get.toNamed(
            UploadTask.routeName,
            arguments: {'teamId': teamProvider.teamId},
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
