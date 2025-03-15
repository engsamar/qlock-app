import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:q_lock/core/di.dart';

import '../../../../core/constants/app_colors.dart' show AppColors;
import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../auth/presentation/logic/auth_cubit.dart';
import '../../../auth/presentation/logic/auth_state.dart';
import '../../../profile/data/repos/profile_repository.dart';
import '../../../profile/presentation/logic/profile_cubit.dart';
import '../../../profile/presentation/logic/profile_state.dart';

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  final _nameController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _selectedImage;
  bool _isInitialized = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _selectImage() async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _updateProfile(BuildContext context, UserModel user) {
    final String nameText = _nameController.text.trim();
    final String? name = nameText != user.name ? nameText : null;

    if (name == null && _selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.noChangesDetected.tr())),
      );
      return;
    }

    context.read<ProfileCubit>().updateProfile(
      name: nameText,
      profileImage: _selectedImage,
    );
  }

  void _initializeUserData(dynamic user) {
    if (!_isInitialized && user != null) {
      _nameController.text = user.name ?? '';
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              ProfileCubit(profileRepository: getIt<ProfileRepository>()),
      child: Builder(
        builder: (context) {
          return BlocListener<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileUpdateSuccessState) {
                context.read<AuthCubit>().syncUserData(state.user);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.profileUpdatedSuccess.tr()),
                  ),
                );
                // Reset selected image after successful update
                setState(() {
                  _selectedImage = null;
                });
              } else if (state is ProfileUpdateFailureState) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            child: BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                if (state is AuthenticatedState) {
                  final UserModel user = state.user;
                  _initializeUserData(user);

                  return GradientBackground(
                    child: SafeArea(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final availableHeight = constraints.maxHeight - 48.0;
                          return Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: CustomScrollView(
                              slivers: [
                                // Title
                                SliverToBoxAdapter(
                                  child: Text(
                                    AppStrings.profile.tr(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: SizedBox(
                                    height: availableHeight * 0.06,
                                  ),
                                ),

                                // Profile content
                                SliverToBoxAdapter(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Profile Image Section
                                      ProfileImageSelector(
                                        currentImageUrl: user.image,
                                        selectedImage: _selectedImage,
                                        onSelectImage: _selectImage,
                                      ),

                                      // Form Fields Section
                                      ProfileFormFields(
                                        nameController: _nameController,
                                        phoneNumber: user.mobile,
                                      ),
                                    ],
                                  ),
                                ),

                                // Update Button
                                SliverFillRemaining(
                                  hasScrollBody: false,
                                  child: BlocBuilder<
                                    ProfileCubit,
                                    ProfileState
                                  >(
                                    builder: (context, profileState) {
                                      final bool isLoading =
                                          profileState
                                              is ProfileUpdateInProgressState;
                                      return Column(
                                        children: [
                                          const Expanded(child: SizedBox()),
                                          CustomElevatedButton(
                                            onTap:
                                                isLoading
                                                    ? null
                                                    : () => _updateProfile(
                                                      context,
                                                      user,
                                                    ),
                                            text:
                                                isLoading
                                                    ? AppStrings.loading.tr()
                                                    : AppStrings.update.tr(),
                                            isLoading: isLoading,
                                          ),
                                          SizedBox(
                                            height:
                                                MediaQuery.of(
                                                  context,
                                                ).viewInsets.bottom,
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                }

                // Fallback if not authenticated (shouldn't happen normally)
                return const Center(
                  child: Text('Please login to view your profile'),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class ProfileImageSelector extends StatelessWidget {
  final String? currentImageUrl;
  final File? selectedImage;
  final VoidCallback onSelectImage;

  const ProfileImageSelector({
    super.key,
    this.currentImageUrl,
    this.selectedImage,
    required this.onSelectImage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onSelectImage,
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.white.withValues(alpha: 0.9),
              backgroundImage:
                  selectedImage != null ? FileImage(selectedImage!) : null,
              child:
                  selectedImage == null
                      ? _buildNetworkImageOrPlaceholder()
                      : null,
            ),
            TextButton(
              onPressed: onSelectImage,
              child: Text(AppStrings.changePicture.tr()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetworkImageOrPlaceholder() {
    if (currentImageUrl != null && currentImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(50),
        child: CachedNetworkImage(
          imageUrl: currentImageUrl!,
          fit: BoxFit.cover,
          width: 100,
          height: 100,
          placeholder:
              (context, url) => const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
          errorWidget:
              (context, url, error) =>
                  const Icon(Icons.person, size: 50, color: AppColors.primary),
        ),
      );
    } else {
      return const Icon(Icons.person, size: 50, color: AppColors.primary);
    }
  }
}

class ProfileFormFields extends StatelessWidget {
  final TextEditingController nameController;
  final String phoneNumber;

  const ProfileFormFields({
    super.key,
    required this.nameController,
    required this.phoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 44),

        // Username Field
        Text(
          AppStrings.username.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: nameController,
          decoration: InputDecoration(hintText: AppStrings.enterUsername.tr()),
        ),

        // Phone Number Field (readonly)
        const SizedBox(height: 16),
        Text(
          AppStrings.phoneNumber.tr(),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          enabled: false,
          controller: TextEditingController(text: phoneNumber),
        ),
      ],
    );
  }
}
