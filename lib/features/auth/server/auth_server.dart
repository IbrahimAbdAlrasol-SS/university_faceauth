import 'package:get/get.dart';
import '../../../core/network/base_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/config/app_config.dart';

class AuthServer {
  final BaseClient _client = Get.find();

  Future<ApiResponse<Map<String, dynamic>>> login(
    Map<String, dynamic> loginData,
  ) async {
    // Simulate API call for demo
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock successful login response
    final mockResponse = {
      'id': '1',
      'university_id': loginData['university_id'],
      'name': 'أحمد محمد علي',
      'email': 'ahmed.ali@university.edu',
      'phone': '+966501234567',
      'department': 'علوم الحاسب',
      'college': 'كلية الحاسبات وتقنية المعلومات',
      'profile_image': null,
      'token': 'mock_jwt_token_here',
      'created_at': '2024-01-01T00:00:00Z',
      'updated_at': '2024-01-01T00:00:00Z',
    };
    
    return ApiResponse.success(mockResponse);
    
    // Real API call would be:
    // return await _client.post<Map<String, dynamic>>(
    //   AppConfig.loginEndpoint,
    //   data: loginData,
    // );
  }

  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    return const ApiResponse.success({'message': 'Logged out successfully'});
    
    // Real API call would be:
    // return await _client.post<Map<String, dynamic>>('/auth/logout');
  }

  Future<ApiResponse<Map<String, dynamic>>> forgotPassword(
    Map<String, dynamic> data,
  ) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    return const ApiResponse.success({
      'message': 'Password reset link sent successfully'
    });
    
    // Real API call would be:
    // return await _client.post<Map<String, dynamic>>(
    //   '/auth/forgot-password',
    //   data: data,
    // );
  }

  Future<ApiResponse<Map<String, dynamic>>> refreshToken() async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));
    
    return const ApiResponse.success({
      'token': 'new_mock_jwt_token_here',
      'expires_in': 3600,
    });
    
    // Real API call would be:
    // return await _client.post<Map<String, dynamic>>('/auth/refresh');
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyFace(
    Map<String, dynamic> faceData,
  ) async {
    // Simulate face verification API call
    await Future.delayed(const Duration(seconds: 3));
    
    // Mock response based on face verification
    return const ApiResponse.success({
      'verified': true,
      'confidence': 0.95,
      'message': 'Face verification successful',
    });
    
    // Real API call would be:
    // return await _client.post<Map<String, dynamic>>(
    //   AppConfig.verifyFaceEndpoint,
    //   data: faceData,
    // );
  }

  Future<ApiResponse<Map<String, dynamic>>> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    return ApiResponse.success(profileData);
    
    // Real API call would be:
    // return await _client.put<Map<String, dynamic>>(
    //   '/user/profile',
    //   data: profileData,
    // );
  }

  Future<ApiResponse<Map<String, dynamic>>> changePassword(
    Map<String, dynamic> passwordData,
  ) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    return const ApiResponse.success({
      'message': 'Password changed successfully'
    });
    
    // Real API call would be:
    // return await _client.post<Map<String, dynamic>>(
    //   '/auth/change-password',
    //   data: passwordData,
    // );
  }
}