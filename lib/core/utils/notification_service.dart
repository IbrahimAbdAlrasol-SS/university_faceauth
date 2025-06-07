import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../theme/app_theme.dart';

class NotificationService extends GetxService {
  
  void showSuccess(String message, {Duration? duration}) {
    Get.showSnackbar(
      GetSnackBar(
        title: 'نجح!',
        message: message,
        backgroundColor: AppTheme.successColor,
        colorText: Colors.white,
        duration: duration ?? const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
        borderRadius: 16,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        leftBarIndicatorColor: Colors.white,
        animationDuration: const Duration(milliseconds: 300),
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInBack,
      ),
    );
  }

  void showError(String message, {Duration? duration}) {
    Get.showSnackbar(
      GetSnackBar(
        title: 'خطأ!',
        message: message,
        backgroundColor: AppTheme.errorColor,
        colorText: Colors.white,
        duration: duration ?? const Duration(seconds: 4),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
        borderRadius: 16,
        icon: const Icon(Icons.error, color: Colors.white),
        leftBarIndicatorColor: Colors.white,
        animationDuration: const Duration(milliseconds: 300),
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInBack,
      ),
    );
  }

  void showWarning(String message, {Duration? duration}) {
    Get.showSnackbar(
      GetSnackBar(
        title: 'تنبيه!',
        message: message,
        backgroundColor: AppTheme.warningColor,
        colorText: Colors.white,
        duration: duration ?? const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
        borderRadius: 16,
        icon: const Icon(Icons.warning, color: Colors.white),
        leftBarIndicatorColor: Colors.white,
        animationDuration: const Duration(milliseconds: 300),
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInBack,
      ),
    );
  }

  void showInfo(String message, {Duration? duration}) {
    Get.showSnackbar(
      GetSnackBar(
        title: 'معلومة',
        message: message,
        backgroundColor: AppTheme.accentColor,
        colorText: Colors.white,
        duration: duration ?? const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
        borderRadius: 16,
        icon: const Icon(Icons.info, color: Colors.white),
        leftBarIndicatorColor: Colors.white,
        animationDuration: const Duration(milliseconds: 300),
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInBack,
      ),
    );
  }

  Future<void> showCustomNotification({
    required String title,
    required String message,
    required Color backgroundColor,
    required IconData icon,
    Duration? duration,
    VoidCallback? onTap,
  }) async {
    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        backgroundColor: backgroundColor,
        colorText: Colors.white,
        duration: duration ?? const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
        margin: const EdgeInsets.all(20),
        borderRadius: 16,
        icon: Icon(icon, color: Colors.white),
        leftBarIndicatorColor: Colors.white,
        onTap: onTap != null ? (_) => onTap() : null,
        animationDuration: const Duration(milliseconds: 300),
        forwardAnimationCurve: Curves.easeOutBack,
        reverseAnimationCurve: Curves.easeInBack,
      ),
    );
  }

  Future<bool?> showConfirmDialog({
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    Color? confirmColor,
  }) async {
    return await Get.dialog<bool>(
      SlideInDown(
        duration: const Duration(milliseconds: 300),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          content: Text(
            message,
            style: Get.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                cancelText,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: confirmColor ?? AppTheme.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(confirmText),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
  }

  void showLoadingDialog({String message = 'جاري التحميل...'}) {
    Get.dialog(
      SlideInUp(
        duration: const Duration(milliseconds: 300),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              ),
              const SizedBox(height: 20),
              Text(
                message,
                style: Get.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  void hideLoadingDialog() {
    if (Get.isDialogOpen == true) {
      Get.back();
    }
  }
}