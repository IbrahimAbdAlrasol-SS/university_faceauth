import 'package:equatable/equatable.dart';

abstract class ApiException extends Equatable implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({
    required this.message,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, statusCode];

  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  const NetworkException(String message) : super(message: message);
}

class ServerException extends ApiException {
  const ServerException([String message = 'خطأ في الخادم'])
      : super(message: message, statusCode: 500);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([String message = 'غير مصرح'])
      : super(message: message, statusCode: 401);
}

class NotFoundException extends ApiException {
  const NotFoundException([String message = 'غير موجود'])
      : super(message: message, statusCode: 404);
}

class ValidationException extends ApiException {
  const ValidationException(String message)
      : super(message: message, statusCode: 422);
}

class TimeoutException extends ApiException {
  const TimeoutException([String message = 'انتهت مهلة الاتصال'])
      : super(message: message);
}