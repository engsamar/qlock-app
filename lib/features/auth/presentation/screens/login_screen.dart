import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_intl_phone_field/flutter_intl_phone_field.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:q_lock/core/widgets/custom_elevated_button.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/gradient_background.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _navigateToOTP() {
    if (_phoneController.text.isNotEmpty) {
      Navigator.pushNamed(
        context,
        AppRoutes.otp,
        arguments: {'phoneNumber': _phoneController.text},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.login.tr())),
      extendBodyBehindAppBar: true,
      body: GradientBackground(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),
                Text(
                  AppStrings.enterPhone.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                SizedBox(height: 40.h),
                Text(
                  AppStrings.phoneNumber.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                IntlPhoneField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.lightGrey,
                    hintText: AppStrings.phoneNumber.tr(),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  initialCountryCode: 'EG',
                  languageCode: context.locale.languageCode,
                  onChanged: (phone) {
                    _phoneController.text = phone.completeNumber;
                  },
                ),
                SizedBox(height: 69.h),
                Text(
                  AppStrings.smsCodeInfo.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                CustomElevatedButton(
                  onTap: _navigateToOTP,
                  text: AppStrings.next.tr(),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
