import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constans/constants.dart';
import '../../../data/local/local_storage.dart';
import '../bloc/onboarding_bloc.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      icon: Icons.school,
      title: 'Aitmatov Digital',
      subtitle: 'Твой школьный цифровой центр',
    ),
    _OnboardingPage(
      icon: Icons.menu_book,
      title: 'Учебники и курсы',
      subtitle: 'Учебники, курсы, тесты, проекты',
    ),
    _OnboardingPage(
      icon: Icons.auto_stories,
      title: 'Айтматов и Касандра',
      subtitle: 'Касандра как метафора твоего выбора',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingBloc(),
      child: BlocConsumer<OnboardingBloc, OnboardingState>(
        listener: (context, state) async {
          if (state is OnboardingCompleted) {
            final storage = GetIt.I<LocalStorage>();
            await storage.setOnboardingCompleted(true);
            if (context.mounted) context.go('/login');
          }
        },
        builder: (context, state) {
          final page = state is OnboardingPageState ? state.page : 0;
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.read<OnboardingBloc>().add(OnboardingSkip()),
                        child: const Text('Пропустить'),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(_pages[page].icon, size: AppSizes.iconXXL, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(height: AppSpacing.xxxl),
                          Text(_pages[page].title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                          const SizedBox(height: AppSpacing.lg),
                          Text(_pages[page].subtitle, style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                          width: i == page ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                            color: i == page
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () => context.read<OnboardingBloc>().add(OnboardingNextPage()),
                        child: Text(page == _pages.length - 1 ? 'Начать' : 'Далее'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OnboardingPage {
  final IconData icon;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}
