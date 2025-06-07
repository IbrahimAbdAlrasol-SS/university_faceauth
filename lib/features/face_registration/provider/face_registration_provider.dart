import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:university_face_auth/core/theme/app_theme.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/face_detection_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/notification_service.dart';
import '../../../core/routes/app_routes.dart';

enum RegistrationStep {
  front,
  leftProfile,
  rightProfile,
  lookingUp,
  lookingDown,
}

class FaceRegistrationProvider extends GetxController {
  final CameraService _cameraService = Get.find();
  final FaceDetectionService _faceDetectionService = Get.find();
  final StorageService _storageService = Get.find();
  final NotificationService _notificationService = Get.find();

  // Reactive Variables
  final RxBool isCameraInitialized = false.obs;
  final RxBool isCapturing = false.obs;
  final RxBool canCapture = false.obs;
  final Rx<RegistrationStep> currentStep = RegistrationStep.front.obs;
  final Rxn<FaceDetectionResult> currentDetectionResult = Rxn<FaceDetectionResult>();
  final RxList<Uint8List> capturedImages = <Uint8List>[].obs;
  final RxDouble registrationProgress = 0.0.obs;

  // Constants
  final int totalSteps = RegistrationStep.values.length;
  final int minRequiredImages = 3; // Front + 2 profiles minimum

  CameraController? get cameraController => _cameraService.controller;
  bool get hasMultipleCameras => _cameraService.hasMultipleCameras;

  @override
  void onInit() {
    super.onInit();
    _initializeCamera();
    _startFaceDetectionLoop();
  }

  @override
  void onClose() {
    _stopFaceDetectionLoop();
    super.onClose();
  }

  Future<void> _initializeCamera() async {
    try {
      if (_cameraService.isInitialized.value) {
        isCameraInitialized.value = true;
      } else {
        // Wait for camera to initialize
        ever(_cameraService.isInitialized, (bool initialized) {
          isCameraInitialized.value = initialized;
        });
      }
    } catch (e) {
      _notificationService.showError('فشل في تهيئة الكاميرا');
    }
  }

  void _startFaceDetectionLoop() {
    // Detect faces every 500ms
    ever(_cameraService.isInitialized, (bool initialized) {
      if (initialized) {
        _detectFaceContinuously();
      }
    });
  }

  void _stopFaceDetectionLoop() {
    // Clean up detection loop
  }

  Future<void> _detectFaceContinuously() async {
    if (!isCameraInitialized.value || isCapturing.value) return;

    try {
      final imageBytes = await _cameraService.captureImage();
      if (imageBytes != null) {
        final result = await _faceDetectionService.detectFace(imageBytes);
        currentDetectionResult.value = result;
        
        // Update capture availability based on face quality
        canCapture.value = result.hasFace && 
                          result.quality.index >= FaceQuality.fair.index;
      }
    } catch (e) {
      // Silent fail for continuous detection
    }

    // Continue detection loop
    await Future.delayed(const Duration(milliseconds: 500));
    if (isCameraInitialized.value) {
      _detectFaceContinuously();
    }
  }

  Future<void> captureImage() async {
    if (!canCapture.value || isCapturing.value) return;

    try {
      isCapturing.value = true;

      final imageBytes = await _cameraService.captureImage();
      if (imageBytes == null) {
        _notificationService.showError('فشل في التقاط الصورة');
        return;
      }

      final result = await _faceDetectionService.detectFace(imageBytes);
      
      if (!result.hasFace) {
        _notificationService.showWarning('لم يتم العثور على وجه واضح');
        return;
      }

      if (result.quality.index < FaceQuality.fair.index) {
        _notificationService.showWarning('جودة الصورة ضعيفة، حاول مرة أخرى');
        return;
      }

      // Save the captured image
      if (result.faceImage != null) {
        capturedImages.add(result.faceImage!);
        _updateProgress();
        
        _notificationService.showSuccess(
          'تم التقاط الصورة بنجاح (${capturedImages.length}/${totalSteps})'
        );

        // Move to next step
        _moveToNextStep();
      }
    } catch (e) {
      _notificationService.showError('خطأ في التقاط الصورة');
    } finally {
      isCapturing.value = false;
    }
  }

  void _moveToNextStep() {
    final currentIndex = currentStep.value.index;
    
    if (currentIndex < RegistrationStep.values.length - 1) {
      currentStep.value = RegistrationStep.values[currentIndex + 1];
    } else {
      // All steps completed
      _completeRegistration();
    }
  }

  Future<void> _completeRegistration() async {
    if (capturedImages.length < minRequiredImages) {
      _notificationService.showError(
        'يجب التقاط $minRequiredImages صور على الأقل'
      );
      return;
    }

    try {
      _notificationService.showLoadingDialog(message: 'جاري حفظ بيانات الوجه...');

      // Save face data locally
      await _storageService.saveFaceData(capturedImages.toList());
      
      // Register faces with detection service
      _faceDetectionService.registerFaces(capturedImages.toList());

      // Mark as not first login anymore
      await _storageService.setFirstLogin(false);

      _notificationService.hideLoadingDialog();
      _notificationService.showSuccess('تم تسجيل بصمة الوجه بنجاح!');

      // Navigate to main app
      Get.offAllNamed(AppRoutes.mainNavigation);
    } catch (e) {
      _notificationService.hideLoadingDialog();
      _notificationService.showError('فشل في حفظ بيانات الوجه');
    }
  }

  void _updateProgress() {
    registrationProgress.value = capturedImages.length / totalSteps;
  }

  String getCurrentInstruction() {
    switch (currentStep.value) {
      case RegistrationStep.front:
        return 'انظر مباشرة إلى الكاميرا\nحافظ على وضعية مستقيمة';
      case RegistrationStep.leftProfile:
        return 'أدر رأسك قليلاً إلى اليسار\nأظهر جانب وجهك الأيسر';
      case RegistrationStep.rightProfile:
        return 'أدر رأسك قليلاً إلى اليمين\nأظهر جانب وجهك الأيمن';
      case RegistrationStep.lookingUp:
        return 'ارفع رأسك قليلاً إلى الأعلى\nانظر أعلى الكاميرا قليلاً';
      case RegistrationStep.lookingDown:
        return 'اخفض رأسك قليلاً إلى الأسفل\nانظر أسفل الكاميرا قليلاً';
    }
  }

  bool canSkipCurrentStep() {
    // Only front view is mandatory
    return currentStep.value != RegistrationStep.front && 
           capturedImages.length >= minRequiredImages;
  }

  void skipCurrentStep() {
    if (canSkipCurrentStep()) {
      _moveToNextStep();
    }
  }

  Future<void> switchCamera() async {
    try {
      await _cameraService.switchCamera();
    } catch (e) {
      _notificationService.showError('فشل في تغيير الكاميرا');
    }
  }

  Future<bool> onBackPressed() async {
    if (capturedImages.isEmpty) {
      // No images captured, can go back
      return true;
    }

    final shouldExit = await _notificationService.showConfirmDialog(
      title: 'إلغاء التسجيل',
      message: 'سيتم فقدان جميع الصور المسجلة. هل تريد المتابعة؟',
      confirmText: 'نعم، إلغاء',
      cancelText: 'لا، متابعة',
      confirmColor: AppTheme.errorColor,
    );

    if (shouldExit == true) {
      capturedImages.clear();
      return true;
    }
    
    return false;
  }

  void retakeCurrentImage() {
    if (capturedImages.isNotEmpty) {
      capturedImages.removeLast();
      _updateProgress();
      
      // Go back to previous step
      if (currentStep.value.index > 0) {
        currentStep.value = RegistrationStep.values[currentStep.value.index - 1];
      }
    }
  }

  void resetRegistration() {
    capturedImages.clear();
    currentStep.value = RegistrationStep.front;
    registrationProgress.value = 0.0;
    currentDetectionResult.value = null;
  }
}