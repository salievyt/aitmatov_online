import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, User>> signup(Map<String, dynamic> data);
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, User?>> getCurrentUser({bool forceRefresh = false});
  Future<Either<Failure, User>> updateMyProfile({String? username, String? avatar});
  Future<Either<Failure, User>> getUserProfile(int id);
  Future<bool> isAuthenticated();
}
