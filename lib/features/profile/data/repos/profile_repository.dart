import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:q_lock/core/network/dio_client.dart';

import '../../../../core/models/user_model.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/models/failure.dart';
import '../../../../core/network/models/resource_model.dart';

class ProfileRepository {
  final DioClient _dioClient;

  ProfileRepository({required DioClient dioClient}) : _dioClient = dioClient;

  Future<Either<Failure, ResourceModel<UserModel>>> updateProfile({
    required String name,
    required String publicKey,
    required String privateKey,
    File? profileImage,
  }) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'public_key': publicKey,
        'privite_key': privateKey,
        if (profileImage != null)
          'image': await MultipartFile.fromFile(
            profileImage.path,
            filename: profileImage.path.split('/').last,
          ),
      });

      return _dioClient.postFormData(
        path: ApiEndpoints.updateProfile,
        formData: formData,
        fromJson: UserModel.fromJson,
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // Method to update specific profile fields
  Future<Either<Failure, ResourceModel<UserModel>>> updateProfileFields({
    String? name,
    File? profileImage,
  }) async {
    try {
      final formData = FormData();

      // Only add fields that are provided
      if (name != null) {
        formData.fields.add(MapEntry('name', name));
      }

      if (profileImage != null) {
        formData.files.add(
          MapEntry(
            'image',
            await MultipartFile.fromFile(
              profileImage.path,
              filename: profileImage.path.split('/').last,
            ),
          ),
        );
      }

      return _dioClient.postFormData(
        path: ApiEndpoints.updateProfile,
        formData: formData,
        fromJson: UserModel.fromJson,
      );
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  // You can add more profile-related methods here in the future
  // Such as:
  // - getProfile()
  // - editProfile()
  // - deleteProfilePicture()
  // etc.
}
