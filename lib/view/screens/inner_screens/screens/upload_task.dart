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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isLargeTablet = constraints.maxWidth >= 1200;
          final horizontalPadding =
              isLargeTablet ? constraints.maxWidth * 0.2 : 16.w;

          return Container(
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
                child: Center(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: isLargeTablet ? 800.0 : double.infinity,
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: isLargeTablet ? 32.0 : 16.w,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          elevation: 0,
                          color: colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                isLargeTablet ? 24.0 : 16.r),
                            side: BorderSide(
                              color: colorScheme.outlineVariant,
                              width: isLargeTablet ? 2.0 : 1.0,
                            ),
                          ),
                          child: Padding(
                            padding:
                                EdgeInsets.all(isLargeTablet ? 32.0 : 16.w),
                            child: Form(
                              key: controller.formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    l10n.allFieldsRequired,
                                    style: TextStyle(
                                      color: colorScheme.primary,
                                      fontSize: isLargeTablet ? 28.0 : 20.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: isLargeTablet ? 32.0 : 24.h),
                                  _buildTaskCategory(
                                      context, colorScheme, isLargeTablet),
                                  SizedBox(height: isLargeTablet ? 24.0 : 16.h),
                                  _buildTaskTitle(
                                      context, colorScheme, isLargeTablet),
                                  SizedBox(height: isLargeTablet ? 24.0 : 16.h),
                                  _buildTaskDescription(
                                      context, colorScheme, isLargeTablet),
                                  SizedBox(height: isLargeTablet ? 24.0 : 16.h),
                                  _buildTaskDeadline(
                                      context, colorScheme, isLargeTablet),
                                  SizedBox(height: isLargeTablet ? 32.0 : 24.h),
                                  _buildUploadButton(
                                      context, colorScheme, isLargeTablet),
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
        },
      ),
    );
  }

  Widget _buildTaskCategory(
      BuildContext context, ColorScheme colorScheme, bool isLargeTablet) {
    return InkWell(
      onTap: () => controller.showTaskCategoriesDialog(context),
      child: TextFormField(
        controller: controller.taskCategoryController,
        enabled: false,
        style: TextStyle(
          color: colorScheme.onSurface,
          fontSize: isLargeTablet ? 16.0 : 14.0,
        ),
        decoration: InputDecoration(
          labelText: AppLocalizations.of(context)!.taskCategory,
          labelStyle: TextStyle(
            color: colorScheme.primary,
            fontSize: isLargeTablet ? 16.0 : 14.0,
          ),
          prefixIcon: Icon(
            Icons.category_rounded,
            color: colorScheme.primary,
            size: isLargeTablet ? 28.0 : 24.0,
          ),
          suffixIcon: Icon(
            Icons.arrow_drop_down,
            color: colorScheme.primary,
            size: isLargeTablet ? 28.0 : 24.0,
          ),
          filled: true,
          fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isLargeTablet ? 16.0 : 12.r),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isLargeTablet ? 16.0 : 12.r),
            borderSide: BorderSide(
              color: colorScheme.outline,
              width: isLargeTablet ? 2.0 : 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isLargeTablet ? 16.0 : 12.r),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: isLargeTablet ? 3.0 : 2.0,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(isLargeTablet ? 16.0 : 12.r),
            borderSide: BorderSide(
              color: colorScheme.error,
              width: isLargeTablet ? 2.0 : 1.0,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: isLargeTablet ? 24.0 : 16.0,
            vertical: isLargeTablet ? 20.0 : 16.0,
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

  Widget _buildTaskDeadline(
      BuildContext context, ColorScheme colorScheme, bool isLargeTablet) {
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

  Widget _buildTaskTitle(
      BuildContext context, ColorScheme colorScheme, bool isLargeTablet) {
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

  Widget _buildTaskDescription(
      BuildContext context, ColorScheme colorScheme, bool isLargeTablet) {
    return TextFormField(
      controller: controller.taskDescriptionController,
      style: TextStyle(
        color: colorScheme.onSurface,
        fontSize: isLargeTablet ? 16.0 : 14.0,
      ),
      maxLines: 5,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.taskDescription,
        labelStyle: TextStyle(
          color: colorScheme.primary,
          fontSize: isLargeTablet ? 16.0 : 14.0,
        ),
        prefixIcon: Icon(
          Icons.description,
          color: colorScheme.primary,
          size: isLargeTablet ? 28.0 : 24.0,
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isLargeTablet ? 16.0 : 12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isLargeTablet ? 16.0 : 12.r),
          borderSide: BorderSide(
            color: colorScheme.outline,
            width: isLargeTablet ? 2.0 : 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isLargeTablet ? 16.0 : 12.r),
          borderSide: BorderSide(
            color: colorScheme.primary,
            width: isLargeTablet ? 3.0 : 2.0,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isLargeTablet ? 16.0 : 12.r),
          borderSide: BorderSide(
            color: colorScheme.error,
            width: isLargeTablet ? 2.0 : 1.0,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: isLargeTablet ? 24.0 : 16.0,
          vertical: isLargeTablet ? 20.0 : 16.0,
        ),
      ),
      validator: (value) =>
          value!.isEmpty ? AppLocalizations.of(context)!.fieldRequired : null,
    );
  }

  Widget _buildUploadButton(
      BuildContext context, ColorScheme colorScheme, bool isLargeTablet) {
    return Center(
      child: Obx(() => FilledButton.icon(
            onPressed: controller.isLoading.value ? null : _uploadTaskAndNotify,
            icon: controller.isLoading.value
                ? SizedBox(
                    width: isLargeTablet ? 32.0 : 24.w,
                    height: isLargeTablet ? 32.0 : 24.w,
                    child: CircularProgressIndicator(
                      strokeWidth: isLargeTablet ? 3.0 : 2.0,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : Icon(
                    Icons.upload_rounded,
                    size: isLargeTablet ? 32.0 : 24.w,
                  ),
            label: Text(
              AppLocalizations.of(context)!.uploadTask,
              style: TextStyle(
                fontSize: isLargeTablet ? 20.0 : 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(
                horizontal: isLargeTablet ? 48.0 : 32.w,
                vertical: isLargeTablet ? 24.0 : 16.h,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(isLargeTablet ? 16.0 : 12.r),
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
