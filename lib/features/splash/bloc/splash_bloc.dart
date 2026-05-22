import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../data/local/secure_local_storage.dart';
import '../../../domain/repositories/auth_repository.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final AuthRepository _authRepository;
  final SecureLocalStorage _localStorage;

  SplashBloc(this._authRepository, this._localStorage) : super(SplashInitial()) {
    on<SplashStarted>(_onSplashStarted);
  }

  Future<void> _onSplashStarted(SplashStarted event, Emitter<SplashState> emit) async {
    emit(SplashLoading());
    await Future.delayed(const Duration(seconds: 2));

    final isFirstLaunch = _localStorage.getFirstLaunch() ?? true;
    final onboardingCompleted = _localStorage.getOnboardingCompleted();

    if (isFirstLaunch || !onboardingCompleted) {
      await _localStorage.setFirstLaunch(false);
      emit(SplashOnboardingRequired());
      return;
    }

    final isAuth = await _authRepository.isAuthenticated();
    if (isAuth) {
      emit(SplashAuthenticated());
    } else {
      emit(SplashUnauthenticated());
    }
  }

  
}

