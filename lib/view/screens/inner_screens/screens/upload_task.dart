import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/l10n/app_localizations.dart';
import 'package:tuncbt/view/screens/inner_screens/inner_screen_controller.dart';
import 'package:tuncbt/core/services/push_notifications.dart';

class UploadTaskScreen extends GetView<InnerScreenController> {
  static const routeName = '/upload-task';

  UploadTaskScreen({Key? key}) : super(key: key);

  final PushNotificationSystems _notificationSystems =
      Get.find<PushNotificationSystems>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.uploadTask),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 2,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.surfaceVariant,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 0,
                    color: colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                      side: BorderSide(
                        color: colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Form(
                        key: controller.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.allFieldsRequired,
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            _buildTaskCategory(context, colorScheme),
                            SizedBox(height: 16.h),
                            _buildTaskTitle(context, colorScheme),
                            SizedBox(height: 16.h),
                            _buildTaskDescription(context, colorScheme),
                            SizedBox(height: 16.h),
                            _buildTaskDeadline(context, colorScheme),
                            SizedBox(height: 24.h),
                            _buildUploadButton(context, colorScheme),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCategory(BuildContext context, ColorScheme colorScheme) {
    return InkWell(
      onTap: () => controller.showTaskCategoriesDialog(context),
      child: TextFormField(
        controller: controller.taskCategoryController,
        enabled: false,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.taskCategory,
          labelStyle: TextStyle(color: colorScheme.primary),
          prefixIcon: Icon(Icons.category_rounded, color: colorScheme.primary),
          suffixIcon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: colorScheme.error),
          ),
        ),
        validator: (value) {
          if (value == null ||
              value.isEmpty ||
              value == 'Görev kategorisi seçin') {
            return AppLocalizations.of(context)!.fieldRequired;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTaskDeadline(BuildContext context, ColorScheme colorScheme) {
    return InkWell(
      onTap: () => controller.pickDateDialog(context),
      child: TextFormField(
        controller: controller.deadlineDateController,
        enabled: false,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.taskDeadline,
          labelStyle: TextStyle(color: colorScheme.primary),
          prefixIcon:
              Icon(Icons.calendar_today_rounded, color: colorScheme.primary),
          suffixIcon: Icon(Icons.arrow_drop_down, color: colorScheme.primary),
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: colorScheme.error),
          ),
        ),
        validator: (value) {
          if (value == null ||
              value.isEmpty ||
              value == 'Görev son tarihini seçin') {
            return AppLocalizations.of(context)!.fieldRequired;
          }
          return null;
        },
      ),
    );
  }

  Widget _buildTaskTitle(BuildContext context, ColorScheme colorScheme) {
    return TextFormField(
      controller: controller.taskTitleController,
      style: TextStyle(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.taskTitle,
        labelStyle: TextStyle(color: colorScheme.primary),
        prefixIcon: Icon(Icons.title, color: colorScheme.primary),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
      validator: (value) =>
          value!.isEmpty ? AppLocalizations.of(context)!.fieldRequired : null,
    );
  }

  Widget _buildTaskDescription(BuildContext context, ColorScheme colorScheme) {
    return TextFormField(
      controller: controller.taskDescriptionController,
      style: TextStyle(color: colorScheme.onSurface),
      maxLines: 5,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.taskDescription,
        labelStyle: TextStyle(color: colorScheme.primary),
        prefixIcon: Icon(Icons.description, color: colorScheme.primary),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: colorScheme.error),
        ),
      ),
      validator: (value) =>
          value!.isEmpty ? AppLocalizations.of(context)!.fieldRequired : null,
    );
  }

  Widget _buildUploadButton(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Obx(() => FilledButton.icon(
            onPressed: controller.isLoading.value ? null : _uploadTaskAndNotify,
            icon: controller.isLoading.value
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Icon(Icons.upload_rounded, size: 24.w),
            label: Text(
              AppLocalizations.of(context)!.uploadTask,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: 32.w,
                vertical: 16.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          )),
    );
  }

  void _uploadTaskAndNotify() async {
    if (controller.formKey.currentState!.validate()) {
      try {
        await controller.uploadTask();
        await _createTaskAddedNotification();
        Get.back();
        Get.snackbar(
          AppLocalizations.of(Get.context!)!.ok,
          AppLocalizations.of(Get.context!)!.taskUploadSuccess,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        print('Error uploading task: $e');
        Get.snackbar(
          AppLocalizations.of(Get.context!)!.error,
          AppLocalizations.of(Get.context!)!.taskUploadError,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }
  }

  Future<void> _createTaskAddedNotification() async {
    String? taskID = await controller.getLastUploadedTaskID();
    String uploadedBy = controller.getCurrentUserId();
    if (taskID != null) {
      await _notificationSystems.createTaskAddedNotification(
          taskID, uploadedBy);
    } else {
      print('Failed to get the last uploaded task ID');
    }
  }
}
