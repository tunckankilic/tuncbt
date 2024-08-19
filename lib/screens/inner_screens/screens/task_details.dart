import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tuncbt/constants/constants.dart';
import 'package:tuncbt/screens/inner_screens/inner_screen_controller.dart';
import 'package:tuncbt/widgets/comments_widget.dart';

class TaskDetailsScreen extends GetView<InnerScreenController> {
  static const routeName = "/task-details";

  final String uploadedBy;
  final String taskID;

  TaskDetailsScreen({Key? key, required this.uploadedBy, required this.taskID})
      : super(key: key) {
    controller.getTaskData(taskID, uploadedBy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Back',
            style: TextStyle(
              color: Constants.darkBlue,
              fontStyle: FontStyle.italic,
              fontSize: 20,
            ),
          ),
        ),
      ),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 15),
                    Text(
                      controller.taskTitle.value,
                      style: TextStyle(
                        color: Constants.darkBlue,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildUploadedBySection(),
                              _dividerWidget(),
                              _buildDateSection(),
                              _dividerWidget(),
                              _buildDoneStateSection(),
                              _dividerWidget(),
                              _buildDescriptionSection(),
                              const SizedBox(height: 40),
                              _buildCommentSection(),
                              const SizedBox(height: 40),
                              _buildCommentsList(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildUploadedBySection() {
    return Row(
      children: [
        Text('Uploaded by ',
            style: TextStyle(
                color: Constants.darkBlue,
                fontWeight: FontWeight.bold,
                fontSize: 15)),
        const Spacer(),
        Container(
          height: 50,
          width: 50,
          decoration: BoxDecoration(
            border: Border.all(width: 3, color: Colors.pink.shade700),
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage(controller.userImageUrl.value.isEmpty
                  ? 'https://cdn.pixabay.com/photo/2016/08/08/09/17/avatar-1577909_1280.png'
                  : controller.userImageUrl.value),
              fit: BoxFit.fill,
            ),
          ),
        ),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(controller.authorName.value, style: _textStyle()),
            Text(controller.authorPosition.value, style: _textStyle()),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Uploaded on:', style: _titleStyle()),
            Text(controller.postedDate.value, style: _textStyle()),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Deadline date:', style: _titleStyle()),
            Text(controller.deadlineDate.value,
                style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.normal,
                    fontSize: 15)),
          ],
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            controller.isDeadlineAvailable.value
                ? 'Deadline is not finished yet'
                : 'Deadline passed',
            style: TextStyle(
              color: controller.isDeadlineAvailable.value
                  ? Colors.green
                  : Colors.red,
              fontWeight: FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoneStateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Done state:', style: _titleStyle()),
        const SizedBox(height: 15),
        Row(
          children: [
            TextButton(
              onPressed: () => controller.updateTaskStatus(taskID, true),
              child: Text('Done', style: _textStyle()),
            ),
            Opacity(
              opacity: controller.isDone.value ? 1 : 0,
              child: const Icon(Icons.check_box, color: Colors.green),
            ),
            const SizedBox(width: 40),
            TextButton(
              onPressed: () => controller.updateTaskStatus(taskID, false),
              child: Text('Not Done', style: _textStyle()),
            ),
            Opacity(
              opacity: !controller.isDone.value ? 1 : 0,
              child: const Icon(Icons.check_box, color: Colors.red),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Task Description', style: _titleStyle()),
        const SizedBox(height: 10),
        Text(controller.taskDescription.value, style: _textStyle()),
      ],
    );
  }

  Widget _buildCommentSection() {
    return Obx(() => AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: controller.isCommenting.value
              ? _buildCommentInput()
              : Center(
                  child: MaterialButton(
                    onPressed: () => controller.isCommenting.value = true,
                    color: Colors.pink.shade700,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13)),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Add a Comment',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                    ),
                  ),
                ),
        ));
  }

  Widget _buildCommentInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 3,
          child: TextField(
            controller: controller.commentController,
            style: TextStyle(color: Constants.darkBlue),
            maxLength: 200,
            keyboardType: TextInputType.text,
            maxLines: 6,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(Get.context!).scaffoldBackgroundColor,
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white)),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pink)),
            ),
          ),
        ),
        Flexible(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: MaterialButton(
                  onPressed: () => controller.addComment(taskID),
                  color: Colors.pink.shade700,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text(
                    'Post',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => controller.isCommenting.value = false,
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentsList() {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('tasks').doc(taskID).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No Comments for this task'));
        }
        final comments = snapshot.data!['taskComments'] as List<dynamic>;
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: comments.length,
          itemBuilder: (context, index) {
            final comment = comments[index];
            return CommentWidget(
              commentId: comment['commentId'],
              commenterId: comment['userId'],
              commentBody: comment['commentBody'],
              commenterImageUrl: comment['userImageUrl'],
              commenterName: comment['name'],
            );
          },
          separatorBuilder: (context, index) => const Divider(thickness: 1),
        );
      },
    );
  }

  Widget _dividerWidget() {
    return const Column(
      children: [
        SizedBox(height: 10),
        Divider(thickness: 1),
        SizedBox(height: 10),
      ],
    );
  }

  TextStyle _textStyle() => TextStyle(
      color: Constants.darkBlue, fontSize: 13, fontWeight: FontWeight.normal);
  TextStyle _titleStyle() => TextStyle(
      color: Constants.darkBlue, fontWeight: FontWeight.bold, fontSize: 20);
}
