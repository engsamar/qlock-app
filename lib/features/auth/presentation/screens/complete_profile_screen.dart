import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:q_lock/core/di.dart';
import 'package:q_lock/core/routes/app_routes.dart';
import 'package:q_lock/features/profile/presentation/logic/profile_cubit.dart';
import 'package:q_lock/features/profile/presentation/logic/profile_state.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../../main.dart';
import '../../../notification/repos/notification_repository.dart';
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _usernameController = TextEditingController();
  final _imagePicker = ImagePicker();
  File? _selectedImage;

  @override
  void dispose() {
    _usernameController.dispose();
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppStrings.errorPickingImage.tr()}$e')),
      );
    }
  }

  void _completeProfile(BuildContext context) {
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(AppStrings.enterUsername.tr())));
      return;
    }

    context.read<ProfileCubit>().completeProfile(
      name: username,
      profileImage: _selectedImage,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(profileRepository: getIt()),
      child: Builder(
        builder: (context) {
          return BlocListener<ProfileCubit, ProfileState>(
            listener: (context, state) {
              if (state is ProfileCompletionSuccessState) {
                // Sync with AuthCubit
                context.read<AuthCubit>().syncUserData(state.user);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppStrings.profileCompletedSuccess.tr()),
                  ),
                );

                getIt<NotificationRepository>().initialize(
                  deviceId: deviceId,
                  lang: context.deviceLocale.languageCode,
                );
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (route) => false,
                );
              } else if (state is ProfileCompletionFailureState) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(state.message)));
              }
            },
            child: Scaffold(
              appBar: AppBar(title: Text(AppStrings.completeProfile.tr())),
              extendBodyBehindAppBar: true,
              resizeToAvoidBottomInset: false,
              body: GradientBackground(
                child: SafeArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final availableHeight = constraints.maxHeight - 48.0;
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: SizedBox(height: availableHeight * 0.07),
                            ),
                            SliverToBoxAdapter(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Profile Image Section
                                  ProfileImageSelector(
                                    selectedImage: _selectedImage,
                                    onSelectImage: _selectImage,
                                  ),

                                  // Form Fields Section
                                  ProfileFormFields(
                                    usernameController: _usernameController,
                                  ),
                                ],
                              ),
                            ),

                            // Bottom Button Section
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: CompleteProfileButton(
                                onComplete: () => _completeProfile(context),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ProfileImageSelector extends StatelessWidget {
  final File? selectedImage;
  final VoidCallback onSelectImage;
  final String? currentImageUrl;

  const ProfileImageSelector({
    super.key,
    required this.selectedImage,
    required this.onSelectImage,
    this.currentImageUrl,
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
  final TextEditingController usernameController;

  const ProfileFormFields({super.key, required this.usernameController});

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
          controller: usernameController,
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
        BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) {
            String phoneNumber = '';
            if (state is AuthenticatedState) {
              phoneNumber = state.user.mobile;
            }
            return TextField(
              enabled: false,
              controller: TextEditingController(text: phoneNumber),
            );
          },
        ),
      ],
    );
  }
}

class CompleteProfileButton extends StatelessWidget {
  final VoidCallback onComplete;

  const CompleteProfileButton({super.key, required this.onComplete});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Expanded(child: SizedBox()),
        BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final bool isLoading = state is ProfileCompletionInProgressState;

            return CustomElevatedButton(
              onTap: isLoading ? null : onComplete,
              text: isLoading ? AppStrings.loading.tr() : AppStrings.next.tr(),
              isLoading: isLoading,
            );
          },
        ),
        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ],
    );
  }
}
