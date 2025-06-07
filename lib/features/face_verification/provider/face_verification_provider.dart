import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import '../../../core/services/camera_service.dart';
import '../../../core/services/face_detection_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/utils/notification_service.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/config/app_config.dart';
import '../../auth/model/user_model.dart';

enum VerificationState {
  idle,
  detecting,
  verifying,
  success,
  failed,
}

class FaceVerificationProvider extends GetxController {
  final CameraService _cameraService = Get.find();
  final FaceDetectionService _faceDetectionService = Get.find();
  final StorageService _storageService = Get.find();
  final NotificationService _notificationService = Get.find();

  // Reactive Variables
  final RxBool isCameraInitialized = false.obs;
  final Rx<VerificationState> verificationState = VerificationState.idle.obs;
  final Rxn<FaceDetectionResult> currentDetectionResult = Rxn<FaceDetectionResult>();
  final RxDouble verificationProgress = 0.0.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  // Internal Variables
  Timer? _detectionTimer;
  Timer? _verificationTimer;
  List<Uint8List>? _storedFaceData;
  int _verificationAttempts = 0;
  final int _maxVerificationAttempts = 3;
  final Duration _verificationTimeout = const Duration(seconds: AppConfig.faceVerificationTimeout);

  CameraController? get cameraController => _cameraService.controller;

  @override
  void onInit() {
    super.onInit();
    _initializeVerification();
  }

  @override
  void onClose() {
    _stopTimers();
    super.onClose();
  }

  Future<void> _initializeVerification() async {
    try {
      // Load user data
      final userData = _storageService.getUserData();
      if (userData != null) {
        currentUser.value = UserModel.fromJson(userData);
      }

      // Load stored face data
      _storedFaceData = _storageService.getFaceData();
      if (_storedFaceData == null || _storedFaceData!.isEmpty) {
        _notificationService.showError('لم يتم العثور على بيانات الوجه المسجلة');
        Get.offAllNamed(AppRoutes.faceRegistration);
        return;
      }

      // Initialize camera
      if (_cameraService.isInitialized.value) {
        isCameraInitialized.value = true;
        _startAutomaticVerification();
      } else {
        ever(_cameraService.isInitialized, (bool initialized) {
          if (initialized) {
            isCameraInitialized.value = true;
            _startAutomaticVerification();
          }
        });
      }
    } catch (e) {
      _notificationService.showError('فشل في تهيئة نظام التحقق');
    }
  }

  void _startAutomaticVerification() {
    verificationState.value = VerificationState.detecting;
    
    // Start continuous face detection
    _detectionTimer = Timer.periodic(
      const Duration(milliseconds: 1000),
      (_) => _detectAndVerify(),
    );

    // Set verification timeout
    _verificationTimer = Timer(_verificationTimeout, () {
      if (verificationState.value != VerificationState.success) {
        _handleVerificationTimeout();
      }
    });
  }

  Future<void> _detectAndVerify() async {
    if (verificationState.value == VerificationState.verifying || 
        verificationState.value == VerificationState.success) {
      return;
    }

    try {
      final imageBytes = await _cameraService.captureImage();
      if (imageBytes == null) return;

      final detectionResult = await _faceDetectionService.detectFace(imageBytes);
      currentDetectionResult.value = detectionResult;

      if (detectionResult.hasFace && 
          detectionResult.quality.index >= FaceQuality.good.index) {
        await _performVerification(imageBytes);
      }
    } catch (e) {
      // Silent fail for automatic verification
    }
  }

  Future<void> _performVerification(Uint8List faceImage) async {
    if (verificationState.value == VerificationState.verifying) return;

    try {
      verificationState.value = VerificationState.verifying;
      _verificationAttempts++;

      // Simulate verification progress
      _animateVerificationProgress();

      final isVerified = await _faceDetectionService.verifyFace(
        faceImage,
        _storedFaceData!,
      );

      if (isVerified) {
        await _handleSuccessfulVerification();
      } else {
        await _handleFailedVerification();
      }
    } catch (e) {
      await _handleFailedVerification();
    }
  }

  void _animateVerificationProgress() {
    verificationProgress.value = 0.0;
    
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (verificationState.value != VerificationState.verifying) {
        timer.cancel();
        return;
      }

      verificationProgress.value += 0.05;
      
      if (verificationProgress.value >= 1.0) {
        timer.cancel();
      }
    });
  }

  Future<void> _handleSuccessfulVerification() async {
    _stopTimers();
    verificationState.value = VerificationState.success;
    verificationProgress.value = 1.0;

    // Wait for success animation
    await Future.delayed(const Duration(seconds: 2));
  }

  Future<void> _handleFailedVerification() async {
    verificationState.value = VerificationState.failed;
    verificationProgress.value = 0.0;

    if (_verificationAttempts >= _maxVerificationAttempts) {
      _notificationService.showError('فشل في التحقق بعد عدة محاولات');
      await Future.delayed(const Duration(seconds: 2));
      skipVerification();
    } else {
      // Reset to detecting state for another attempt
      await Future.delayed(const Duration(seconds: 2));
      verificationState.value = VerificationState.detecting;
    }
  }

  void _handleVerificationTimeout() {
    _stopTimers();
    _notificationService.showWarning('انتهت مهلة التحقق من الهوية');
    skipVerification();
  }

  void startManualVerification() {
    if (verificationState.value == VerificationState.verifying) return;

    _stopTimers();
    _startAutomaticVerification();
  }

  void skipVerification() {
    _stopTimers();
    Get.offAllNamed(AppRoutes.login);
  }

  void navigateToMain() {
    Get.offAllNamed(AppRoutes.mainNavigation);
  }

  void _stopTimers() {
    _detectionTimer?.cancel();
    _verificationTimer?.cancel();
    _detectionTimer = null;
    _verificationTimer = null;
  }

  // Getters for UI
  bool get isVerifying => verificationState.value == VerificationState.verifying;
  bool get isSuccessful => verificationState.value == VerificationState.success;
  bool get hasFailed => verificationState.value == VerificationState.failed;
  
  String get statusMessage {
    switch (verificationState.value) {
      case VerificationState.idle:
        return 'ضع وجهك داخل الإطار';
      case VerificationState.detecting:
        return 'جاري البحث عن الوجه...';
      case VerificationState.verifying:
        return 'جاري التحقق من الهوية...';
      case VerificationState.success:
        return 'تم التحقق بنجاح!';
      case VerificationState.failed:
        return 'فشل في التحقق، حاول مرة أخرى';
    }
  }

  Color get statusColor {
    switch (verificationState.value) {
      case VerificationState.idle:
      case VerificationState.detecting:
        return Colors.white;
      case VerificationState.verifying:
        return AppTheme.accentColor;
      case VerificationState.success:
        return AppTheme.successColor;
      case VerificationState.failed:
        return AppTheme.errorColor;
    }
  }
}