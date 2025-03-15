import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/custom_elevated_button.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../logic/auth_cubit.dart';
import '../logic/auth_state.dart';

class OTPScreen extends StatefulWidget {
  final String phoneNumber;
  final int code;

  const OTPScreen({super.key, required this.phoneNumber, required this.code});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  late int _code;
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _resendSeconds = 25;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _code = widget.code;
    _startResendTimer();
  }

  void _startResendTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendSeconds > 0) {
        setState(() {
          _resendSeconds--;
        });
        _startResendTimer();
      } else if (mounted) {
        setState(() {
          _canResend = true;
        });
      }
    });
  }

  void _onOTPDigitChanged(String value, int index) {
    if (value.length == 1 && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }

    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    if (_controllers.every((controller) => controller.text.isNotEmpty)) {
      for (var node in _focusNodes) {
        node.unfocus();
      }
    }
  }

  void _verifyOTP() {
    context.read<AuthCubit>().verifyOtpCode(
      phoneNumber: widget.phoneNumber,
      otp: _controllers.map((e) => e.text).join(''),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthenticatedState) {
          if ((context.read<AuthCubit>().state as AuthenticatedState)
                      .user
                      .publicKey ==
                  null ||
              (context.read<AuthCubit>().state as AuthenticatedState)
                      .user
                      .publicKey ==
                  '' ||
              (context.read<AuthCubit>().state as AuthenticatedState)
                      .user
                      .privateKey ==
                  null ||
              (context.read<AuthCubit>().state as AuthenticatedState)
                      .user
                      .privateKey ==
                  '') {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.completeProfile,
              arguments: {'phoneNumber': widget.phoneNumber},
            );
          } else {
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(title: Text(AppStrings.otp.tr())),
        extendBodyBehindAppBar: true,
        body: GradientBackground(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final availableHeight = constraints.maxHeight;
                  return CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: SizedBox(height: availableHeight * 0.30),
                      ),
                      SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              '${AppStrings.enterOtp.tr()} (${widget.phoneNumber})',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.normal,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              '$_code',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.normal,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: List.generate(
                                4,
                                (index) => SizedBox(
                                  width: 78.w,
                                  height: 89.h,
                                  child: TextFormField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    maxLength: 1,
                                    style: TextStyle(
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.black,
                                    ),
                                    onChanged:
                                        (value) =>
                                            _onOTPDigitChanged(value, index),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.timer_outlined,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '00:${_resendSeconds.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed:
                                        _canResend
                                            ? () => _startResendTimer()
                                            : null,
                                    child: Text(AppStrings.resendCode.tr()),
                                  ),
                                ],
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
                            BlocBuilder<AuthCubit, AuthState>(
                              builder: (context, state) {
                                bool isLoading =
                                    state is OtpVerificationInProgressState;
                                return CustomElevatedButton(
                                  onTap: isLoading ? null : _verifyOTP,
                                  isLoading: isLoading,
                                  text: AppStrings.next.tr(),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
