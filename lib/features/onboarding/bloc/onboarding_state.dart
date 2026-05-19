part of 'onboarding_bloc.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

class OnboardingPageState extends OnboardingState {
  final int page;

  const OnboardingPageState(this.page);

  @override
  List<Object?> get props => [page];
}

class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}
