import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/view/screens/inner_screens/inner_screen_controller.dart';
import 'package:tuncbt/view/widgets/comments_widget.dart';

class TaskDetailsScreen extends GetView<InnerScreenController> {
  static const routeName = "/task-details";

  final String uploadedBy;
  final String taskID;
  final String teamId;

  TaskDetailsScreen({
    Key? key,
    required this.uploadedBy,
    required this.taskID,
    required this.teamId,
  }) : super(key: key) {
    Get.put(InnerScreenController());
    controller.getTaskData(taskID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeTablet = constraints.maxWidth >= 1200;
          final horizontalPadding =
              isLargeTablet ? constraints.maxWidth * 0.2 : 16.w;

          return Obx(
            () => controller.isLoading.value
                ? const Center(child: CircularProgressIndicator())
                : controller.errorMessage.value.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: isLargeTablet ? 64.0 : 48.sp,
                              color: Colors.red,
                            ),
                            SizedBox(height: isLargeTablet ? 24.0 : 16.h),
                            Text(
                              controller.errorMessage.value,
                              style: TextStyle(
                                fontSize: isLargeTablet ? 24.0 : 18.sp,
                                color: AppTheme.textColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : CustomScrollView(
                        slivers: [
                          _buildSliverAppBar(isLargeTablet),
                          SliverToBoxAdapter(
                            child: Center(
                              child: Container(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      isLargeTablet ? 800.0 : double.infinity,
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: isLargeTablet ? 32.0 : 16.w,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _buildTaskInfo(context, isLargeTablet),
                                    SizedBox(
                                        height: isLargeTablet ? 32.0 : 20.h),
                                    _buildDescriptionSection(
                                        context, isLargeTablet),
                                    SizedBox(
                                        height: isLargeTablet ? 32.0 : 20.h),
                                    _buildCommentSection(
                                        context, isLargeTablet),
                                    SizedBox(
                                        height: isLargeTablet ? 32.0 : 20.h),
                                    _buildCommentsList(isLargeTablet),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(bool isLargeTablet) {
    return SliverAppBar(
      expandedHeight: isLargeTablet ? 300.0 : 200.h,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          controller.currentTask.value.title,
          style: TextStyle(
            color: Colors.white,
            fontSize: isLargeTablet ? 28.0 : 20.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInfo(BuildContext context, bool isLargeTablet) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isLargeTablet ? 16.0 : 10.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(isLargeTablet ? 24.0 : 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUploadedBySection(context, isLargeTablet),
            _dividerWidget(isLargeTablet),
            _buildDateSection(context, isLargeTablet),
            _dividerWidget(isLargeTablet),
            _buildDoneStateSection(context, isLargeTablet),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedBySection(BuildContext context, bool isLargeTablet) {
    return Row(
      children: [
        Text(AppLocalizations.of(context)!.uploadedBy,
            style: _titleStyle(isLargeTablet)),
        const Spacer(),
        CircleAvatar(
          radius: isLargeTablet ? 24.0 : 18.r,
          backgroundImage: NetworkImage(controller
                  .currentUser.value.imageUrl.isEmpty
              ? 'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png'
              : controller.currentUser.value.imageUrl),
        ),
        SizedBox(width: isLargeTablet ? 8.0 : 5.r),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.currentUser.value.name,
              style: _textStyle(isLargeTablet),
            ),
            Text(
              controller.currentUser.value.position,
              style: _textStyle(isLargeTablet),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSection(BuildContext context, bool isLargeTablet) {
    return Column(
      children: [
        _buildInfoRow(
          AppLocalizations.of(context)!.uploadedOn,
          controller.currentTask.value.createdAt.toString().split(' ')[0],
          isLargeTablet: isLargeTablet,
        ),
        SizedBox(height: isLargeTablet ? 12.0 : 8.h),
        _buildInfoRow(
          AppLocalizations.of(context)!.deadlineDate,
          controller.currentTask.value.deadlineDate,
          valueColor: Colors.red,
          isLargeTablet: isLargeTablet,
        ),
        SizedBox(height: isLargeTablet ? 16.0 : 10.h),
        Text(
          controller.currentTask.value.deadline.isAfter(DateTime.now())
              ? AppLocalizations.of(context)!.deadlineNotFinished
              : AppLocalizations.of(context)!.deadlinePassed,
          style: TextStyle(
            color: controller.currentTask.value.deadline.isAfter(DateTime.now())
                ? Colors.green
                : Colors.red,
            fontSize: isLargeTablet ? 18.0 : 14.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value,
      {Color? valueColor, required bool isLargeTablet}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: _titleStyle(isLargeTablet)),
        Text(value,
            style: _textStyle(isLargeTablet).copyWith(color: valueColor)),
      ],
    );
  }

  Widget _buildDoneStateSection(BuildContext context, bool isLargeTablet) {
    return Obx(() {
      final canUpdateStatus = controller.canUpdateTaskStatus.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(AppLocalizations.of(context)!.status,
              style: _titleStyle(isLargeTablet)),
          SizedBox(height: isLargeTablet ? 16.0 : 10.h),
          if (canUpdateStatus)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusButton(AppLocalizations.of(context)!.taskCompleted,
                    true, isLargeTablet),
                _buildStatusButton(AppLocalizations.of(context)!.taskInProgress,
                    false, isLargeTablet),
              ],
            )
          else
            Container(
              padding: EdgeInsets.all(isLargeTablet ? 16.0 : 8.r),
              decoration: BoxDecoration(
                color: controller.currentTask.value.isDone
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius:
                    BorderRadius.circular(isLargeTablet ? 16.0 : 10.r),
              ),
              child: Text(
                controller.currentTask.value.isDone
                    ? AppLocalizations.of(context)!.taskCompleted
                    : AppLocalizations.of(context)!.taskInProgress,
                style: TextStyle(
                  color: controller.currentTask.value.isDone
                      ? Colors.green
                      : Colors.red,
                  fontSize: isLargeTablet ? 20.0 : 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      );
    });
  }

  Widget _buildStatusButton(
      String label, bool isDoneStatus, bool isLargeTablet) {
    return ElevatedButton.icon(
      onPressed: () => controller.updateTaskStatus(taskID, isDoneStatus),
      icon: Icon(
        controller.currentTask.value.isDone == isDoneStatus
            ? Icons.check_circle
            : Icons.circle_outlined,
        color: Colors.white,
        size: isLargeTablet ? 28.0 : 24.0,
      ),
      label: Text(
        label,
        style: TextStyle(
          fontSize: isLargeTablet ? 16.0 : 14.0,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDoneStatus ? Colors.green : Colors.red,
        padding: EdgeInsets.symmetric(
          horizontal: isLargeTablet ? 24.0 : 16.0,
          vertical: isLargeTablet ? 16.0 : 12.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isLargeTablet ? 24.0 : 20.r),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context, bool isLargeTablet) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isLargeTablet ? 16.0 : 10.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(isLargeTablet ? 24.0 : 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.taskDescription,
              style: _titleStyle(isLargeTablet),
            ),
            SizedBox(height: isLargeTablet ? 16.0 : 10.h),
            Text(
              controller.currentTask.value.description,
              style: _textStyle(isLargeTablet),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection(BuildContext context, bool isLargeTablet) {
    return Obx(() {
      if (!controller.canAddComment.value) {
        return const SizedBox.shrink();
      }

      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: controller.isCommenting.value
            ? _buildCommentInput(context, isLargeTablet)
            : Center(
                child: ElevatedButton.icon(
                  onPressed: () => controller.isCommenting.value = true,
                  icon: Icon(
                    Icons.add_comment,
                    size: isLargeTablet ? 28.0 : 24.0,
                  ),
                  label: Text(
                    AppLocalizations.of(context)!.addComment,
                    style: TextStyle(
                      fontSize: isLargeTablet ? 16.0 : 14.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accentColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: isLargeTablet ? 24.0 : 16.0,
                      vertical: isLargeTablet ? 16.0 : 12.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(isLargeTablet ? 24.0 : 20.r),
                    ),
                  ),
                ),
              ),
      );
    });
  }

  Widget _buildCommentInput(BuildContext context, bool isLargeTablet) {
    return Column(
      children: [
        TextField(
          controller: controller.commentController,
          style: TextStyle(
            color: AppTheme.textColor,
            fontSize: isLargeTablet ? 16.0 : 14.0,
          ),
          maxLength: 200,
          maxLines: 3,
          decoration: InputDecoration(
            fillColor: Colors.grey[200],
            filled: true,
            hintText: AppLocalizations.of(context)!.writeYourComment,
            hintStyle: TextStyle(
              fontSize: isLargeTablet ? 16.0 : 14.0,
            ),
            contentPadding: EdgeInsets.all(isLargeTablet ? 16.0 : 12.0),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(isLargeTablet ? 16.0 : 10.r),
            ),
          ),
        ),
        SizedBox(height: isLargeTablet ? 16.0 : 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => controller.isCommenting.value = false,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeTablet ? 20.0 : 16.0,
                  vertical: isLargeTablet ? 12.0 : 8.0,
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(
                  fontSize: isLargeTablet ? 16.0 : 14.0,
                ),
              ),
            ),
            SizedBox(width: isLargeTablet ? 16.0 : 10.w),
            ElevatedButton(
              onPressed: () => controller.addComment(taskID),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentColor,
                padding: EdgeInsets.symmetric(
                  horizontal: isLargeTablet ? 24.0 : 16.0,
                  vertical: isLargeTablet ? 16.0 : 12.0,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(isLargeTablet ? 16.0 : 10.r),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.send,
                style: TextStyle(
                  fontSize: isLargeTablet ? 16.0 : 14.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentsList(bool isLargeTablet) {
    return Obx(() {
      print('Yorumlar listesi yeniden oluşturuluyor');
      print('Mevcut yorumlar: ${controller.currentTask.value.comments}');
      print('Yorum sayısı: ${controller.currentTask.value.comments.length}');

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          vertical: isLargeTablet ? 16.0 : 8.0,
        ),
        itemCount: controller.currentTask.value.comments.length,
        itemBuilder: (context, index) {
          final comment = controller.currentTask.value.comments[index];
          print('Yorum oluşturuluyor - Index: $index, Body: ${comment.body}');

          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: isLargeTablet ? 8.0 : 4.0,
            ),
            child: CommentWidget(
              commentId: comment.id,
              commenterId: comment.userId,
              commentBody: comment.body,
              commenterImageUrl: comment.userImageUrl,
              commenterName: comment.name,
              commenterTeamRole: comment.teamRole,
              commentTime: comment.time,
              isLargeTablet: isLargeTablet,
            ),
          );
        },
        separatorBuilder: (context, index) => Divider(
          height: isLargeTablet ? 32.0 : 24.0,
          thickness: isLargeTablet ? 2.0 : 1.0,
        ),
      );
    });
  }

  Widget _dividerWidget(bool isLargeTablet) {
    return Divider(
      height: isLargeTablet ? 32.0 : 20.h,
      thickness: isLargeTablet ? 2.0 : 1.0,
    );
  }

  TextStyle _textStyle(bool isLargeTablet) => TextStyle(
        color: AppTheme.textColor,
        fontSize: isLargeTablet ? 16.0 : 12.sp,
      );

  TextStyle _titleStyle(bool isLargeTablet) => TextStyle(
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: isLargeTablet ? 18.0 : 14.sp,
      );
}
