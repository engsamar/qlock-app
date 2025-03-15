import '../../../../core/models/user_model.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitialState extends ProfileState {
  const ProfileInitialState();
}

class ProfileLoadingState extends ProfileState {
  const ProfileLoadingState();
}

class ProfileErrorState extends ProfileState {
  final String message;

  const ProfileErrorState({required this.message});
}

// Initial profile completion states
class ProfileCompletionInProgressState extends ProfileState {
  const ProfileCompletionInProgressState();
}

class ProfileCompletionSuccessState extends ProfileState {
  final UserModel user;

  const ProfileCompletionSuccessState({required this.user});
}

class ProfileCompletionFailureState extends ProfileState {
  final String message;

  const ProfileCompletionFailureState({required this.message});
}

// Profile update states
class ProfileUpdateInProgressState extends ProfileState {
  const ProfileUpdateInProgressState();
}

class ProfileUpdateSuccessState extends ProfileState {
  final UserModel user;

  const ProfileUpdateSuccessState({required this.user});
}

class ProfileUpdateFailureState extends ProfileState {
  final String message;

  const ProfileUpdateFailureState({required this.message});
}

// You can add more profile states as needed for future features
// Such as:
// - ProfileUpdatedState
// - ProfileImageUpdatedState
// etc.
