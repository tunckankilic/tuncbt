import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/config/constants.dart';
import 'package:tuncbt/screens/inner_screens/inner_screen_controller.dart';
import 'package:tuncbt/widgets/drawer_widget.dart';
import 'package:tuncbt/services/push_notifications.dart';

class UploadTask extends GetView<InnerScreenController> {
  static const routeName = "/upload-task";

  UploadTask({Key? key}) : super(key: key);

  final PushNotificationSystems _notificationSystems =
      Get.find<PushNotificationSystems>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Task',
            style: TextStyle(color: AppTheme.textColor)),
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
      ),
      drawer: DrawerWidget(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      SizedBox(height: 20.h),
                      _buildTaskCategory(),
                      _buildTaskTitle(),
                      _buildTaskDescription(),
                      _buildTaskDeadline(),
                      SizedBox(height: 20.h),
                      _buildUploadButton(),
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

  Widget _buildHeader() {
    return Text(
      'All Fields are required',
      style: TextStyle(
        color: AppTheme.primaryColor,
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTaskCategory() {
    return _buildFormField(
      label: 'Task Category*',
      controller: controller.taskCategoryController,
      onTap: () => controller.showTaskCategoriesDialog(Get.context!),
      enabled: false,
      icon: Icons.category,
    );
  }

  Widget _buildTaskTitle() {
    return _buildFormField(
      label: 'Task Title*',
      controller: controller.taskTitleController,
      maxLength: 100,
      icon: Icons.title,
    );
  }

  Widget _buildTaskDescription() {
    return _buildFormField(
      label: 'Task Description*',
      controller: controller.taskDescriptionController,
      maxLength: 1000,
      maxLines: 3,
      icon: Icons.description,
    );
  }

  Widget _buildTaskDeadline() {
    return _buildFormField(
      label: 'Task Deadline Date*',
      controller: controller.deadlineDateController,
      onTap: () => controller.pickDateDialog(Get.context!),
      enabled: false,
      icon: Icons.calendar_today,
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    VoidCallback? onTap,
    bool enabled = true,
    int maxLength = 100,
    int maxLines = 1,
    IconData? icon,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          InkWell(
            onTap: onTap,
            child: TextFormField(
              controller: controller,
              enabled: enabled,
              maxLength: maxLength,
              maxLines: maxLines,
              style: const TextStyle(color: AppTheme.textColor),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppTheme.backgroundColor,
                prefixIcon: Icon(icon, color: AppTheme.primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide: const BorderSide(color: AppTheme.primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.r),
                  borderSide:
                      const BorderSide(color: AppTheme.accentColor, width: 2),
                ),
              ),
              validator: (value) {
                if (value!.isEmpty) {
                  return "This field is required";
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton() {
    return Center(
      child: Obx(
        () => controller.isLoading.value
            ? const CircularProgressIndicator()
            : ElevatedButton.icon(
                onPressed: _uploadTaskAndNotify,
                icon: const Icon(Icons.upload_file),
                label: const Text('Upload Task'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  padding:
                      EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  textStyle: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
      ),
    );
  }

  void _uploadTaskAndNotify() async {
    if (controller.formKey.currentState!.validate()) {
      try {
        await controller.uploadTask();
        // Görev başarıyla yüklendi, bildirim oluştur
        await _createTaskAddedNotification();
        Get.snackbar(
          'Success',
          'Task uploaded and notification created',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        print('Error uploading task: $e');
        Get.snackbar(
          'Error',
          'Failed to upload task',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _createTaskAddedNotification() async {
    String? taskID = await controller.getLastUploadedTaskID();
    String uploadedBy = controller
        .getCurrentUserId(); // Bu metodu InnerScreenController'a eklemelisiniz
    if (taskID != null) {
      await Get.find<PushNotificationSystems>()
          .createTaskAddedNotification(taskID, uploadedBy);
    } else {
      print('Failed to get the last uploaded task ID');
    }
  }
}
