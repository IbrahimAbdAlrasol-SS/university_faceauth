import 'dart:convert';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:university_face_auth/core/config/config_App.dart';

class StorageService extends GetxService {
  late GetStorage _storage;

  @override
  void onInit() {
    super.onInit();
    _storage = GetStorage();
  }

  // User Data Management
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _storage.write(AppConfig.userDataKey, userData);
  }

  Map<String, dynamic>? getUserData() {
    return _storage.read<Map<String, dynamic>>(AppConfig.userDataKey);
  }

  Future<void> clearUserData() async {
    await _storage.remove(AppConfig.userDataKey);
  }

  // Face Data Management
  Future<void> saveFaceData(List<Uint8List> faceImages) async {
    final encodedImages = faceImages.map((img) => base64Encode(img)).toList();
    await _storage.write(AppConfig.faceDataKey, encodedImages);
  }

  List<Uint8List>? getFaceData() {
    final encodedImages = _storage.read<List<dynamic>>(AppConfig.faceDataKey);
    if (encodedImages == null) return null;
    
    return encodedImages
        .map((encoded) => base64Decode(encoded.toString()))
        .toList();
  }

  Future<void> clearFaceData() async {
    await _storage.remove(AppConfig.faceDataKey);
  }

  bool get hasFaceData => _storage.hasData(AppConfig.faceDataKey);

  // First Login Management
  Future<void> setFirstLogin(bool isFirst) async {
    await _storage.write(AppConfig.isFirstLoginKey, isFirst);
  }

  bool get isFirstLogin => _storage.read(AppConfig.isFirstLoginKey) ?? true;

  // Token Management
  Future<void> saveToken(String token) async {
    await _storage.write('auth_token', token);
  }

  String? getToken() {
    return _storage.read<String>('auth_token');
  }

  Future<void> clearToken() async {
    await _storage.remove('auth_token');
  }

  bool get hasToken => _storage.hasData('auth_token');

  // Theme Management
  Future<void> saveThemeMode(String themeMode) async {
    await _storage.write(AppConfig.themeKey, themeMode);
  }

  String get themeMode => _storage.read(AppConfig.themeKey) ?? 'light';

  // Language Management
  Future<void> saveLanguage(String languageCode) async {
    await _storage.write('language', languageCode);
  }

  String get language => _storage.read('language') ?? 'ar';

  // Biometric Settings
  Future<void> saveBiometricEnabled(bool enabled) async {
    await _storage.write('biometric_enabled', enabled);
  }

  bool get isBiometricEnabled => _storage.read('biometric_enabled') ?? false;

  // App Settings
  Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await _storage.write('app_settings', settings);
  }

  Map<String, dynamic> get appSettings => 
      _storage.read<Map<String, dynamic>>('app_settings') ?? {};

  // Clear All Data
  Future<void> clearAllData() async {
    await _storage.erase();
  }

  // Check if user is logged in
  bool get isLoggedIn => hasToken && getUserData() != null;

  // Check if app is configured
  bool get isAppConfigured => isLoggedIn && hasFaceData;

  // Generic methods for any data
  Future<void> write<T>(String key, T value) async {
    await _storage.write(key, value);
  }

  T? read<T>(String key) {
    return _storage.read<T>(key);
  }

  Future<void> remove(String key) async {
    await _storage.remove(key);
  }

  bool hasData(String key) {
    return _storage.hasData(key);
  }
}