import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:q_lock/core/network/dio_client.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/models/failure.dart';
import '../../../../core/network/models/resource_model.dart';
import '../models/auth_response_model.dart';

class AuthRepository {
  final DioClient _dioClient;
  AuthRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<Either<Failure, ResourceModel<int?>>> verifyPhoneNumber({
    required String phoneNumber,
  }) async {
    return _dioClient.post(
      path: ApiEndpoints.validateMobile,
      body: {'mobile': phoneNumber},
      fromJson: (json) {
        return json['code'];
      },
    );
  }

  Future<Either<Failure, ResourceModel<AuthResponseModel>>> verifyOtpCode({
    required String phoneNumber,
    required String otp,
  }) async {
    return _dioClient.post(
      path: ApiEndpoints.verifyMobile,
      body: {'mobile': phoneNumber, 'code': otp},
      fromJson: AuthResponseModel.fromJson,
    );
  }
}
