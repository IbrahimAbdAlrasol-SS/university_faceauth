import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../provider/face_registration_provider.dart';

class RegistrationProgressIndicator extends StatelessWidget {
  final RegistrationStep currentStep;
  final int totalSteps;
  final int capturedImages;

  const RegistrationProgressIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.capturedImages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Progress Text
          FadeInDown(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الخطوة ${currentStep.index + 1} من $totalSteps',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$capturedImages/$totalSteps',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Progress Bar
          SlideInLeft(
            delay: const Duration(milliseconds: 200),
            child: Column(
              children: [
                // Linear Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: capturedImages / totalSteps,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.accentColor,
                    ),
                    minHeight: 8,
                  ),
                ),

                const SizedBox(height: 16),

                // Step Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    totalSteps,
                    (index) => _buildStepIndicator(index),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Current Step Name
          FadeInUp(
            delay: const Duration(milliseconds: 400),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 1,
                ),
              ),
              child: Text(
                _getStepName(currentStep),
                style: TextStyle(
                  color: AppTheme.accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int index) {
    final isCompleted = index < capturedImages;
    final isCurrent = index == currentStep.index;
    final step = RegistrationStep.values[index];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: isCompleted
            ? AppTheme.successColor
            : isCurrent
                ? AppTheme.primaryColor
                : Colors.white.withOpacity(0.2),
        shape: BoxShape.circle,
        border: Border.all(
          color: isCompleted
              ? AppTheme.successColor
              : isCurrent
                  ? AppTheme.primaryColor
                  : Colors.white.withOpacity(0.4),
          width: 2,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Center(
        child: isCompleted
            ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 24,
              )
            : Icon(
                _getStepIcon(step),
                color: isCurrent ? Colors.white : Colors.white54,
                size: 20,
              ),
      ),
    );
  }

  String _getStepName(RegistrationStep step) {
    switch (step) {
      case RegistrationStep.front:
        return 'المواجهة';
      case RegistrationStep.leftProfile:
        return 'الجانب الأيسر';
      case RegistrationStep.rightProfile:
        return 'الجانب الأيمن';
      case RegistrationStep.lookingUp:
        return 'النظر للأعلى';
      case RegistrationStep.lookingDown:
        return 'النظر للأسفل';
    }
  }

  IconData _getStepIcon(RegistrationStep step) {
    switch (step) {
      case RegistrationStep.front:
        return Icons.face;
      case RegistrationStep.leftProfile:
        return Icons.keyboard_arrow_left;
      case RegistrationStep.rightProfile:
        return Icons.keyboard_arrow_right;
      case RegistrationStep.lookingUp:
        return Icons.keyboard_arrow_up;
      case RegistrationStep.lookingDown:
        return Icons.keyboard_arrow_down;
    }
  }
}