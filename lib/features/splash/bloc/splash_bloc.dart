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

    // Run token migration asynchronously (non-blocking)
    // This ensures tokens are migrated to secure storage on first launch
    _localStorage.migrateFromSharedPreferences().catchError((e) {
      // Silent failure - migration will retry on next launch
      // User can still use the app if migration fails
    });

    // Use minimum splash time (800ms) in parallel with auth check
    // This ensures smooth UX without artificial delays
    final minSplashTime = Future.delayed(const Duration(milliseconds: 800));

    final isFirstLaunch = _localStorage.getFirstLaunch() ?? true;
    final onboardingCompleted = _localStorage.getOnboardingCompleted();

    if (isFirstLaunch || !onboardingCompleted) {
      await minSplashTime;
      await _localStorage.setFirstLaunch(false);
      emit(SplashOnboardingRequired());
      return;
    }

    final isAuth = await _authRepository.isAuthenticated();

    // Wait for minimum splash time to complete
    await minSplashTime;

    if (isAuth) {
      emit(SplashAuthenticated());
    } else {
      emit(SplashUnauthenticated());
    }
  }

  
}

