import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';

import '../constants/app_strings.dart';
import 'api_keys.dart';
import 'dio_error_handler.dart';
import 'models/failure.dart';
import 'models/pagination_model.dart';
import 'models/resource_model.dart';

class DioClient {
  final Dio _dio;

  DioClient(this._dio);

  Future<Either<Failure, ResourceModel<T>>> get<T, M>({
    required String path,
    required M Function(Map<String, dynamic>) fromJson,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);

      final responseData = response.data as Map<String, dynamic>;
      final data = _parseData<T, M>(responseData[ApiKeys.dataKey], fromJson);
      final pagination =
          responseData[ApiKeys.paginationKey] != null
              ? PaginationModel.fromJson(responseData[ApiKeys.paginationKey])
              : null;

      return Right(ResourceModel<T>(data: data, pagination: pagination));
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(
        ServerFailure(message: AppStrings.unexpectedError.tr() + e.toString()),
      );
    }
  }

  Future<Either<Failure, ResourceModel<T>>> post<T, M>({
    required String path,
    required M Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: body,
        queryParameters: queryParameters,
      );
      final responseData = response.data as Map<String, dynamic>;
      final data = _parseData<T, M>(responseData[ApiKeys.dataKey], fromJson);
      final pagination =
          responseData[ApiKeys.paginationKey] != null
              ? PaginationModel.fromJson(responseData[ApiKeys.paginationKey])
              : null;

      return Right(ResourceModel<T>(data: data, pagination: pagination));
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(
        ServerFailure(message: AppStrings.unexpectedError.tr() + e.toString()),
      );
    }
  }

  Future<Either<Failure, ResourceModel<T>>> put<T, M>({
    required String path,
    required M Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: body,
        queryParameters: queryParameters,
      );
      final responseData = response.data as Map<String, dynamic>;
      final data = _parseData<T, M>(responseData[ApiKeys.dataKey], fromJson);
      final pagination =
          responseData[ApiKeys.paginationKey] != null
              ? PaginationModel.fromJson(responseData[ApiKeys.paginationKey])
              : null;

      return Right(ResourceModel<T>(data: data, pagination: pagination));
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(
        ServerFailure(message: AppStrings.unexpectedError.tr() + e.toString()),
      );
    }
  }

  Future<Either<Failure, ResourceModel<T>>> delete<T, M>({
    required String path,
    required M Function(Map<String, dynamic>) fromJson,
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: body,
        queryParameters: queryParameters,
      );
      final responseData = response.data as Map<String, dynamic>;
      final data = _parseData<T, M>(responseData[ApiKeys.dataKey], fromJson);
      final pagination =
          responseData[ApiKeys.paginationKey] != null
              ? PaginationModel.fromJson(responseData[ApiKeys.paginationKey])
              : null;

      return Right(ResourceModel<T>(data: data, pagination: pagination));
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(
        ServerFailure(message: AppStrings.unexpectedError.tr() + e.toString()),
      );
    }
  }

  Future<Either<Failure, ResourceModel<T>>> postFormData<T, M>({
    required String path,
    required M Function(Map<String, dynamic>) fromJson,
    required FormData formData,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: Options(contentType: 'multipart/form-data'),
      );

      final responseData = response.data as Map<String, dynamic>;
      final data = _parseData<T, M>(responseData[ApiKeys.dataKey], fromJson);
      final pagination =
          responseData[ApiKeys.paginationKey] != null
              ? PaginationModel.fromJson(responseData[ApiKeys.paginationKey])
              : null;

      return Right(ResourceModel<T>(data: data, pagination: pagination));
    } on DioException catch (e) {
      return Left(handleDioError(e));
    } catch (e) {
      return Left(
        ServerFailure(message: AppStrings.unexpectedError.tr() + e.toString()),
      );
    }
  }

  T _parseData<T, M>(dynamic data, M Function(Map<String, dynamic>) fromJson) {
    if (T == List<M>) {
      if (data is List) {
        return data
                .map((item) => fromJson(item as Map<String, dynamic>))
                .toList()
            as T;
      } else {
        throw FormatException(
          AppStrings.expectedListError.tr() + data.runtimeType.toString(),
        );
      }
    } else if (data is Map<String, dynamic>) {
      return fromJson(data) as T;
    } else {
      throw FormatException(
        AppStrings.expectedMapError.tr() + data.runtimeType.toString(),
      );
    }
  }
}
