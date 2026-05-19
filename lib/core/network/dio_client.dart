import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../errors/exceptions.dart';

class DioClient {
  
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://dev.phantom-ink.online/api',
  );
  static const int _timeoutSeconds = 15;

  late final Dio dio;
  final Logger _logger = Logger();
  

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: _timeoutSeconds),
        receiveTimeout: const Duration(seconds: _timeoutSeconds),
        sendTimeout: const Duration(seconds: _timeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      ChuckerDioInterceptor(),
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (o) => _logger.i(o),
      ),
      _AuthInterceptor(),
      _ErrorInterceptor(),
    ]);
  }

  void setToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    dio.options.headers.remove('Authorization');
  }
}

class _AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.response?.statusCode) {
      case 401:
      case 403:
        throw NeedAuthException('Сессия истекла. Войдите снова.');
      case 404:
        throw NotFoundException('Ресурс не найден');
      case 500:
      case 502:
      case 503:
        throw ServerException('Ошибка сервера. Попробуйте позже.');
      default:
        if (err.type == DioExceptionType.connectionTimeout ||
            err.type == DioExceptionType.receiveTimeout ||
            err.type == DioExceptionType.connectionError) {
          throw NetworkException('Нет интернет-соединения');
        }
        throw ServerException(err.message ?? 'Неизвестная ошибка');
    }
  }
}
