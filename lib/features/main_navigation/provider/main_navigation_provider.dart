import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/utils/notification_service.dart';
import '../../../core/routes/app_routes.dart';

class MainNavigationProvider extends GetxController {
  final NotificationService _notificationService = Get.find();

  // Reactive Variables
  final RxInt selectedIndex = 2.obs; // Start with Bot/Home
  final RxBool hasUnreadNotifications = false.obs;
  final RxString currentPageTitle = 'الرئيسية'.obs;

  // Page titles
  final List<String> pageTitles = [
    'البروفايل',
    'الإحصائيات', 
    'الرئيسية',
    'تسجيل الحضور',
    'التنبيهات',
  ];

  @override
  void onInit() {
    super.onInit();
    _updatePageTitle();
    _loadNotificationStatus();
    
    // Listen to index changes
    ever(selectedIndex, (_) {
      _updatePageTitle();
      _handlePageChange();
    });
  }

  void changeIndex(int index) {
    if (index == selectedIndex.value) {
      // Double tap on same tab - scroll to top or refresh
      _handleDoubleTap(index);
      return;
    }

    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Animate page change
    selectedIndex.value = index;
  }

  void _updatePageTitle() {
    if (selectedIndex.value >= 0 && selectedIndex.value < pageTitles.length) {
      currentPageTitle.value = pageTitles[selectedIndex.value];
    }
  }

  void _handlePageChange() {
    // Handle specific page changes
    switch (selectedIndex.value) {
      case 0: // Profile
        _onProfilePage();
        break;
      case 1: // Statistics
        _onStatisticsPage();
        break;
      case 2: // Home/Bot
        _onHomePage();
        break;
      case 3: // Attendance
        _onAttendancePage();
        break;
      case 4: // Notifications
        _onNotificationsPage();
        break;
    }
  }

  void _handleDoubleTap(int index) {
    // Handle double tap actions for each page
    switch (index) {
      case 0: // Profile
        _refreshProfile();
        break;
      case 1: // Statistics
        _refreshStatistics();
        break;
      case 2: // Home/Bot
        _refreshHome();
        break;
      case 3: // Attendance
        _refreshAttendance();
        break;
      case 4: // Notifications
        _refreshNotifications();
        break;
    }
  }

  // Page specific handlers
  void _onProfilePage() {
    // Handle profile page logic
  }

  void _onStatisticsPage() {
    // Handle statistics page logic
  }

  void _onHomePage() {
    // Handle home page logic
  }

  void _onAttendancePage() {
    // Handle attendance page logic
  }

  void _onNotificationsPage() {
    // Mark notifications as read when viewed
    if (hasUnreadNotifications.value) {
      hasUnreadNotifications.value = false;
      _saveNotificationStatus();
    }
  }

  // Refresh handlers
  void _refreshProfile() {
    HapticFeedback.mediumImpact();
    // Refresh profile data
  }

  void _refreshStatistics() {
    HapticFeedback.mediumImpact();
    // Refresh statistics
  }

  void _refreshHome() {
    HapticFeedback.mediumImpact();
    // Refresh home/bot
  }

  void _refreshAttendance() {
    HapticFeedback.mediumImpact();
    // Refresh attendance
  }

  void _refreshNotifications() {
    HapticFeedback.mediumImpact();
    // Refresh notifications
  }

  // Notification management
  void addNotification() {
    hasUnreadNotifications.value = true;
    _saveNotificationStatus();
  }

  void clearNotifications() {
    hasUnreadNotifications.value = false;
    _saveNotificationStatus();
  }

  void _loadNotificationStatus() {
    // Load from storage
    // hasUnreadNotifications.value = _storageService.read('has_unread') ?? false;
  }

  void _saveNotificationStatus() {
    // Save to storage
    // _storageService.write('has_unread', hasUnreadNotifications.value);
  }

  // Navigation helpers
  void navigateToPage(int index) {
    if (index >= 0 && index < pageTitles.length) {
      changeIndex(index);
    }
  }

  void navigateToHome() {
    changeIndex(2);
  }

  void navigateToProfile() {
    changeIndex(0);
  }

  void navigateToNotifications() {
    changeIndex(4);
  }

  // Back button handler
  Future<void> onBackPressed() async {
    if (selectedIndex.value != 2) {
      // If not on home, go to home
      changeIndex(2);
    } else {
      // If on home, show exit dialog
      final shouldExit = await _notificationService.showConfirmDialog(
        title: 'خروج من التطبيق',
        message: 'هل تريد الخروج من التطبيق؟',
        confirmText: 'خروج',
        cancelText: 'إلغاء',
      );

      if (shouldExit == true) {
        SystemNavigator.pop();
      }
    }
  }

  // Quick actions
  void quickAttendance() {
    _notificationService.showInfo('جاري تسجيل الحضور...');
    // Navigate to attendance or trigger quick attendance
    changeIndex(3);
  }

  void quickNotification() {
    changeIndex(4);
  }

  // Bot interactions
  void openBotChat() {
    // Open bot chat interface
    _notificationService.showInfo('مرحباً! كيف يمكنني مساعدتك؟');
  }

  void askBotQuestion(String question) {
    // Handle bot questions
    _notificationService.showInfo('جاري معالجة سؤالك...');
  }

  // Getters
  bool get isOnHomePage => selectedIndex.value == 2;
  bool get isOnProfilePage => selectedIndex.value == 0;
  bool get isOnNotificationsPage => selectedIndex.value == 4;
  
  String get currentTitle => currentPageTitle.value;
  
  int get currentIndex => selectedIndex.value;
}