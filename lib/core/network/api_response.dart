import 'package:equatable/equatable.dart';
import 'api_exceptions.dart';

class ApiResponse<T> extends Equatable {
  final T? data;
  final ApiException? error;
  final bool isSuccess;

  const ApiResponse._({
    this.data,
    this.error,
    required this.isSuccess,
  });

  const ApiResponse.success(T data)
      : this._(data: data, isSuccess: true);

  const ApiResponse.error(ApiException error)
      : this._(error: error, isSuccess: false);

  bool get isError => !isSuccess;
  bool get hasData => data != null;

  @override
  List<Object?> get props => [data, error, isSuccess];
}