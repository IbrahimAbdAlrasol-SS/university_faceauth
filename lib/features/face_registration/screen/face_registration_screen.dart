import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/services/face_detection_service.dart';
import '../provider/face_registration_provider.dart';
import '../widget/face_detection_overlay.dart';
import '../widget/registration_progress_indicator.dart';

class FaceRegistrationScreen extends StatelessWidget {
  const FaceRegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FaceRegistrationProvider provider = Get.put(FaceRegistrationProvider());
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldExit = await provider.onBackPressed();
          if (shouldExit) {
            Get.back();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          if (!provider.isCameraInitialized.value) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppTheme.primaryColor),
                  SizedBox(height: 20),
                  Text(
                    'جاري تهيئة الكاميرا...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              // Camera Preview
              Positioned.fill(
                child: provider.cameraController != null
                    ? CameraPreview(provider.cameraController!)
                    : const Center(
                        child: Text(
                          'الكاميرا غير متاحة',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
              ),

              // Face Detection Overlay
              Positioned.fill(
                child: FaceDetectionOverlay(
                  detectionResult: provider.currentDetectionResult.value,
                  isCapturing: provider.isCapturing.value,
                ),
              ),

              // Top Section - Header and Progress
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Header
                        FadeInDown(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    final shouldExit = await provider.onBackPressed();
                                    if (shouldExit) Get.back();
                                  },
                                  icon: const Icon(
                                    Icons.arrow_back_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'تسجيل بصمة الوجه',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Text(
                                        'التقط صورة واضحة لوجهك',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: Colors.white70,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Progress Indicator
                        SlideInDown(
                          delay: const Duration(milliseconds: 200),
                          child: RegistrationProgressIndicator(
                            currentStep: provider.currentStep.value,
                            totalSteps: provider.totalSteps,
                            capturedImages: provider.capturedImages.length,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bottom Section - Instructions and Controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.9),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Quality Status
                          Obx(() {
                            final result = provider.currentDetectionResult.value;
                            if (result != null) {
                              return SlideInUp(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getQualityColor(result.quality)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: _getQualityColor(result.quality),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getQualityIcon(result.quality),
                                        color: _getQualityColor(result.quality),
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Flexible(
                                        child: Text(
                                          result.message,
                                          style: TextStyle(
                                            color: _getQualityColor(result.quality),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }),

                          const SizedBox(height: 20),

                          // Instructions
                          FadeInUp(
                            delay: const Duration(milliseconds: 400),
                            child: Text(
                              provider.getCurrentInstruction(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Capture Button
                          FadeInUp(
                            delay: const Duration(milliseconds: 600),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Skip button (only for non-required angles)
                                if (provider.canSkipCurrentStep())
                                  CustomOutlineButton(
                                    text: 'تخطي',
                                    width: 100,
                                    height: 48,
                                    onPressed: provider.skipCurrentStep,
                                    borderColor: Colors.white70,
                                    textColor: Colors.white70,
                                  ),

                                // Capture button
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                  ),
                                  child: Material(
                                    color: provider.canCapture.value
                                        ? AppTheme.primaryColor
                                        : Colors.grey,
                                    shape: const CircleBorder(),
                                    child: InkWell(
                                      onTap: provider.canCapture.value &&
                                              !provider.isCapturing.value
                                          ? provider.captureImage
                                          : null,
                                      customBorder: const CircleBorder(),
                                      child: Center(
                                        child: provider.isCapturing.value
                                            ? const SizedBox(
                                                width: 30,
                                                height: 30,
                                                child: CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 3,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.camera_alt,
                                                color: Colors.white,
                                                size: 36,
                                              ),
                                      ),
                                    ),
                                  ),
                                ),

                                // Camera switch button
                                if (provider.hasMultipleCameras)
                                  IconButton(
                                    onPressed: provider.switchCamera,
                                    icon: const Icon(
                                      Icons.cameraswitch_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  )
                                else
                                  const SizedBox(width: 48),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Color _getQualityColor(FaceQuality quality) {
    switch (quality) {
      case FaceQuality.excellent:
        return AppTheme.successColor;
      case FaceQuality.good:
        return AppTheme.accentColor;
      case FaceQuality.fair:
        return AppTheme.warningColor;
      case FaceQuality.poor:
        return AppTheme.errorColor;
    }
  }

  IconData _getQualityIcon(FaceQuality quality) {
    switch (quality) {
      case FaceQuality.excellent:
        return Icons.check_circle;
      case FaceQuality.good:
        return Icons.thumb_up;
      case FaceQuality.fair:
        return Icons.warning;
      case FaceQuality.poor:
        return Icons.error;
    }
  }
}