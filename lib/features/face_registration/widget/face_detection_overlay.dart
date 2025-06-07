import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/face_detection_service.dart';

class FaceDetectionOverlay extends StatelessWidget {
  final FaceDetectionResult? detectionResult;
  final bool isCapturing;

  const FaceDetectionOverlay({
    super.key,
    this.detectionResult,
    required this.isCapturing,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: FaceOverlayPainter(
        detectionResult: detectionResult,
        isCapturing: isCapturing,
      ),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: _buildGuideElements(context),
      ),
    );
  }

  Widget _buildGuideElements(BuildContext context) {
    return Stack(
      children: [
        // Face guide circle
        Center(
          child: _buildFaceGuide(),
        ),
        
        // Capture animation
        if (isCapturing)
          FadeIn(
            duration: const Duration(milliseconds: 300),
            child: Container(
              color: Colors.white.withOpacity(0.3),
              child: const Center(
                child: Icon(
                  Icons.camera_alt,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFaceGuide() {
    final Color guideColor = _getGuideColor();
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 280,
      height: 350,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(140),
        border: Border.all(
          color: guideColor,
          width: 4,
        ),
        boxShadow: [
          BoxShadow(
            color: guideColor.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Corner guides
          ...List.generate(4, (index) => _buildCornerGuide(index, guideColor)),
          
          // Center guide
          Center(
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: guideColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerGuide(int index, Color color) {
    final positions = [
      // Top-left
      const Alignment(-0.8, -0.8),
      // Top-right
      const Alignment(0.8, -0.8),
      // Bottom-left
      const Alignment(-0.8, 0.8),
      // Bottom-right
      const Alignment(0.8, 0.8),
    ];

    return Align(
      alignment: positions[index],
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 3),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Color _getGuideColor() {
    if (detectionResult == null) {
      return Colors.white.withOpacity(0.5);
    }

    if (!detectionResult!.hasFace) {
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
}

class FaceOverlayPainter extends CustomPainter {
  final FaceDetectionResult? detectionResult;
  final bool isCapturing;

  FaceOverlayPainter({
    this.detectionResult,
    required this.isCapturing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw dark overlay with face cutout
    _drawOverlay(canvas, size);
    
    // Draw face detection indicators if face is found
    if (detectionResult?.face != null) {
      _drawFaceIndicators(canvas, size);
    }
    
    // Draw grid lines for alignment
    _drawGridLines(canvas, size);
  }

  void _drawOverlay(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Create oval cutout for face
    final ovalRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: 280,
      height: 350,
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
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Scale face bounding box to canvas size
    final scaleX = size.width / 640; // Assuming camera preview is 640 wide
    final scaleY = size.height / 480; // Assuming camera preview is 480 high

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

    // Draw facial landmarks if available
    _drawLandmarks(canvas, face, scaleX, scaleY);
  }

  void _drawLandmarks(Canvas canvas, face, double scaleX, double scaleY) {
    final landmarkPaint = Paint()
      ..color = _getFaceIndicatorColor()
      ..style = PaintingStyle.fill;

    // Draw key landmarks
    final landmarks = face.landmarks;
    for (final landmark in landmarks.values) {
      if (landmark != null) {
        canvas.drawCircle(
          Offset(
            landmark.x * scaleX,
            landmark.y * scaleY,
          ),
          3,
          landmarkPaint,
        );
      }
    }
  }

  void _drawGridLines(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1;

    // Vertical center line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      gridPaint,
    );

    // Horizontal center line
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      gridPaint,
    );

    // Rule of thirds lines
    final thirdWidth = size.width / 3;
    final thirdHeight = size.height / 3;

    // Vertical thirds
    canvas.drawLine(
      Offset(thirdWidth, 0),
      Offset(thirdWidth, size.height),
      gridPaint,
    );
    canvas.drawLine(
      Offset(thirdWidth * 2, 0),
      Offset(thirdWidth * 2, size.height),
      gridPaint,
    );

    // Horizontal thirds
    canvas.drawLine(
      Offset(0, thirdHeight),
      Offset(size.width, thirdHeight),
      gridPaint,
    );
    canvas.drawLine(
      Offset(0, thirdHeight * 2),
      Offset(size.width, thirdHeight * 2),
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
  bool shouldRepaint(covariant FaceOverlayPainter oldDelegate) {
    return oldDelegate.detectionResult != detectionResult ||
           oldDelegate.isCapturing != isCapturing;
  }
}