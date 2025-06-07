import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image/image.dart' as img;
import '../utils/notification_service.dart';

class CameraService extends GetxService {
  final NotificationService _notificationService = Get.find();
  
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  final RxBool isInitialized = false.obs;
  final RxBool isCapturing = false.obs;
  final RxDouble exposureOffset = 0.0.obs;
  final RxDouble zoomLevel = 1.0.obs;
  
  CameraController? get controller => _controller;
  bool get hasPermission => _hasPermission;
  bool _hasPermission = false;

  @override
  void onInit() {
    super.onInit();
    _initializeCamera();
  }

  @override
  void onClose() {
    _controller?.dispose();
    super.onClose();
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      await _requestPermission();
      
      if (!_hasPermission) {
        _notificationService.showError('يجب السماح بالوصول للكاميرا');
        return;
      }

      // Get available cameras
      _cameras = await availableCameras();
      
      if (_cameras == null || _cameras!.isEmpty) {
        _notificationService.showError('لا توجد كاميرا متاحة');
        return;
      }

      // Initialize front camera (for face detection)
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );

      await _initializeController(frontCamera);
    } catch (e) {
      _notificationService.showError('فشل في تهيئة الكاميرا: ${e.toString()}');
    }
  }

  Future<void> _initializeController(CameraDescription camera) async {
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    try {
      await _controller!.initialize();
      
      // Configure camera settings for optimal face detection
      await _controller!.setFlashMode(FlashMode.off);
      await _controller!.setFocusMode(FocusMode.auto);
      await _controller!.setExposureMode(ExposureMode.auto);
      
      isInitialized.value = true;
    } catch (e) {
      _notificationService.showError('فشل في تهيئة تحكم الكاميرا');
      throw e;
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    _hasPermission = status == PermissionStatus.granted;
  }

  Future<Uint8List?> captureImage() async {
    if (!isInitialized.value || _controller == null) {
      _notificationService.showError('الكاميرا غير مهيأة');
      return null;
    }

    if (isCapturing.value) return null;

    try {
      isCapturing.value = true;
      
      final XFile imageFile = await _controller!.takePicture();
      final Uint8List imageBytes = await imageFile.readAsBytes();
      
      // Process and optimize image for face detection
      final processedImage = await _processImageForFaceDetection(imageBytes);
      
      return processedImage;
    } catch (e) {
      _notificationService.showError('فشل في التقاط الصورة');
      return null;
    } finally {
      isCapturing.value = false;
    }
  }

  Future<Uint8List> _processImageForFaceDetection(Uint8List imageBytes) async {
    try {
      // Decode image
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) return imageBytes;

      // Resize image for optimal face detection (max 1080px)
      if (image.width > 1080) {
        final ratio = 1080 / image.width;
        final newHeight = (image.height * ratio).round();
        image = img.copyResize(image, width: 1080, height: newHeight);
      }

      // Enhance image quality
      image = img.adjustColor(image, brightness: 1.1, contrast: 1.2);
      
      // Convert back to bytes
      final processedBytes = Uint8List.fromList(img.encodeJpg(image, quality: 90));
      
      return processedBytes;
    } catch (e) {
      // Return original if processing fails
      return imageBytes;
    }
  }

  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    try {
      final currentCamera = _controller!.description;
      final newCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection != currentCamera.lensDirection,
      );

      await _controller!.dispose();
      await _initializeController(newCamera);
    } catch (e) {
      _notificationService.showError('فشل في تغيير الكاميرا');
    }
  }

  Future<void> setZoom(double zoom) async {
    if (!isInitialized.value) return;
    
    try {
      await _controller!.setZoomLevel(zoom);
      zoomLevel.value = zoom;
    } catch (e) {
      // Ignore zoom errors
    }
  }

  Future<void> setExposure(double exposure) async {
    if (!isInitialized.value) return;
    
    try {
      await _controller!.setExposureOffset(exposure);
      exposureOffset.value = exposure;
    } catch (e) {
      // Ignore exposure errors
    }
  }

  Future<void> focusOnPoint(Offset point) async {
    if (!isInitialized.value) return;
    
    try {
      await _controller!.setFocusPoint(point);
    } catch (e) {
      // Ignore focus errors
    }
  }

  Future<void> resetCameraSettings() async {
    if (!isInitialized.value) return;
    
    try {
      await _controller!.setZoomLevel(1.0);
      await _controller!.setExposureOffset(0.0);
      await _controller!.setFocusMode(FocusMode.auto);
      
      zoomLevel.value = 1.0;
      exposureOffset.value = 0.0;
    } catch (e) {
      // Ignore reset errors
    }
  }

  bool get isFrontCamera {
    return _controller?.description.lensDirection == CameraLensDirection.front;
  }

  bool get hasMultipleCameras {
    return _cameras != null && _cameras!.length > 1;
  }

  Future<void> reinitialize() async {
    await _controller?.dispose();
    isInitialized.value = false;
    await _initializeCamera();
  }
}