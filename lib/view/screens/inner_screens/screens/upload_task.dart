import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tuncbt/core/config/constants.dart';
import 'package:tuncbt/providers/team_provider.dart';
import 'package:tuncbt/view/screens/inner_screens/inner_screen_controller.dart';
import 'package:tuncbt/view/widgets/drawer_widget.dart';
import 'package:tuncbt/core/services/push_notifications.dart';

class UploadTask extends GetView<InnerScreenController> {
  static const routeName = "/upload-task";

  UploadTask({Key? key}) : super(key: key);

  final PushNotificationSystems _notificationSystems =
      Get.find<PushNotificationSystems>();

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

    if (!teamProvider.isAdmin && !teamProvider.isManager) {
      Get.back();
      Get.snackbar(
        'Hata',
        'Görev ekleme yetkiniz bulunmuyor',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return const SizedBox.shrink();
    }

    Get.put(InnerScreenController());
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${teamProvider.currentTeam?.teamName ?? 'Takım'} - Yeni Görev',
          style: const TextStyle(color: AppTheme.textColor),
        ),
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
      'Tüm alanlar zorunludur',
      style: TextStyle(
        color: AppTheme.primaryColor,
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTaskCategory() {
    return _buildFormField(
      label: 'Görev Kategorisi*',
      controller: controller.taskCategoryController,
      onTap: () => controller.showTaskCategoriesDialog(Get.context!),
      enabled: false,
      icon: Icons.category,
    );
  }

  Widget _buildTaskTitle() {
    return _buildFormField(
      label: 'Görev Başlığı*',
      controller: controller.taskTitleController,
      maxLength: 100,
      icon: Icons.title,
    );
  }

  Widget _buildTaskDescription() {
    return _buildFormField(
      label: 'Görev Açıklaması*',
      controller: controller.taskDescriptionController,
      maxLength: 1000,
      maxLines: 3,
      icon: Icons.description,
    );
  }

  Widget _buildTaskDeadline() {
    return _buildFormField(
      label: 'Son Tarih*',
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
                  return "Bu alan zorunludur";
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
                label: const Text('Görevi Yükle'),
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
          'Başarılı',
          'Görev yüklendi ve bildirim oluşturuldu',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        print('Error uploading task: $e');
        Get.snackbar(
          'Hata',
          'Görev yüklenirken hata oluştu',
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
