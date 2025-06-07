import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../provider/auth_provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthProvider authProvider = Get.put(AuthProvider());
    
    return PopScope(
      canPop: false,
      child: Scaffold(
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
                // Header Section
                Expanded(
                  flex: 2,
                  child: FadeInDown(
                    duration: const Duration(milliseconds: 600),
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              size: 40,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          
                          const SizedBox(height: 24),
                          
                          Text(
                            'مرحباً بك',
                            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            'سجل دخولك للمتابعة',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Form Section
                Expanded(
                  flex: 3,
                  child: SlideInUp(
                    duration: const Duration(milliseconds: 800),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 20),
                          ),
                        ],
                      ),
                      child: Form(
                        key: authProvider.formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'تسجيل الدخول',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // University ID Field
                            FadeInLeft(
                              delay: const Duration(milliseconds: 200),
                              child: CustomTextField(
                                controller: authProvider.universityIdController,
                                label: 'المعرف الجامعي',
                                hintText: '123456789',
                                prefixIcon: Icons.school,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ],
                                validator: authProvider.validateUniversityId,
                              ),
                            ),
                            
                            const SizedBox(height: 20),
                            
                            // Password Field
                            FadeInRight(
                              delay: const Duration(milliseconds: 400),
                              child: Obx(() => CustomTextField(
                                controller: authProvider.passwordController,
                                label: 'كلمة المرور',
                                hintText: '••••••••',
                                prefixIcon: Icons.lock,
                                isPassword: true,
                                obscureText: authProvider.isPasswordHidden.value,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    authProvider.isPasswordHidden.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppTheme.textSecondary,
                                  ),
                                  onPressed: authProvider.togglePasswordVisibility,
                                ),
                                validator: authProvider.validatePassword,
                              )),
                            ),
                            
                            const SizedBox(height: 32),
                            
                            // Login Button
                            FadeInUp(
                              delay: const Duration(milliseconds: 600),
                              child: Obx(() => CustomButton(
                                text: 'تسجيل الدخول',
                                onPressed: authProvider.isLoading.value
                                    ? null
                                    : authProvider.login,
                                isLoading: authProvider.isLoading.value,
                                icon: Icons.login_rounded,
                              )),
                            ),
                            
                            const SizedBox(height: 24),
                            
                            // Forgot Password
                            FadeInUp(
                              delay: const Duration(milliseconds: 800),
                              child: TextButton(
                                onPressed: authProvider.forgotPassword,
                                child: Text(
                                  'نسيت كلمة المرور؟',
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}