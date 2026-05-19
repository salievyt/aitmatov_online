import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_management_repository.dart';
import '../dto/user_dto.dart';

class UserManagementRepositoryImpl implements UserManagementRepository {
  final Dio _dio;
  final NetworkInfo _networkInfo;

  UserManagementRepositoryImpl(this._dio, this._networkInfo);

  @override
  Future<Either<Failure, List<User>>> getUsers({String? role, String? search}) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final query = <String, dynamic>{};
      if (role != null && role.isNotEmpty) query['role'] = role;
      if (search != null && search.isNotEmpty) query['search'] = search;
      final response = await _dio.get('/users/', queryParameters: query);
      final body = response.data as Map<String, dynamic>;
      final results = (body['results'] ?? <dynamic>[]) as List<dynamic>;
      final users = results.map((e) => UserDto.fromJson(e as Map<String, dynamic>).toEntity()).toList();
      return Right(users);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, User>> updateUser(int id, Map<String, dynamic> data) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dio.patch('/users/$id/', data: data);
      final user = UserDto.fromJson(response.data as Map<String, dynamic>).toEntity();
      return Right(user);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
