part of 'onboarding_bloc.dart';

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class OnboardingNextPage extends OnboardingEvent {}

class OnboardingSkip extends OnboardingEvent {}

class OnboardingComplete extends OnboardingEvent {}
