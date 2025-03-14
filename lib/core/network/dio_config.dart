import 'package:dio/dio.dart';
import 'package:q_lock/core/network/api_constants.dart';

abstract class DioConfig {
  DioConfig._();
  static Future<Dio> createDio({
    required List<Interceptor> interceptors,
  }) async {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );

    dio.interceptors.addAll(interceptors);

    return dio;
  }
}
