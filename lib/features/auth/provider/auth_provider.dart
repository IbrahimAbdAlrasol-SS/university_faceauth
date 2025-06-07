import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/network/base_client.dart';
import '../../../core/utils/notification_service.dart';
import '../../../core/routes/app_routes.dart';
import '../server/auth_server.dart';
import '../model/user_model.dart';

class AuthProvider extends GetxController {
  final StorageService _storageService = Get.find();
  final NotificationService _notificationService = Get.find();
  final AuthServer _authServer = AuthServer();

  // Form Controllers
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController universityIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Reactive Variables
  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    _loadSavedUser();
  }

  @override
  void onClose() {
    universityIdController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void _loadSavedUser() {
    final userData = _storageService.getUserData();
    if (userData != null) {
      try {
        currentUser.value = UserModel.fromJson(userData);
      } catch (e) {
        // Invalid user data, clear it
        _storageService.clearUserData();
      }
    }
  }

  String? validateUniversityId(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'المعرف الجامعي مطلوب';
    }
    
    if (value.trim().length < 6) {
      return 'المعرف الجامعي يجب أن يكون 6 أرقام على الأقل';
    }
    
    if (value.trim().length > 10) {
      return 'المعرف الجامعي لا يجب أن يزيد عن 10 أرقام';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(value.trim())) {
      return 'المعرف الجامعي يجب أن يحتوي على أرقام فقط';
    }
    
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    
    if (value.trim().length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    
    return null;
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    // Validate form
    if (!formKey.currentState!.validate()) {
      _notificationService.showError('يرجى التأكد من صحة البيانات');
      return;
    }

    try {
      isLoading.value = true;

      final loginData = {
        'university_id': universityIdController.text.trim(),
        'password': passwordController.text.trim(),
      };

      final response = await _authServer.login(loginData);

      if (response.isSuccess && response.data != null) {
        final user = UserModel.fromJson(response.data!);
        
        // Save user data
        await _storageService.saveUserData(user.toJson());
        currentUser.value = user;

        // Save auth token if available
        if (response.data!['token'] != null) {
          await _storageService.saveToken(response.data!['token']);
        }

        _notificationService.showSuccess('تم تسجيل الدخول بنجاح');

        // Navigate based on face registration status
        if (_storageService.hasFaceData) {
          Get.offAllNamed(AppRoutes.faceVerification);
        } else {
          await _storageService.setFirstLogin(true);
          Get.offAllNamed(AppRoutes.faceRegistration);
        }
      } else {
        _notificationService.showError(
          response.error?.message ?? 'فشل في تسجيل الدخول'
        );
      }
    } catch (e) {
      _notificationService.showError('حدث خطأ غير متوقع');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;

      // Call logout API if needed
      await _authServer.logout();

      // Clear all local data
      await _storageService.clearAllData();
      currentUser.value = null;

      _notificationService.showSuccess('تم تسجيل الخروج بنجاح');
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      _notificationService.showError('حدث خطأ أثناء تسجيل الخروج');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword() async {
    final universityId = universityIdController.text.trim();
    
    if (universityId.isEmpty) {
      _notificationService.showWarning('يرجى إدخال المعرف الجامعي أولاً');
      return;
    }

    try {
      isLoading.value = true;

      final response = await _authServer.forgotPassword({
        'university_id': universityId,
      });

      if (response.isSuccess) {
        _notificationService.showSuccess(
          'تم إرسال رابط إعادة تعيين كلمة المرور'
        );
      } else {
        _notificationService.showError(
          response.error?.message ?? 'فشل في إرسال رابط إعادة التعيين'
        );
      }
    } catch (e) {
      _notificationService.showError('حدث خطأ غير متوقع');
    } finally {
      isLoading.value = false;
    }
  }

  bool get isLoggedIn => currentUser.value != null && _storageService.hasToken;

  String get userName => currentUser.value?.name ?? 'المستخدم';
  String get userUniversityId => currentUser.value?.universityId ?? '';
  String get userEmail => currentUser.value?.email ?? '';

  void clearForm() {
    universityIdController.clear();
    passwordController.clear();
    formKey.currentState?.reset();
  }
}