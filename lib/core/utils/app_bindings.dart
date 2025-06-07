import 'package:get/get.dart';
import '../services/storage_service.dart';
import '../services/camera_service.dart';
import '../services/face_detection_service.dart';
import '../network/base_client.dart';
import '../utils/notification_service.dart';
import '../../features/auth/provider/auth_provider.dart';
import '../../features/face_registration/provider/face_registration_provider.dart';
import '../../features/face_verification/provider/face_verification_provider.dart';
import '../../features/main_navigation/provider/main_navigation_provider.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Core Services
    Get.put(StorageService(), permanent: true);
    Get.put(CameraService(), permanent: true);
    Get.put(FaceDetectionService(), permanent: true);
    Get.put(BaseClient(), permanent: true);
    Get.put(NotificationService(), permanent: true);
    
    // Providers
    Get.lazyPut<AuthProvider>(() => AuthProvider());
    Get.lazyPut<FaceRegistrationProvider>(() => FaceRegistrationProvider());
    Get.lazyPut<FaceVerificationProvider>(() => FaceVerificationProvider());
    Get.lazyPut<MainNavigationProvider>(() => MainNavigationProvider());
  }
}