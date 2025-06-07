import 'dart:typed_data';
import 'dart:math' as math;
import 'dart:ui';
import 'package:get/get.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image/image.dart' as img;
import 'package:university_face_auth/core/config/config_App.dart';
import '../utils/notification_service.dart';

enum FaceQuality { poor, fair, good, excellent }

class FaceDetectionResult {
  final bool hasFace;
  final Face? face;
  final FaceQuality quality;
  final String message;
  final double confidence;
  final Uint8List? faceImage;

  FaceDetectionResult({
    required this.hasFace,
    this.face,
    required this.quality,
    required this.message,
    required this.confidence,
    this.faceImage,
  });
}

class FaceDetectionService extends GetxService {
  final NotificationService _notificationService = Get.find();
  late FaceDetector _faceDetector;
  
  final RxBool isProcessing = false.obs;
  final RxList<Uint8List> registeredFaces = <Uint8List>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initializeFaceDetector();
  }

  @override
  void onClose() {
    _faceDetector.close();
    super.onClose();
  }

  void _initializeFaceDetector() {
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true,
        enableLandmarks: true,
        enableContours: true,
        enableTracking: false,
        minFaceSize: 0.1,
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
  }

  Future<FaceDetectionResult> detectFace(Uint8List imageBytes) async {
    if (isProcessing.value) {
      return FaceDetectionResult(
        hasFace: false,
        quality: FaceQuality.poor,
        message: 'جاري المعالجة...',
        confidence: 0.0,
      );
    }

    try {
      isProcessing.value = true;
      
      final inputImage = InputImage.fromBytes(
        bytes: imageBytes,
        metadata:  InputImageMetadata(
          size: Size(640, 480),
          rotation: InputImageRotation.rotation0deg,
          format: InputImageFormat.nv21,
          bytesPerRow: 640,
        ),
      );

      final faces = await _faceDetector.processImage(inputImage);
      
      if (faces.isEmpty) {
        return FaceDetectionResult(
          hasFace: false,
          quality: FaceQuality.poor,
          message: 'لم يتم العثور على وجه',
          confidence: 0.0,
        );
      }

      if (faces.length > 1) {
        return FaceDetectionResult(
          hasFace: false,
          quality: FaceQuality.poor,
          message: 'يجب أن يكون وجه واحد فقط في الصورة',
          confidence: 0.0,
        );
      }

      final face = faces.first;
      final quality = _evaluateFaceQuality(face, imageBytes);
      final confidence = _calculateConfidence(face);
      
      String message = _getQualityMessage(quality);
      
      // Extract face region if quality is good enough
      Uint8List? faceImage;
      if (quality.index >= FaceQuality.fair.index) {
        faceImage = await _extractFaceRegion(imageBytes, face);
      }

      return FaceDetectionResult(
        hasFace: true,
        face: face,
        quality: quality,
        message: message,
        confidence: confidence,
        faceImage: faceImage,
      );

    } catch (e) {
      _notificationService.showError('خطأ في كشف الوجه');
      return FaceDetectionResult(
        hasFace: false,
        quality: FaceQuality.poor,
        message: 'خطأ في معالجة الصورة',
        confidence: 0.0,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  FaceQuality _evaluateFaceQuality(Face face, Uint8List imageBytes) {
    double score = 0.0;
    
    // Check face size (larger is better)
    final faceSize = face.boundingBox.width * face.boundingBox.height;
    final imageSize = imageBytes.length / 3; // Rough estimate
    final sizeRatio = faceSize / imageSize;
    
    if (sizeRatio > 0.15) score += 25;
    else if (sizeRatio > 0.10) score += 15;
    else if (sizeRatio > 0.05) score += 10;
    
    // Check head pose
    final headEulerAngleY = face.headEulerAngleY?.abs() ?? 0;
    final headEulerAngleZ = face.headEulerAngleZ?.abs() ?? 0;
    
    if (headEulerAngleY < 10 && headEulerAngleZ < 10) score += 25;
    else if (headEulerAngleY < 20 && headEulerAngleZ < 20) score += 15;
    else if (headEulerAngleY < 30 && headEulerAngleZ < 30) score += 10;
    
    // Check eye openness
    final leftEyeOpen = face.leftEyeOpenProbability ?? 0;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 0;
    
    if (leftEyeOpen > 0.8 && rightEyeOpen > 0.8) score += 25;
    else if (leftEyeOpen > 0.6 && rightEyeOpen > 0.6) score += 15;
    else if (leftEyeOpen > 0.4 && rightEyeOpen > 0.4) score += 10;
    
    // Check smile (neutral to slight smile is better for ID)
    final smilingProbability = face.smilingProbability ?? 0;
    if (smilingProbability > 0.3 && smilingProbability < 0.8) score += 25;
    else if (smilingProbability <= 0.3) score += 20;
    
    if (score >= 80) return FaceQuality.excellent;
    if (score >= 60) return FaceQuality.good;
    if (score >= 40) return FaceQuality.fair;
    return FaceQuality.poor;
  }

  double _calculateConfidence(Face face) {
    double confidence = 0.0;
    
    // Base confidence from detection
    confidence += 0.3;
    
    // Eye detection confidence
    final leftEyeOpen = face.leftEyeOpenProbability ?? 0;
    final rightEyeOpen = face.rightEyeOpenProbability ?? 0;
    confidence += (leftEyeOpen + rightEyeOpen) * 0.2;
    
    // Head pose confidence
    final headEulerAngleY = face.headEulerAngleY?.abs() ?? 90;
    final headEulerAngleZ = face.headEulerAngleZ?.abs() ?? 90;
    final poseConfidence = math.max(0, 1 - (headEulerAngleY + headEulerAngleZ) / 100);
    confidence += poseConfidence * 0.3;
    
    // Landmarks confidence
    if (face.landmarks.isNotEmpty) {
      confidence += 0.2;
    }
    
    return math.min(1.0, confidence);
  }

  String _getQualityMessage(FaceQuality quality) {
    switch (quality) {
      case FaceQuality.excellent:
        return 'جودة ممتازة! يمكن المتابعة';
      case FaceQuality.good:
        return 'جودة جيدة، يمكن المتابعة';
      case FaceQuality.fair:
        return 'جودة مقبولة، حاول تحسين الإضاءة';
      case FaceQuality.poor:
        return 'جودة ضعيفة، تأكد من الإضاءة والزاوية';
    }
  }

  Future<Uint8List?> _extractFaceRegion(Uint8List imageBytes, Face face) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;
      
      final rect = face.boundingBox;
      final padding = 20; // Add padding around face
      
      final x = math.max(0, rect.left.toInt() - padding);
      final y = math.max(0, rect.top.toInt() - padding);
      final width = math.min(
        image.width - x,
        rect.width.toInt() + (padding * 2),
      );
      final height = math.min(
        image.height - y,
        rect.height.toInt() + (padding * 2),
      );
      
      final faceImage = img.copyCrop(image, 
        x: x, y: y, width: width, height: height);
      
      // Resize to standard size for comparison
      final resizedFace = img.copyResize(faceImage, width: 200, height: 200);
      
      return Uint8List.fromList(img.encodeJpg(resizedFace, quality: 90));
    } catch (e) {
      return null;
    }
  }

  Future<bool> verifyFace(Uint8List newFaceImage, List<Uint8List> storedFaces) async {
    if (storedFaces.isEmpty) return false;
    
    try {
      // This is a simplified face comparison
      // In a real app, you'd use more sophisticated face recognition algorithms
      
      final newFaceResult = await detectFace(newFaceImage);
      if (!newFaceResult.hasFace || 
          newFaceResult.quality.index < FaceQuality.fair.index) {
        return false;
      }
      
      // Compare with stored faces
      for (final storedFace in storedFaces) {
        final similarity = await _compareFaces(newFaceImage, storedFace);
        if (similarity >= AppConfig.faceMatchThreshold) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<double> _compareFaces(Uint8List face1, Uint8List face2) async {
    // Simplified face comparison
    // In production, use proper face recognition algorithms like FaceNet
    
    try {
      final img1 = img.decodeImage(face1);
      final img2 = img.decodeImage(face2);
      
      if (img1 == null || img2 == null) return 0.0;
      
      // Resize for comparison
      final resized1 = img.copyResize(img1, width: 100, height: 100);
      final resized2 = img.copyResize(img2, width: 100, height: 100);
      
      // Simple pixel comparison (not ideal for production)
      int matchingPixels = 0;
      int totalPixels = 100 * 100;
      
      for (int y = 0; y < 100; y++) {
        for (int x = 0; x < 100; x++) {
          final pixel1 = resized1.getPixel(x, y);
          final pixel2 = resized2.getPixel(x, y);
          
          final r1 = img.getRed(pixel1);
          final g1 = img.getGreen(pixel1);
          final b1 = img.getBlue(pixel1);
          
          final r2 = img.getRed(pixel2);
          final g2 = img.getGreen(pixel2);
          final b2 = img.getBlue(pixel2);
          
          final diff = math.sqrt(
            math.pow(r1 - r2, 2) +
            math.pow(g1 - g2, 2) +
            math.pow(b1 - b2, 2)
          );
          
          if (diff < 50) matchingPixels++; // Threshold for similarity
        }
      }
      
      return matchingPixels / totalPixels;
    } catch (e) {
      return 0.0;
    }
  }

  void registerFaces(List<Uint8List> faces) {
    registeredFaces.assignAll(faces);
  }

  void clearRegisteredFaces() {
    registeredFaces.clear();
  }

  bool get hasRegisteredFaces => registeredFaces.isNotEmpty;
}