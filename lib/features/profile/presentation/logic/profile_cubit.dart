import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:q_lock/core/functions.dart';

import '../../data/repos/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(const ProfileInitialState());

  /// Complete user profile with name, image and RSA keys
  Future<void> completeProfile({
    required String name,
    File? profileImage,
  }) async {
    emit(const ProfileCompletionInProgressState());

    try {
      // Generate RSA key pair
      final keyPair = generateRSAkeyPair();

      // Convert keys to strings for database storage
      final publicKeyString = encodePublicKeyToString(keyPair.publicKey);
      final privateKeyString = encodePrivateKeyToString(keyPair.privateKey);

      final result = await _profileRepository.updateProfile(
        name: name,
        publicKey: publicKeyString,
        privateKey: privateKeyString,
        profileImage: profileImage,
      );

      result.fold(
        (failure) {
          emit(ProfileCompletionFailureState(message: failure.message));
        },
        (success) {
          emit(ProfileCompletionSuccessState(user: success.data));
        },
      );
    } catch (e) {
      emit(ProfileCompletionFailureState(message: e.toString()));
    }
  }

  /// Update existing profile information
  Future<void> updateProfile({
    String? name,
    File? profileImage,
  }) async {
    emit(const ProfileUpdateInProgressState());

    try {
      // At least one field should be provided
      if (name == null && profileImage == null) {
        emit(
          const ProfileUpdateFailureState(
            message: 'At least one field must be updated',
          ),
        );
        return;
      }

      final result = await _profileRepository.updateProfileFields(
        name: name,
        profileImage: profileImage,
      );

      result.fold(
        (failure) {
          emit(ProfileUpdateFailureState(message: failure.message));
        },
        (success) {
          emit(ProfileUpdateSuccessState(user: success.data));
        },
      );
    } catch (e) {
      emit(ProfileUpdateFailureState(message: e.toString()));
    }
  }
}
