import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_images.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/widgets/gradient_background.dart';

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
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.onboarding);
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
