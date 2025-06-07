import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../provider/main_navigation_provider.dart';
import '../../home/screen/home_screen.dart';
import '../../profile/screen/profile_screen.dart';
import '../../statistics/screen/statistics_screen.dart';
import '../../notifications/screen/notifications_screen.dart';
import '../../attendance/screen/attendance_screen.dart';

class MainNavigationScreen extends StatelessWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MainNavigationProvider provider = Get.put(MainNavigationProvider());
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await provider.onBackPressed();
        }
      },
      child: Scaffold(
        body: Obx(() => IndexedStack(
          index: provider.selectedIndex.value,
          children: const [
            ProfileScreen(),
            StatisticsScreen(),
            HomeScreen(), // Bot/Center
            AttendanceScreen(),
            NotificationsScreen(),
          ],
        )),
        
        bottomNavigationBar: _buildModernBottomNavBar(provider),
      ),
    );
  }

  Widget _buildModernBottomNavBar(MainNavigationProvider provider) {
    return Obx(() => Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Profile
              _buildNavItem(
                index: 0,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'البروفايل',
                provider: provider,
              ),
              
              // Statistics
              _buildNavItem(
                index: 1,
                icon: Icons.analytics_outlined,
                activeIcon: Icons.analytics_rounded,
                label: 'الإحصائيات',
                provider: provider,
              ),
              
              // Bot Center (Larger)
              _buildBotCenter(provider),
              
              // Attendance
              _buildNavItem(
                index: 3,
                icon: Icons.schedule_outlined,
                activeIcon: Icons.schedule_rounded,
                label: 'تسجيل الحضور',
                provider: provider,
              ),
              
              // Notifications
              _buildNavItem(
                index: 4,
                icon: Icons.notifications_outlined,
                activeIcon: Icons.notifications_rounded,
                label: 'التنبيهات',
                provider: provider,
                hasNotification: provider.hasUnreadNotifications.value,
              ),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required MainNavigationProvider provider,
    bool hasNotification = false,
  }) {
    final isSelected = provider.selectedIndex.value == index;
    
    return GestureDetector(
      onTap: () => provider.changeIndex(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    key: ValueKey(isSelected),
                    color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                    size: 24,
                  ),
                ),
                
                // Notification badge
                if (hasNotification)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.errorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                fontFamily: 'Tajawal',
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBotCenter(MainNavigationProvider provider) {
    final isSelected = provider.selectedIndex.value == 2;
    
    return GestureDetector(
      onTap: () => provider.changeIndex(2),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          gradient: isSelected 
              ? AppTheme.primaryGradient
              : LinearGradient(
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.8),
                    AppTheme.secondaryColor.withOpacity(0.8),
                  ],
                ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(isSelected ? 0.4 : 0.2),
              blurRadius: isSelected ? 15 : 8,
              spreadRadius: isSelected ? 2 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Bot Icon with animation
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              tween: Tween(begin: 0.8, end: isSelected ? 1.1 : 1.0),
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Icon(
                    Icons.smart_toy_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 2),
            
            // Bot Label
            Text(
              'بوتي',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }
}