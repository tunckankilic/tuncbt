import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/config/constants.dart';
import 'package:tuncbt/screens/all_workers/all_workers_controller.dart';
import 'package:tuncbt/widgets/all_workers_widget.dart';
import 'package:tuncbt/widgets/drawer_widget.dart';
import 'package:animations/animations.dart';

class AllWorkersScreen extends GetView<AllWorkersController> {
  static const routeName = "/all-workers";
  AllWorkersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerWidget(),
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          _buildWorkersList(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.h,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          'All Workers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
          ),
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
              Icons.group,
              size: 80.sp,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkersList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        );
      } else if (controller.workers.isEmpty) {
        return SliverFillRemaining(
          child: Center(
            child: Text(
              'There are no users',
              style: TextStyle(fontSize: 18.sp, color: AppTheme.textColor),
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
                      userID: worker['id'],
                      userName: worker['name'],
                      userEmail: worker['email'],
                      phoneNumber: worker['phoneNumber'],
                      positionInCompany: worker['positionInCompany'],
                      userImageUrl: worker['userImage'],
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

  Widget _buildFloatingActionButton() {
    return OpenContainer(
      transitionDuration: const Duration(milliseconds: 500),
      openBuilder: (context, _) => AddWorkerScreen(),
      closedElevation: 6.0,
      closedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(32),
      ),
      closedColor: AppTheme.accentColor,
      closedBuilder: (context, openContainer) => FloatingActionButton(
        onPressed: openContainer,
        backgroundColor: AppTheme.accentColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
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
