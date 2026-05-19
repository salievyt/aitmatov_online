import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class UserManagementRepository {
  Future<Either<Failure, List<User>>> getUsers({String? role, String? search});
  Future<Either<Failure, User>> updateUser(int id, Map<String, dynamic> data);
}
