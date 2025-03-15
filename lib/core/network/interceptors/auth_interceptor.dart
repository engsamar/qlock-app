import 'package:dio/dio.dart';
import 'package:q_lock/core/di.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api_keys.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor();

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers[ApiKeys.authorization] =
        'Bearer ${getIt<SharedPreferences>().getString(ApiKeys.bearerToken) ?? ''}';
    handler.next(options);
  }
}
