import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:q_lock/core/di.dart';
import 'package:q_lock/features/auth/presentation/logic/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_keys.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../auth/presentation/logic/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToOnboarding();
  }

  Future<void> _navigateToOnboarding() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      if (context.read<AuthCubit>().state is AuthenticatedState) {
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
          Navigator.pushReplacementNamed(context, AppRoutes.completeProfile);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.home);
        }
      } else {
        if (getIt<SharedPreferences>().getBool(AppKeys.onboardingSeen) ==
            false) {
          Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.login);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        gradientHeight: 1,
        child: Center(
          child: Image.asset(AppImages.logo, width: 166.w, height: 166.h),
        ),
      ),
    );
  }
}
