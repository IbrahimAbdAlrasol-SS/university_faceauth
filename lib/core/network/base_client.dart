import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:get/get.dart' as getx;
import 'package:university_face_auth/core/config/config_App.dart';
import '../utils/notification_service.dart';
import 'api_response.dart';
import 'api_exceptions.dart';

class BaseClient extends getx.GetxService {
  late Dio _dio;
  final Logger _logger = Logger();
  final NotificationService _notificationService = getx.Get.find();

  @override
  void onInit() {
    super.onInit();
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Language': 'ar',
      },
    ));

    _dio.interceptors.addAll([
      _AuthInterceptor(),
      _LoggingInterceptor(_logger),
      _ErrorInterceptor(_notificationService),
    ]);
  }

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic)? fromJson,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse<T>(response, fromJson);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  ApiResponse<T> _handleResponse<T>(
    Response response,
    T Function(dynamic)? fromJson,
  ) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      final data = response.data;
      
      if (fromJson != null && data != null) {
        return ApiResponse.success(fromJson(data));
      }
      
      return ApiResponse.success(data as T);
    } else {
      throw NetworkException(
        message: response.statusMessage ?? 'Unknown error',
        statusCode: response.statusCode!,
      );
    }
  }

  ApiResponse<T> _handleError<T>(dynamic error) {
    _logger.e('API Error: $error');
    
    if (error is DioException) {
      return ApiResponse.error(_mapDioException(error));
    } else if (error is ApiException) {
      return ApiResponse.error(error);
    } else {
      return ApiResponse.error(
        ApiException(message: 'حدث خطأ غير متوقع'),
      );
    }
  }

  ApiException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('انتهت مهلة الاتصال');
      
      case DioExceptionType.connectionError:
        return NetworkException('تأكد من اتصال الإنترنت');
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final message = error.response?.data?['message'] ?? 'خطأ من الخادم';
        
        if (statusCode == 401) {
          return UnauthorizedException('انتهت صلاحية الجلسة');
        } else if (statusCode == 404) {
          return NotFoundException('الصفحة غير موجودة');
        } else if (statusCode >= 500) {
          return ServerException('خطأ في الخادم');
        }
        
        return ApiException(message: message, statusCode: statusCode);
      
      default:
        return ApiException(message: 'حدث خطأ غير متوقع');
    }
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add auth token if available
    // final token = StorageService.getToken();
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }
    
    handler.next(options);
  }
}

class _LoggingInterceptor extends Interceptor {
  final Logger logger;

  _LoggingInterceptor(this.logger);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    logger.i('''
📡 REQUEST: ${options.method} ${options.uri}
🔗 Headers: ${options.headers}
📦 Data: ${options.data}
    ''');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.i('''
✅ RESPONSE: ${response.statusCode} ${response.requestOptions.uri}
📦 Data: ${response.data}
    ''');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    logger.e('''
❌ ERROR: ${err.message}
🔗 URL: ${err.requestOptions.uri}
📦 Data: ${err.response?.data}
    ''');
    handler.next(err);
  }
}

class _ErrorInterceptor extends Interceptor {
  final NotificationService notificationService;

  _ErrorInterceptor(this.notificationService);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Show user-friendly error notifications
    if (err.type == DioExceptionType.connectionError) {
      notificationService.showError('تأكد من اتصال الإنترنت');
    } else if (err.response?.statusCode == 500) {
      notificationService.showError('خطأ في الخادم، حاول مرة أخرى');
    }
    
    handler.next(err);
  }
}