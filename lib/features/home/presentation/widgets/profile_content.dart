import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:q_lock/core/constants/app_colors.dart' show AppColors;

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_elevated_button.dart';

class ProfileContent extends StatefulWidget {
  const ProfileContent({super.key});

  @override
  State<ProfileContent> createState() => _ProfileContentState();
}

class _ProfileContentState extends State<ProfileContent> {
  final _usernameController = TextEditingController();
  String? _selectedImagePath;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _selectImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Image picker would open here')),
    );
  }

  void _completeProfile() {
    if (_usernameController.text.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile completed successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight - 48.0;
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Text(
                  AppStrings.editProfile.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(height: availableHeight * 0.06),
              ),
              SliverToBoxAdapter(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: _selectImage,
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: AppColors.white.withValues(
                                alpha: 0.9,
                              ),
                              backgroundImage:
                                  _selectedImagePath != null
                                      ? AssetImage(_selectedImagePath!)
                                      : null,
                              child:
                                  _selectedImagePath == null
                                      ? const Icon(
                                        Icons.person,
                                        size: 50,
                                        color: AppColors.primary,
                                      )
                                      : null,
                            ),
                            TextButton(
                              onPressed: _selectImage,
                              child: Text(AppStrings.changePicture.tr()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 44),
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
                      controller: _usernameController,
                      decoration: InputDecoration(
                        hintText: AppStrings.enterUsername.tr(),
                      ),
                    ),
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
                      controller: TextEditingController(
                        text: '+234 123 456 7890',
                      ),
                    ),
                  ],
                ),
              ),
              SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  children: [
                    Expanded(child: SizedBox()),
                    CustomElevatedButton(
                      onTap: _completeProfile,
                      text: AppStrings.next.tr(),
                    ),
                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
