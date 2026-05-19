import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/course_repository_impl.dart';
import '../data/repositories/progress_repository_impl.dart';
import '../data/repositories/subject_repository_impl.dart';
import '../data/repositories/user_management_repository_impl.dart';
import '../data/repositories/messenger_repository_impl.dart';
import '../data/repositories/schedule_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/course_repository.dart';
import '../domain/repositories/progress_repository.dart';
import '../domain/repositories/subject_repository.dart';
import '../domain/repositories/user_management_repository.dart';
import '../domain/repositories/messenger_repository.dart';
import '../domain/repositories/schedule_repository.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/dio_client.dart';
import '../core/network/network_info.dart';
import '../data/local/local_storage.dart';
import '../data/repositories/aitmatov_repository_impl.dart';
import '../domain/repositories/aitmatov_repository.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/splash/bloc/splash_bloc.dart';

final GetIt getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Core
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton<LocalStorage>(() => LocalStorage(getIt()));

  final dio = DioClient().dio;
  getIt.registerLazySingleton<Dio>(() => dio);

  getIt.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt(), getIt(), getIt()),
  );
  getIt.registerLazySingleton<AitmatovRepository>(
    () => AitmatovRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<CourseRepository>(
    () => CourseRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<SubjectRepository>(
    () => SubjectRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<ProgressRepository>(
    () => ProgressRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<UserManagementRepository>(
    () => UserManagementRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<MessengerRepository>(
    () => MessengerRepositoryImpl(getIt(), getIt()),
  );
  getIt.registerLazySingleton<ScheduleRepository>(
    () => ScheduleRepositoryImpl(getIt(), getIt()),
  );

  // Blocs
  getIt.registerFactory<SplashBloc>(() => SplashBloc(getIt(), getIt()));
  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt()));
}
