import 'package:get/get.dart';
import '../../features/splash/screen/splash_screen.dart';
import '../../features/auth/screen/login_screen.dart';
import '../../features/face_registration/screen/face_registration_screen.dart';
import '../../features/face_verification/screen/face_verification_screen.dart';
import '../../features/main_navigation/screen/main_navigation_screen.dart';
import '../../features/profile/screen/profile_screen.dart';
import '../../features/statistics/screen/statistics_screen.dart';
import '../../features/notifications/screen/notifications_screen.dart';
import '../../features/home/screen/home_screen.dart';
import '../../features/attendance/screen/attendance_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String faceRegistration = '/face-registration';
  static const String faceVerification = '/face-verification';
  static const String mainNavigation = '/main-navigation';
  static const String profile = '/profile';
  static const String statistics = '/statistics';
  static const String notifications = '/notifications';
  static const String home = '/home';
  static const String attendance = '/attendance';

  static List<GetPage> get pages => [
    GetPage(
      name: splash,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    GetPage(
      name: faceRegistration,
      page: () => const FaceRegistrationScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    
    GetPage(
      name: faceVerification,
      page: () => const FaceVerificationScreen(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    
    GetPage(
      name: mainNavigation,
      page: () => const MainNavigationScreen(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 500),
    ),
    
    GetPage(
      name: profile,
      page: () => const ProfileScreen(),
      transition: Transition.cupertino,
    ),
    
    GetPage(
      name: statistics,
      page: () => const StatisticsScreen(),
      transition: Transition.cupertino,
    ),
    
    GetPage(
      name: notifications,
      page: () => const NotificationsScreen(),
      transition: Transition.cupertino,
    ),
    
    GetPage(
      name: home,
      page: () => const HomeScreen(),
      transition: Transition.cupertino,
    ),
    
    GetPage(
      name: attendance,
      page: () => const AttendanceScreen(),
      transition: Transition.cupertino,
    ),
  ];
}