import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../core/constants/app_strings.dart';
import '../data_sources/firebase_notification_data_source.dart';
import '../data_sources/local_notification_data_source.dart';

class NotificationRepository {
  final FirebaseNotificationDataSource _firebaseDataSource;
  final LocalNotificationDataSource _localDataSource;

  StreamSubscription<String?>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage?>? _messageSubscription;

  NotificationRepository({
    required FirebaseNotificationDataSource firebaseDataSource,
    required LocalNotificationDataSource localDataSource,
  }) : _firebaseDataSource = firebaseDataSource,
       _localDataSource = localDataSource;

  Future<void> initialize({
    required String deviceId,
    required String lang,
  }) async {
    await _firebaseDataSource.requestPermission();

    await _localDataSource.initialize();

    _tokenRefreshSubscription = _firebaseDataSource.onTokenRefresh().listen((
      token,
    ) async {
      if (token != null) {
        await _firebaseDataSource.saveToken(token, deviceId, lang);
      }
    });

    _messageSubscription = _firebaseDataSource.onMessage().listen((
      message,
    ) async {
      if (message?.notification != null) {
        _localDataSource.showNotification(
          title: message!.notification!.title ?? AppStrings.noTitle.tr(),
          body: message.notification!.body ?? AppStrings.noBody.tr(),
        );
      }
    });

    final token = await _firebaseDataSource.getToken();
    await saveToken(token, deviceId, lang);
  }

  Future<void> saveToken(String? token, String deviceId, String lang) async {
    if (token != null) {
      await _firebaseDataSource.saveToken(token, deviceId, lang);
    }
  }

  Future<String?> getToken() async {
    return _firebaseDataSource.getToken();
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    await _messageSubscription?.cancel();
  }
}
