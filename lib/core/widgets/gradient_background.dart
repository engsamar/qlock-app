import 'package:flutter/material.dart';
import 'package:q_lock/core/constants/app_colors.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;
  final double gradientHeight;

  const GradientBackground({
    super.key,
    required this.child,
    this.gradientHeight = 0.22,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary, AppColors.white],
          stops: [0, gradientHeight],
        ),
      ),
      child: child,
    );
  }
}
