import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/providers/team_provider.dart';
import 'package:tuncbt/view/screens/all_workers/all_workers_controller.dart';
import 'package:tuncbt/view/widgets/all_workers_widget.dart';
import 'package:tuncbt/view/widgets/drawer_widget.dart';

class AllWorkersScreen extends GetView<AllWorkersController> {
  static const routeName = "/team-members";

  const AllWorkersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final teamProvider = Provider.of<TeamProvider>(context);
    if (!teamProvider.isInitialized) {
      teamProvider.initializeTeamData();
    }

    if (teamProvider.teamId == null) {
      Get.back();
      Get.snackbar(
        'Hata',
        'Takım bilgisi bulunamadı',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return const SizedBox.shrink();
    }

    Get.put(AllWorkersController());
    return Scaffold(
      drawer: DrawerWidget(),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context, teamProvider),
          _buildWorkersList(teamProvider),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, TeamProvider teamProvider) {
    return SliverAppBar(
      expandedHeight: 200.h,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              teamProvider.currentTeam?.teamName ?? 'Takım Üyeleri',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${teamProvider.teamMembers.length} Üye',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            ),
          ),
          child: Center(
            child: Icon(
              Icons.groups,
              size: 80.sp,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkersList(TeamProvider teamProvider) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        );
      } else if (controller.workers.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_off,
                  size: 64.sp,
                  color: AppTheme.lightTextColor,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Henüz takım üyesi bulunmuyor',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: AppTheme.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                if (teamProvider.isAdmin)
                  Text(
                    'Takımınıza yeni üyeler eklemek için\nreferans kodunuzu paylaşın',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.lightTextColor,
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
              final worker = controller.workers[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 375),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: AllWorkersWidget(
                      userID: worker.id,
                      userName: worker.name,
                      userEmail: worker.email,
                      phoneNumber: worker.phoneNumber,
                      positionInCompany: worker.position,
                      userImageUrl: worker.imageUrl,
                      teamRole: worker.teamRole?.name ?? 'Member',
                    ),
                  ),
                ),
              );
            },
            childCount: controller.workers.length,
          ),
        );
      }
    });
  }
}

class AddWorkerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Implement your AddWorkerScreen here
    return Scaffold(
      appBar: AppBar(title: const Text('Add Worker')),
      body: const Center(child: Text('Add Worker Form')),
    );
  }
}
