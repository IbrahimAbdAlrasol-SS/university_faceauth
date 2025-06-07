import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(),
                
                const SizedBox(height: 30),
                
                // Quick Attendance
                _buildQuickAttendance(),
                
                const SizedBox(height: 30),
                
                // Today's Schedule
                _buildTodaySchedule(),
                
                const SizedBox(height: 30),
                
                // Attendance History
                _buildAttendanceHistory(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تسجيل الحضور',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'سجل حضورك وتابع جدولك اليومي',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAttendance() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.fingerprint_rounded,
              color: Colors.white,
              size: 60,
            ),
            
            const SizedBox(height: 20),
            
            Text(
              'تسجيل حضور سريع',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'اضغط للتسجيل باستخدام بصمة الوجه',
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 24),
            
            CustomButton(
              text: 'تسجيل الحضور الآن',
              onPressed: () {
                // Navigate to face verification for attendance
              },
              backgroundColor: Colors.white,
              textColor: AppTheme.primaryColor,
              icon: Icons.camera_alt_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodaySchedule() {
    return SlideInLeft(
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'جدول اليوم',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          
          const SizedBox(height: 16),
          
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
              children: [
                _buildScheduleItem(
                  subject: 'البرمجة المتقدمة',
                  time: '08:00 - 09:30',
                  room: 'قاعة 101',
                  status: 'completed',
                ),
                _buildScheduleItem(
                  subject: 'هياكل البيانات',
                  time: '10:00 - 11:30',
                  room: 'قاعة 205',
                  status: 'current',
                ),
                _buildScheduleItem(
                  subject: 'قواعد البيانات',
                  time: '12:00 - 13:30',
                  room: 'قاعة 103',
                  status: 'upcoming',
                ),
                _buildScheduleItem(
                  subject: 'الرياضيات المتقدمة',
                  time: '14:00 - 15:30',
                  room: 'قاعة 301',
                  status: 'upcoming',
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem({
    required String subject,
    required String time,
    required String room,
    required String status,
    bool isLast = false,
  }) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    
    switch (status) {
      case 'completed':
        statusColor = AppTheme.successColor;
        statusIcon = Icons.check_circle;
        statusText = 'مكتمل';
        break;
      case 'current':
        statusColor = AppTheme.accentColor;
        statusIcon = Icons.play_circle_filled;
        statusText = 'جاري الآن';
        break;
      case 'upcoming':
        statusColor = AppTheme.warningColor;
        statusIcon = Icons.schedule;
        statusText = 'قادم';
        break;
      default:
        statusColor = AppTheme.textSecondary;
        statusIcon = Icons.circle;
        statusText = '';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              statusIcon,
              color: statusColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      room,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceHistory() {
    return SlideInRight(
      delay: const Duration(milliseconds: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'سجل الحضور',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              
              TextButton(
                onPressed: () {},
                child: Text(
                  'عرض التفاصيل',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
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
              children: [
                _buildHistoryItem(
                  date: 'اليوم',
                  attended: 2,
                  total: 4,
                  percentage: 50,
                ),
                _buildHistoryItem(
                  date: 'أمس',
                  attended: 3,
                  total: 3,
                  percentage: 100,
                ),
                _buildHistoryItem(
                  date: 'الأحد',
                  attended: 4,
                  total: 4,
                  percentage: 100,
                ),
                _buildHistoryItem(
                  date: 'السبت',
                  attended: 2,
                  total: 4,
                  percentage: 50,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem({
    required String date,
    required int attended,
    required int total,
    required int percentage,
    bool isLast = false,
  }) {
    final Color percentageColor = percentage >= 80 
        ? AppTheme.successColor
        : percentage >= 60
            ? AppTheme.warningColor
            : AppTheme.errorColor;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(
          bottom: BorderSide(
            color: Colors.grey.shade100,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  '$attended من $total محاضرات',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: percentageColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$percentage%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: percentageColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}