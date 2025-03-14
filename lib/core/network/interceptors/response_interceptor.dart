import 'package:dio/dio.dart';
import '../api_keys.dart';
import '../models/pagination_model.dart';

class ResponseInterceptor extends Interceptor {
  ResponseInterceptor();

  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    if (response.data is Map<String, dynamic>) {
      final responseData = response.data as Map<String, dynamic>;

      PaginationModel? pagination;
      if (responseData.containsKey(ApiKeys.pageKey) ||
          responseData.containsKey(ApiKeys.totalPagesKey) ||
          responseData.containsKey(ApiKeys.totalResultsKey)) {
        pagination = PaginationModel.fromJson(responseData);

        response.data = {
          ApiKeys.dataKey: responseData['data'],
          ApiKeys.paginationKey: pagination.toJson(),
        };
      } else {
        response.data = {
          ApiKeys.dataKey: responseData['data'],
          ApiKeys.paginationKey: null,
        };
      }
    }

    handler.next(response);
  }
}
