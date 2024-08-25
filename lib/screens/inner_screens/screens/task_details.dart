import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/config/constants.dart';
import 'package:tuncbt/screens/inner_screens/inner_screen_controller.dart';
import 'package:tuncbt/widgets/comments_widget.dart';
import 'package:tuncbt/models/task_model.dart';
import 'package:tuncbt/models/comment_model.dart';

class TaskDetailsScreen extends GetView<InnerScreenController> {
  static const routeName = "/task-details";

  final String uploadedBy;
  final String taskID;

  TaskDetailsScreen({Key? key, required this.uploadedBy, required this.taskID})
      : super(key: key) {
    Get.put(InnerScreenController());
    controller.getTaskData(taskID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  _buildSliverAppBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTaskInfo(),
                          SizedBox(height: 20.h),
                          _buildDescriptionSection(),
                          SizedBox(height: 20.h),
                          _buildCommentSection(),
                          SizedBox(height: 20.h),
                          _buildCommentsList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200.h,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          controller.currentTask.value.title,
          style: TextStyle(color: Colors.white, fontSize: 20.sp),
        ),
        background: Container(
          decoration: const BoxDecoration(
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

  Widget _buildTaskInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUploadedBySection(),
            _dividerWidget(),
            _buildDateSection(),
            _dividerWidget(),
            _buildDoneStateSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadedBySection() {
    return Row(
      children: [
        Text('Uploaded by', style: _titleStyle()),
        const Spacer(),
        CircleAvatar(
          radius: 18.r,
          backgroundImage: NetworkImage(controller
                  .currentUser.value.userImage.isEmpty
              ? 'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png'
              : controller.currentUser.value.userImage),
        ),
        SizedBox(width: 5.r),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(controller.currentUser.value.name, style: _textStyle()),
            Text(controller.currentUser.value.positionInCompany,
                style: _textStyle()),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      children: [
        _buildInfoRow('Uploaded on:',
            controller.currentTask.value.createdAt.toString().split(' ')[0]),
        SizedBox(height: 8.h),
        _buildInfoRow(
            'Deadline date:', controller.currentTask.value.deadlineDate,
            valueColor: Colors.red),
        SizedBox(height: 10.h),
        Text(
          controller.currentTask.value.deadline.isAfter(DateTime.now())
              ? 'Deadline is not finished yet'
              : 'Deadline passed',
          style: TextStyle(
            color: controller.currentTask.value.deadline.isAfter(DateTime.now())
                ? Colors.green
                : Colors.red,
            fontSize: 14.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: _titleStyle()),
        Text(value, style: _textStyle().copyWith(color: valueColor)),
      ],
    );
  }

  Widget _buildDoneStateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Done state:', style: _titleStyle()),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatusButton('Done', true),
            _buildStatusButton('Not Done', false),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusButton(String label, bool isDoneStatus) {
    return ElevatedButton.icon(
      onPressed: () => controller.updateTaskStatus(taskID, isDoneStatus),
      icon: Icon(
        controller.currentTask.value.isDone == isDoneStatus
            ? Icons.check_circle
            : Icons.circle_outlined,
        color: Colors.white,
      ),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: isDoneStatus ? Colors.green : Colors.red,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Task Description', style: _titleStyle()),
            SizedBox(height: 10.h),
            Text(controller.currentTask.value.description, style: _textStyle()),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentSection() {
    return Obx(() => AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: controller.isCommenting.value
              ? _buildCommentInput()
              : Center(
                  child: ElevatedButton.icon(
                    onPressed: () => controller.isCommenting.value = true,
                    icon: const Icon(Icons.add_comment),
                    label: const Text('Add a Comment'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r)),
                    ),
                  ),
                ),
        ));
  }

  Widget _buildCommentInput() {
    return Column(
      children: [
        TextField(
          controller: controller.commentController,
          style: const TextStyle(color: AppTheme.textColor),
          maxLength: 200,
          maxLines: 3,
          decoration: InputDecoration(
            fillColor: Colors.grey[200],
            filled: true,
            hintText: 'Write your comment...',
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => controller.isCommenting.value = false,
              child: const Text('Cancel'),
            ),
            SizedBox(width: 10.w),
            ElevatedButton(
              onPressed: () => controller.addComment(taskID),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor),
              child: const Text('Post'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCommentsList() {
    return Obx(() => ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: controller.currentTask.value.comments.length,
          itemBuilder: (context, index) {
            final comment = controller.currentTask.value.comments[index];
            return CommentWidget(
              commentId: comment.id,
              commenterId: comment.userId,
              commentBody: comment.body,
              commenterImageUrl: comment.userImageUrl,
              commenterName: comment.name,
            );
          },
          separatorBuilder: (context, index) => const Divider(),
        ));
  }

  Widget _dividerWidget() {
    return Divider(height: 20.h, thickness: 1);
  }

  TextStyle _textStyle() => TextStyle(
        color: AppTheme.textColor,
        fontSize: 12.sp,
      );

  TextStyle _titleStyle() => TextStyle(
        color: AppTheme.primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: 14.sp,
      );
}
