class AppConfig {
  static const String appName = 'جامعة المستقبل';
  static const String version = '1.0.0';
  
  // API Configuration
  static const String baseUrl = 'https://your-university-api.com/api/v1';
  static const String loginEndpoint = '/auth/login';
  static const String verifyFaceEndpoint = '/auth/verify-face';
  static const String attendanceEndpoint = '/attendance';
  
  // Face Detection Settings
  static const double faceDetectionConfidence = 0.8;
  static const int maxFaceRegistrationAttempts = 3;
  static const int faceVerificationTimeout = 30; // seconds
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
  
  // Storage Keys
  static const String userDataKey = 'user_data';
  static const String faceDataKey = 'face_data';
  static const String isFirstLoginKey = 'is_first_login';
  static const String themeKey = 'theme_mode';
  
  // Face Recognition Settings
  static const int faceImageQuality = 85;
  static const int minFaceSize = 100;
  static const double faceMatchThreshold = 0.85;
}