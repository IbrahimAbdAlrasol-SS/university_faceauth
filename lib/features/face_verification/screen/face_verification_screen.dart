import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:animate_do/animate_do.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/services/face_detection_service.dart';
import '../../provider/face_verification_provider.dart';
import '../../widget/verification_overlay.dart';

class FaceVerificationScreen extends StatelessWidget {
  const FaceVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final FaceVerificationProvider provider = Get.put(FaceVerificationProvider());
    
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          if (provider.verificationState.value == VerificationState.success) {
            return _buildSuccessView(provider);
          }

          if (!provider.isCameraInitialized.value) {
            return _buildLoadingView();
          }

          return _buildCameraView(provider);
        }),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),
            Text(
              'جاري تهيئة نظام التحقق...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraView(FaceVerificationProvider provider) {
    return Stack(
      children: [
        // Camera Preview
        Positioned.fill(
          child: provider.cameraController != null
              ? CameraPreview(provider.cameraController!)
              : Container(
                  color: Colors.black,
                  child: const Center(
                    child: Text(
                      'الكاميرا غير متاحة',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
        ),

        // Verification Overlay
        Positioned.fill(
          child: VerificationOverlay(
            detectionResult: provider.currentDetectionResult.value,
            verificationState: provider.verificationState.value,
            progress: provider.verificationProgress.value,
          ),
        ),

        // Top Section
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: _buildTopSection(provider),
        ),

        // Bottom Section
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomSection(provider),
        ),
      ],
    );
  }

  Widget _buildTopSection(FaceVerificationProvider provider) {
    return Container(
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
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Header
              FadeInDown(
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(
                        Icons.face_retouching_natural,
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
                            'التحقق من الهوية',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            'انظر إلى الكاميرا للتحقق',
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

              const SizedBox(height: 20),

              // User Info
              Obx(() {
                if (provider.currentUser.value != null) {
                  return SlideInDown(
                    delay: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              provider.currentUser.value!.initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.currentUser.value!.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'المعرف: ${provider.currentUser.value!.universityId}',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(FaceVerificationProvider provider) {
    return Container(
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
              // Status Message
              Obx(() {
                final result = provider.currentDetectionResult.value;
                final state = provider.verificationState.value;
                
                String message = 'ضع وجهك داخل الإطار';
                Color messageColor = Colors.white;
                IconData messageIcon = Icons.face;

                if (state == VerificationState.verifying) {
                  message = 'جاري التحقق من الهوية...';
                  messageColor = AppTheme.accentColor;
                  messageIcon = Icons.verified_user;
                } else if (state == VerificationState.failed) {
                  message = 'فشل في التحقق، حاول مرة أخرى';
                  messageColor = AppTheme.errorColor;
                  messageIcon = Icons.error;
                } else if (result != null) {
                  message = result.message;
                  messageColor = _getResultColor(result.quality);
                  messageIcon = _getResultIcon(result.quality);
                }

                return FadeInUp(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: messageColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: messageColor,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          messageIcon,
                          color: messageColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            message,
                            style: TextStyle(
                              color: messageColor,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 30),

              // Action Buttons
              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Row(
                  children: [
                    // Skip verification (if allowed)
                    Expanded(
                      child: CustomOutlineButton(
                        text: 'تسجيل الدخول بكلمة المرور',
                        onPressed: provider.skipVerification,
                        borderColor: Colors.white70,
                        textColor: Colors.white70,
                        height: 48,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Manual verification trigger
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: Material(
                        color: provider.verificationState.value == VerificationState.verifying
                            ? AppTheme.accentColor
                            : AppTheme.primaryColor,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: provider.verificationState.value == VerificationState.verifying
                              ? null
                              : provider.startManualVerification,
                          customBorder: const CircleBorder(),
                          child: Center(
                            child: provider.verificationState.value == VerificationState.verifying
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.verified_user,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessView(FaceVerificationProvider provider) {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppTheme.primaryGradient,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success Animation
            FadeInDown(
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: AppTheme.successColor,
                  size: 80,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Success Message
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Column(
                children: [
                  Text(
                    'تم التحقق بنجاح!',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Text(
                    'مرحباً بك في التطبيق',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 60),

            // Continue Button
            FadeInUp(
              delay: const Duration(milliseconds: 600),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: CustomButton(
                  text: 'المتابعة',
                  onPressed: provider.navigateToMain,
                  icon: Icons.arrow_forward_rounded,
                  backgroundColor: Colors.white,
                  textColor: AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getResultColor(FaceQuality quality) {
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

  IconData _getResultIcon(FaceQuality quality) {
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