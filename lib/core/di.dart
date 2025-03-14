import 'package:get_it/get_it.dart';
import 'package:q_lock/features/auth/data/repos/auth_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'network/dio_client.dart';
import 'network/dio_config.dart';
import 'network/interceptors/auth_interceptor.dart';
import 'network/interceptors/language_interceptor.dart';
import 'network/interceptors/response_interceptor.dart';

final getIt = GetIt.instance;

setupDI() async {
  final SharedPreferences sharedPreferences =
      await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  getIt.registerLazySingleton<AuthInterceptor>(() => AuthInterceptor());
  getIt.registerLazySingleton<LanguageInterceptor>(() => LanguageInterceptor());
  getIt.registerLazySingleton<ResponseInterceptor>(() => ResponseInterceptor());

  final dio = await DioConfig.createDio(
    interceptors: [
      getIt<AuthInterceptor>(),
      getIt<LanguageInterceptor>(),
      getIt<ResponseInterceptor>(),
    ],
  );
  getIt.registerLazySingleton<DioClient>(() => DioClient(dio));
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(dioClient: getIt()),
  );
}
