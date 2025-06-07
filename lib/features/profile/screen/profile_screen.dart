import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../auth/provider/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Get.find();
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor,
              AppTheme.secondaryColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),
              
              // Profile Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Profile Info
                        _buildProfileInfo(authProvider),
                        
                        const SizedBox(height: 30),
                        
                        // Settings
                        _buildSettingsSection(),
                        
                        const SizedBox(height: 30),
                        
                        // Logout Button
                        _buildLogoutButton(authProvider),
                      ],
                    ),
                  ),
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Text(
              'البروفايل الشخصي',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            
            const Spacer(),
            
            IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(AuthProvider authProvider) {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Obx(() => Center(
              child: Text(
                authProvider.currentUser.value?.initials ?? 'M',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )),
          ),
          
          const SizedBox(height: 20),
          
          // Name
          Obx(() => Text(
            authProvider.currentUser.value?.name ?? 'المستخدم',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          )),
          
          const SizedBox(height: 8),
          
          // University ID
          Obx(() => Text(
            'المعرف الجامعي: ${authProvider.currentUser.value?.universityId ?? ''}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          )),
          
          const SizedBox(height: 20),
          
          // Info Cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  title: 'الكلية',
                  value: authProvider.currentUser.value?.college ?? 'غير محدد',
                  icon: Icons.school_rounded,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: _buildInfoCard(
                  title: 'القسم',
                  value: authProvider.currentUser.value?.department ?? 'غير محدد',
                  icon: Icons.category_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 24,
          ),
          
          const SizedBox(height: 8),
          
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return SlideInLeft(
      delay: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الإعدادات',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildSettingItem(
            icon: Icons.face_rounded,
            title: 'إعدادات بصمة الوجه',
            subtitle: 'إدارة بيانات التحقق من الهوية',
            onTap: () {},
          ),
          
          _buildSettingItem(
            icon: Icons.notifications_rounded,
            title: 'الإشعارات',
            subtitle: 'إدارة إعدادات التنبيهات',
            onTap: () {},
          ),
          
          _buildSettingItem(
            icon: Icons.security_rounded,
            title: 'الأمان والخصوصية',
            subtitle: 'كلمة المرور وإعدادات الأمان',
            onTap: () {},
          ),
          
          _buildSettingItem(
            icon: Icons.language_rounded,
            title: 'اللغة',
            subtitle: 'العربية',
            onTap: () {},
          ),
          
          _buildSettingItem(
            icon: Icons.help_rounded,
            title: 'المساعدة والدعم',
            subtitle: 'الأسئلة الشائعة وتواصل معنا',
            onTap: () {},
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppTheme.textSecondary,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildLogoutButton(AuthProvider authProvider) {
    return FadeInUp(
      delay: const Duration(milliseconds: 600),
      child: Obx(() => CustomButton(
        text: 'تسجيل الخروج',
        onPressed: authProvider.logout,
        isLoading: authProvider.isLoading.value,
        icon: Icons.logout_rounded,
        backgroundColor: AppTheme.errorColor,
      )),
    );
  }
}