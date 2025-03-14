import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

import '../constants/app_strings.dart';
import 'models/failure.dart';

Failure handleDioError(DioException error) {
  switch (error.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return TimeoutFailure(message: AppStrings.requestTimeoutError.tr());

    case DioExceptionType.connectionError:
      return ConnectionFailure(message: AppStrings.checkInternetError.tr());

    case DioExceptionType.badResponse:
      log('**//** Bad Response: ${error.response?.data}');
      log('**//** Bad Response: ${error.response?.data.runtimeType}');
      if (error.response?.data is Map<String, dynamic>) {
        final message =
            error.response?.data?['message'] ?? AppStrings.serverError.tr();
        return ServerFailure(
          message: message,
          statusCode: error.response?.statusCode,
        );
      }
      final message = AppStrings.serverError.tr();
      return ServerFailure(
        message: message,
        statusCode: error.response?.statusCode,
      );

    case DioExceptionType.cancel:
      return RequestCancelledFailure(
        message: AppStrings.requestCancelledError.tr(),
      );

    default:
      return UnexpectedFailure(
        message: error.message ?? AppStrings.unexpectedServerError.tr(),
        statusCode: error.response?.statusCode,
      );
  }
}
