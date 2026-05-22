import 'dart:developer';

import 'package:aitmatov_app/core/errors/exceptions.dart';
import 'package:aitmatov_app/core/errors/failures.dart';
import 'package:aitmatov_app/core/network/network_info.dart';
import 'package:aitmatov_app/data/dto/user_dto.dart';
import 'package:aitmatov_app/data/local/secure_local_storage.dart';
import 'package:aitmatov_app/domain/entities/user.dart';
import 'package:aitmatov_app/domain/repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final SecureLocalStorage _localStorage;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl(this._dio, this._localStorage, this._networkInfo);

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final response = await _dio.post('/auth/login/', data: {
        'email': email,
        'password': password,
      });
      final responseBody = response.data as Map<String, dynamic>;
      final token = responseBody['access'] as String?;
      final refreshToken = responseBody['refresh'] as String?;
      if (token != null) {
        await _localStorage.setToken(token);
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      if (refreshToken != null) {
        await _localStorage.setRefreshToken(refreshToken);
      }
      var userJson = responseBody['user'] as Map<String, dynamic>? ??
          responseBody['data'] as Map<String, dynamic>?;
      if (userJson == null) {
        final profileResponse = await _dio.get('/users/me/');
        final profileBody = profileResponse.data as Map<String, dynamic>;
        userJson = profileBody['data'] as Map<String, dynamic>? ?? profileBody;
      }
      final user = UserDto.fromJson(userJson).toEntity();
      await _localStorage.cacheUser(userJson);
      return Right(user);
    } on NeedAuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (e) {
      log('Login error: $e');
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, User>> signup(Map<String, dynamic> data) async {
    if (!await _networkInfo.isConnected) {
      return const Left(NetworkFailure());
    }
    try {
      final signupPayload = Map<String, dynamic>.from(data)..remove('role');
      final response = await _dio.post('/auth/signup/', data: signupPayload);
      final responseBody = response.data as Map<String, dynamic>;
      final token = responseBody['access'] as String?;
      final refreshToken = responseBody['refresh'] as String?;
      if (token != null) {
        await _localStorage.setToken(token);
        _dio.options.headers['Authorization'] = 'Bearer $token';
      }
      if (refreshToken != null) {
        await _localStorage.setRefreshToken(refreshToken);
      }
      var userJson = responseBody['user'] as Map<String, dynamic>? ??
          responseBody['data'] as Map<String, dynamic>?;
      if (userJson == null) {
        final profileResponse = await _dio.get('/users/me/');
        final profileBody = profileResponse.data as Map<String, dynamic>;
        userJson = profileBody['data'] as Map<String, dynamic>? ?? profileBody;
      }
      final user = UserDto.fromJson(userJson).toEntity();
      await _localStorage.cacheUser(userJson);
      return Right(user);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (e) {
      log('Signup error: $e');
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _localStorage.clearToken();
      await _localStorage.clearCachedUser();
      _dio.options.headers.remove('Authorization');
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, User?>> getCurrentUser({bool forceRefresh = false}) async {
    try {
      final cached = _localStorage.getCachedUser();
      if (!forceRefresh && cached != null) {
        return Right(UserDto.fromJson(cached).toEntity());
      }
      if (!await _networkInfo.isConnected) {
        return const Left(NetworkFailure());
      }
      final response = await _dio.get('/users/me/');
      final responseBody = response.data as Map<String, dynamic>;
      final userJson = responseBody['data'] as Map<String, dynamic>? ?? responseBody;
      final user = UserDto.fromJson(userJson).toEntity();
      await _localStorage.cacheUser(userJson);
      return Right(user);
    } on NeedAuthException {
      return const Left(AuthFailure());
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (e) {
      log('GetCurrentUser error: $e');
      return const Left(ServerFailure());
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _localStorage.getToken();
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      return true;
    }
    return false;
  }

  @override
  Future<Either<Failure, User>> updateMyProfile({String? username, String? avatar}) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final payload = <String, dynamic>{};
      if (username != null) payload['username'] = username;
      if (avatar != null) payload['avatar'] = avatar;
      final response = await _dio.patch('/users/me/', data: payload);
      final body = response.data as Map<String, dynamic>;
      final json = body['data'] as Map<String, dynamic>? ?? body;
      final user = UserDto.fromJson(json).toEntity();
      await _localStorage.cacheUser(json);
      return Right(user);
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, User>> getUserProfile(int id) async {
    if (!await _networkInfo.isConnected) return const Left(NetworkFailure());
    try {
      final response = await _dio.get('/users/profile/$id/');
      final body = response.data as Map<String, dynamic>;
      final json = body['data'] as Map<String, dynamic>? ?? body;
      return Right(UserDto.fromJson(json).toEntity());
    } on DioException catch (e) {
      return Left(NetworkFailure(e.message ?? 'Ошибка сети'));
    } catch (_) {
      return const Left(ServerFailure());
    }
  }
}
