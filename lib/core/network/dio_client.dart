import 'package:chucker_flutter/chucker_flutter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  static const String _rawBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://dev.phantom-ink.online/api',
    // defaultValue: 'http://127.0.0.1/api',
  );
  static const int _timeoutSeconds = 15;

  late final Dio dio;

  String get _baseUrl {
    final trimmed = _rawBaseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    if (trimmed.endsWith('/api')) return trimmed;
    return '$trimmed/api';
  }

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

    final interceptors = <Interceptor>[
      _AuthInterceptor(),
      _ErrorInterceptor(),
    ];

    if (kDebugMode) {
      interceptors.insert(0, ChuckerDioInterceptor());
    }

    dio.interceptors.addAll(interceptors);
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
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: err.error,
        stackTrace: err.stackTrace,
        message: _messageFor(err),
      ),
    );
  }

  String _messageFor(DioException err) {
    final statusCode = err.response?.statusCode;
    final serverMessage = _extractResponseMessage(err.response?.data);

    if (serverMessage != null && serverMessage.isNotEmpty) {
      return serverMessage;
    }

    switch (statusCode) {
      case 400:
        return 'Проверьте заполненные данные.';
      case 401:
        return 'Сессия истекла. Войдите снова.';
      case 403:
        return 'У вас нет доступа к этому действию.';
      case 404:
        return 'Данные не найдены.';
      case 405:
        return 'Это действие не поддерживается сервером.';
      case 409:
        return 'Конфликт данных. Обновите экран и попробуйте снова.';
      case 413:
        return 'Файл слишком большой.';
      case 422:
        return 'Сервер не смог обработать эти данные.';
      case 429:
        return 'Слишком много запросов. Попробуйте позже.';
      case 500:
        return 'Внутренняя ошибка сервера.';
      case 502:
      case 503:
      case 504:
        return 'Сервер временно недоступен. Попробуйте позже.';
    }

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
        return 'Не удалось подключиться к серверу. Проверьте интернет.';
      case DioExceptionType.sendTimeout:
        return 'Не удалось отправить запрос. Проверьте интернет.';
      case DioExceptionType.receiveTimeout:
        return 'Сервер слишком долго отвечает. Попробуйте позже.';
      case DioExceptionType.connectionError:
        return 'Нет соединения с сервером. Проверьте интернет.';
      case DioExceptionType.badCertificate:
        return 'Проблема с сертификатом сервера.';
      case DioExceptionType.cancel:
        return 'Запрос отменен.';
      case DioExceptionType.badResponse:
      case DioExceptionType.unknown:
        return err.message ?? 'Неизвестная ошибка сети.';
    }
  }

  String? _extractResponseMessage(dynamic data) {
    if (data == null) return null;

    if (data is String) {
      final trimmed = data.trim();
      return trimmed.isEmpty ? null : trimmed;
    }

    if (data is List) {
      final messages = data.map(_extractResponseMessage).whereType<String>();
      return messages.isEmpty ? null : messages.join('\n');
    }

    if (data is Map) {
      final preferred = _firstString(data, const [
        'detail',
        'message',
        'error',
        'non_field_errors',
      ]);
      if (preferred != null) return preferred;

      final fieldErrors = <String>[];
      data.forEach((key, value) {
        final message = _extractResponseMessage(value);
        if (message == null || message.isEmpty) return;
        fieldErrors.add('${_fieldLabel(key.toString())}: $message');
      });

      return fieldErrors.isEmpty ? null : fieldErrors.join('\n');
    }

    return data.toString();
  }

  String? _firstString(Map data, List<String> keys) {
    for (final key in keys) {
      if (!data.containsKey(key)) continue;
      final message = _extractResponseMessage(data[key]);
      if (message != null && message.isNotEmpty) return message;
    }
    return null;
  }

  String _fieldLabel(String field) {
    const labels = {
      'email': 'Электронная почта',
      'password': 'Пароль',
      'password_confirm': 'Подтверждение пароля',
      'username': 'Никнейм',
      'first_name': 'Имя',
      'last_name': 'Фамилия',
      'phone': 'Телефон',
      'role': 'Роль',
      'class_level': 'Класс',
      'school': 'Школа',
      'name': 'Название',
      'title': 'Название',
      'description': 'Описание',
      'subject': 'Предмет',
      'message': 'Сообщение',
      'text': 'Текст',
      'grade': 'Оценка',
      'course': 'Курс',
      'lesson': 'Урок',
      'user': 'Пользователь',
    };
    return labels[field] ?? field.replaceAll('_', ' ');
  }
}
