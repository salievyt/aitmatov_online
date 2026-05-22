import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/services/analytics_service.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final AnalyticsService _analytics;

  AuthBloc(this._authRepository, this._analytics) : super(AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
  }

  Future<void> _onLoginRequested(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepository.login(event.email, event.password);
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (user) {
        // Track login event
        _analytics.logLogin(
          method: 'email',
          userId: user.id.toString(),
          role: user.role,
        );
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onSignupRequested(AuthSignupRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepository.signup(event.data);
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (user) {
        // Track signup event
        _analytics.logSignUp(
          method: 'email',
          role: user.role,
        );
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLogoutRequested(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await _authRepository.logout();
    result.fold(
      (failure) => emit(AuthError(_mapFailureToMessage(failure))),
      (_) {
        // Track logout event
        _analytics.logLogout();
        emit(AuthUnauthenticated());
      },
    );
  }

  Future<void> _onCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    final isAuth = await _authRepository.isAuthenticated();
    if (isAuth) {
      final result = await _authRepository.getCurrentUser(forceRefresh: true);
      result.fold(
        (failure) => emit(AuthUnauthenticated()),
        (user) => emit(user != null ? AuthAuthenticated(user) : AuthUnauthenticated()),
      );
    } else {
      emit(AuthUnauthenticated());
    }
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is NetworkFailure) return failure.message;
    if (failure is AuthFailure) return failure.message;
    if (failure is ServerFailure) return failure.message;
    return 'Произошла ошибка';
  }
}
