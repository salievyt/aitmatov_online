class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'Нет интернет-соединения']);
}

class NeedAuthException implements Exception {
  final String message;
  NeedAuthException([this.message = 'Требуется авторизация']);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException([this.message = 'Не найдено']);
}

class CacheException implements Exception {
  final String message;
  CacheException([this.message = 'Ошибка кеша']);
}
