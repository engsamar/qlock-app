import 'dart:developer';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';

class FirebaseNotificationDataSource {
  final FirebaseMessaging _messaging;
  final DioClient _dioClient;

  FirebaseNotificationDataSource({
    required FirebaseMessaging messaging,
    required DioClient dioClient,
  })  : _messaging = messaging,
        _dioClient = dioClient;

  Future<void> requestPermission() async {
    await _messaging.requestPermission();
  }

  Future<void> saveToken(String token, String deviceId, String lang) async {
    final response = await _dioClient.put(
      path: ApiEndpoints.fcmToken,
      body: {
        'fcm_token': token,
        'device_id': deviceId,
        'platform': Platform.isIOS ? 'ios' : 'android',
        'lang': lang,
      },
      fromJson: (_) => null,
    );

    response.fold(
      (failure) {
        log('**//** ${failure.message} **//**');
      },
      (resource) {
        log('**//** ${resource.data} **//**');
      },
    );
  }

  Stream<String?> onTokenRefresh() {
    return _messaging.onTokenRefresh;
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Stream<RemoteMessage?> onMessage() {
    return FirebaseMessaging.onMessage;
  }
}
