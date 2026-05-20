import '../data/local/local_storage.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/course_repository.dart';
import '../domain/repositories/progress_repository.dart';
import '../domain/repositories/schedule_repository.dart';
import '../domain/repositories/subject_repository.dart';
import '../domain/repositories/user_management_repository.dart';
import '../domain/repositories/messenger_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';

import '../core/theme/app_theme.dart';
import '../domain/repositories/aitmatov_repository.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/splash/bloc/splash_bloc.dart';
import 'router.dart';

class AitmatovApp extends StatelessWidget {
  const AitmatovApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(create: (_) => GetIt.I<AuthRepository>()),
        RepositoryProvider<AitmatovRepository>(create: (_) => GetIt.I<AitmatovRepository>()),
        RepositoryProvider<CourseRepository>(create: (_) => GetIt.I<CourseRepository>()),
        RepositoryProvider<SubjectRepository>(create: (_) => GetIt.I<SubjectRepository>()),
        RepositoryProvider<ProgressRepository>(create: (_) => GetIt.I<ProgressRepository>()),
        RepositoryProvider<UserManagementRepository>(create: (_) => GetIt.I<UserManagementRepository>()),
        RepositoryProvider<MessengerRepository>(create: (_) => GetIt.I<MessengerRepository>()),
        RepositoryProvider<ScheduleRepository>(create: (_) => GetIt.I<ScheduleRepository>()),
        RepositoryProvider<LocalStorage>(create: (_) => GetIt.I<LocalStorage>()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => GetIt.I<SplashBloc>()),
          BlocProvider(create: (_) => GetIt.I<AuthBloc>()),
        ],
        child: MaterialApp.router(
          title: 'Aitmatov Digital',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          routerConfig: AppRouter.router,
          localizationsDelegates: const [
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: const [
            Locale('ru', 'RU'),
            Locale('ky', 'KG'),
          ],
        ),
      ),
    );
  }
}
