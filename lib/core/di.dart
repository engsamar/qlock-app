import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:q_lock/features/auth/data/repos/auth_repository.dart';
import 'package:q_lock/features/chat/data/repos/chat_repository.dart';
import 'package:q_lock/features/home/data/repository/contacts_repository.dart';
import 'package:q_lock/features/home/presentation/logic/contacts/contacts_cubit.dart';
import 'package:q_lock/features/profile/data/repos/profile_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/home/data/repository/rooms_repository.dart';
import '../features/notification/data_sources/firebase_notification_data_source.dart';
import '../features/notification/data_sources/local_notification_data_source.dart';
import '../features/notification/repos/notification_repository.dart';
import 'network/dio_client.dart';
import 'network/dio_config.dart';
import 'network/interceptors/auth_interceptor.dart';
import 'network/interceptors/language_interceptor.dart';
import 'network/interceptors/response_interceptor.dart';

final getIt = GetIt.instance;

Future<void> setupDI() async {
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

  // Firebase
  getIt.registerLazySingleton<FirebaseDatabase>(
    () => FirebaseDatabase.instance,
  );


  getIt.registerLazySingleton<FirebaseMessaging>(
    () => FirebaseMessaging.instance,
  );



  getIt.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => FlutterLocalNotificationsPlugin(),
  );

  // Data sources
  getIt.registerLazySingleton<FirebaseNotificationDataSource>(
    () => FirebaseNotificationDataSource(
      messaging: getIt(),
      dioClient: getIt(),
    ),
  );

  getIt.registerLazySingleton<LocalNotificationDataSource>(
    () => LocalNotificationDataSource(
      plugin: getIt(),
    ),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(dioClient: getIt()),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => ProfileRepository(dioClient: getIt()),
  );

  getIt.registerLazySingleton<ContactsRepository>(
    () => ContactsRepository(dioClient: getIt()),
    );

    getIt.registerLazySingleton<RoomsRepository>(
      () => RoomsRepository(database: getIt()),
    );

  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepository(
      database: getIt(),
      dioClient: getIt(),
    ),
  );

  getIt.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(
      firebaseDataSource: getIt(),
      localDataSource: getIt(),
    ),
  );

  // Register cubits/blocs
  getIt.registerFactory<ContactsCubit>(
    () => ContactsCubit(contactsRepository: getIt()),
  );

  
}
