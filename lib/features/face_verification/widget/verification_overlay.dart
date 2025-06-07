import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/face_detection_service.dart';
import '../provider/face_verification_provider.dart';

class VerificationOverlay extends StatelessWidget {
  final FaceDetectionResult? detectionResult;
  final VerificationState verificationState;
  final double progress;

  const VerificationOverlay({
    super.key,
    this.detectionResult,
    required this.verificationState,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: VerificationOverlayPainter(
        detectionResult: detectionResult,
        verificationState: verificationState,
        progress: progress,
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: _buildOverlayElements(),
      ),
    );
  }

  Widget _buildOverlayElements() {
    return Stack(
      children: [
        // Main verification frame
        Center(
          child: _buildVerificationFrame(),
        ),
        
        // Progress indicators
        if (verificationState == VerificationState.verifying)
          _buildVerificationProgress(),
        
        // Success animation
        if (verificationState == VerificationState.success)
          _buildSuccessAnimation(),
      ],
    );
  }

  Widget _buildVerificationFrame() {
    final Color frameColor = _getFrameColor();
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: 300,
      height: 380,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(150),
        border: Border.all(
          color: frameColor,
          width: verificationState == VerificationState.verifying ? 6 : 4,
        ),
        boxShadow: [
          BoxShadow(
            color: frameColor.withOpacity(0.3),
            blurRadius: verificationState == VerificationState.verifying ? 30 : 15,
            spreadRadius: verificationState == VerificationState.verifying ? 5 : 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Corner guides
          ...List.generate(4, (index) => _buildCornerGuide(index, frameColor)),
          
          // Center crosshair
          Center(
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                border: Border.all(color: frameColor, width: 2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: frameColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerGuide(int index, Color color) {
    final positions = [
      const Alignment(-0.85, -0.8),  // Top-left
      const Alignment(0.85, -0.8),   // Top-right
      const Alignment(-0.85, 0.8),   // Bottom-left
      const Alignment(0.85, 0.8),    // Bottom-right
    ];

    return Align(
      alignment: positions[index],
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 25,
        height: 25,
        decoration: BoxDecoration(
          border: Border.all(
            color: color,
            width: 3,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _buildVerificationProgress() {
    return Center(
      child: FadeIn(
        child: Container(
          width: 350,
          height: 430,
          child: Stack(
            children: [
              // Circular progress indicator
              Center(
                child: SizedBox(
                  width: 350,
                  height: 430,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.accentColor,
                    ),
                  ),
                ),
              ),
              
              // Scanning lines animation
              _buildScanningLines(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScanningLines() {
    return Container(
      width: 350,
      height: 430,
      child: CustomPaint(
        painter: ScanningLinesPainter(
          progress: progress,
          color: AppTheme.accentColor,
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return Center(
      child: ZoomIn(
        duration: const Duration(milliseconds: 600),
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppTheme.successColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.successColor.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.check,
            color: Colors.white,
            size: 60,
          ),
        ),
      ),
    );
  }

  Color _getFrameColor() {
    switch (verificationState) {
      case VerificationState.idle:
        return Colors.white.withOpacity(0.6);
      case VerificationState.detecting:
        if (detectionResult?.hasFace == true) {
          return _getQualityColor(detectionResult!.quality);
        }
        return AppTheme.warningColor;
      case VerificationState.verifying:
        return AppTheme.accentColor;
      case VerificationState.success:
        return AppTheme.successColor;
      case VerificationState.failed:
        return AppTheme.errorColor;
    }
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
}

class VerificationOverlayPainter extends CustomPainter {
  final FaceDetectionResult? detectionResult;
  final VerificationState verificationState;
  final double progress;

  VerificationOverlayPainter({
    this.detectionResult,
    required this.verificationState,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw dark overlay with oval cutout
    _drawOverlay(canvas, size);
    
    // Draw face detection indicators
    if (detectionResult?.face != null) {
      _drawFaceIndicators(canvas, size);
    }
    
    // Draw alignment grid
    _drawAlignmentGrid(canvas, size);
  }

  void _drawOverlay(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Create oval cutout
    final ovalRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: 300,
      height: 380,
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(ovalRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);
  }

  void _drawFaceIndicators(Canvas canvas, Size size) {
    final face = detectionResult!.face!;
    final paint = Paint()
      ..color = _getFaceIndicatorColor()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Scale face coordinates to canvas
    final scaleX = size.width / 640;
    final scaleY = size.height / 480;

    final faceRect = Rect.fromLTWH(
      face.boundingBox.left * scaleX,
      face.boundingBox.top * scaleY,
      face.boundingBox.width * scaleX,
      face.boundingBox.height * scaleY,
    );

    // Draw face bounding box
    canvas.drawRRect(
      RRect.fromRectAndRadius(faceRect, const Radius.circular(8)),
      paint,
    );
  }

  void _drawAlignmentGrid(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 1;

    // Center lines
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      gridPaint,
    );
    
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      gridPaint,
    );
  }

  Color _getFaceIndicatorColor() {
    if (detectionResult == null || !detectionResult!.hasFace) {
      return AppTheme.errorColor;
    }

    switch (detectionResult!.quality) {
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

  @override
  bool shouldRepaint(covariant VerificationOverlayPainter oldDelegate) {
    return oldDelegate.detectionResult != detectionResult ||
           oldDelegate.verificationState != verificationState ||
           oldDelegate.progress != progress;
  }
}

class ScanningLinesPainter extends CustomPainter {
  final double progress;
  final Color color;

  ScanningLinesPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Draw scanning lines based on progress
    final lineHeight = size.height * progress;
    
    for (int i = 0; i < 5; i++) {
      final y = centerY - (size.height / 2) + (lineHeight / 5) * i;
      
      if (y <= centerY + (size.height / 2)) {
        canvas.drawLine(
          Offset(centerX - 100, y),
          Offset(centerX + 100, y),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant ScanningLinesPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}