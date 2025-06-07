import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFF),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Notifications List
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildNotificationSection('اليوم', [
                      _buildNotificationItem(
                        title: 'تذكير بامتحان',
                        subtitle: 'امتحان البرمجة المتقدمة غداً في تمام الساعة 10:00 صباحاً',
                        time: 'قبل ساعة',
                        icon: Icons.event_note_rounded,
                        color: AppTheme.warningColor,
                        isUnread: true,
                      ),
                      _buildNotificationItem(
                        title: 'تم تحديث الدرجات',
                        subtitle: 'تم رفع درجات امتحان هياكل البيانات',
                        time: 'قبل 3 ساعات',
                        icon: Icons.grade_rounded,
                        color: AppTheme.successColor,
                        isUnread: true,
                      ),
                    ]),
                    
                    const SizedBox(height: 20),
                    
                    _buildNotificationSection('أمس', [
                      _buildNotificationItem(
                        title: 'واجب جديد',
                        subtitle: 'تم إضافة واجب جديد في مادة قواعد البيانات',
                        time: 'أمس 2:30 م',
                        icon: Icons.assignment_rounded,
                        color: AppTheme.accentColor,
                      ),
                      _buildNotificationItem(
                        title: 'إلغاء محاضرة',
                        subtitle: 'تم إلغاء محاضرة الرياضيات المتقدمة لظروف طارئة',
                        time: 'أمس 10:15 ص',
                        icon: Icons.cancel_rounded,
                        color: AppTheme.errorColor,
                      ),
                    ]),
                    
                    const SizedBox(height: 20),
                    
                    _buildNotificationSection('هذا الأسبوع', [
                      _buildNotificationItem(
                        title: 'فعالية جامعية',
                        subtitle: 'ندوة حول التكنولوجيا المستقبلية يوم الأربعاء',
                        time: 'منذ 3 أيام',
                        icon: Icons.event_rounded,
                        color: AppTheme.primaryColor,
                      ),
                      _buildNotificationItem(
                        title: 'تحديث النظام',
                        subtitle: 'تم تحديث نظام إدارة التعلم الإلكتروني',
                        time: 'منذ 4 أيام',
                        icon: Icons.system_update_rounded,
                        color: AppTheme.textSecondary,
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Text(
              'الإشعارات',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            
            const Spacer(),
            
            IconButton(
              onPressed: () {
                // Mark all as read
              },
              icon: Icon(
                Icons.done_all_rounded,
                color: AppTheme.primaryColor,
                size: 28,
              ),
            ),
            
            IconButton(
              onPressed: () {
                // Settings
              },
              icon: Icon(
                Icons.settings_rounded,
                color: AppTheme.textSecondary,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection(String title, List<Widget> notifications) {
    return FadeInUp(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: notifications,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String subtitle,
    required String time,
    required IconData icon,
    required Color color,
    bool isUnread = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread ? color.withOpacity(0.02) : Colors.transparent,
        border: Border(
          left: BorderSide(
            color: isUnread ? color : Colors.transparent,
            width: 4,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(height: 6),
                
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          IconButton(
            onPressed: () {
              // More options
            },
            icon: Icon(
              Icons.more_vert_rounded,
              color: AppTheme.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}