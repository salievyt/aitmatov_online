import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingPageState(0)) {
    on<OnboardingNextPage>(_onNextPage);
    on<OnboardingSkip>(_onSkip);
    on<OnboardingComplete>(_onComplete);
  }

  void _onNextPage(OnboardingNextPage event, Emitter<OnboardingState> emit) {
    if (state is OnboardingPageState) {
      final current = (state as OnboardingPageState).page;
      if (current < 2) {
        emit(OnboardingPageState(current + 1));
      } else {
        emit(const OnboardingCompleted());
      }
    }
  }

  void _onSkip(OnboardingSkip event, Emitter<OnboardingState> emit) {
    emit(const OnboardingCompleted());
  }

  void _onComplete(OnboardingComplete event, Emitter<OnboardingState> emit) {
    emit(const OnboardingCompleted());
  }
}
