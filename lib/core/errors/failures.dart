import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Ошибка сервера']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Нет интернет-соединения']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Требуется авторизация']);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Не найдено']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Ошибка кеша']);
}
