import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    required this.onTap,
    required this.text,
    this.isSingleColor = false,
  });

  final VoidCallback onTap;
  final String text;
  final bool isSingleColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          color: isSingleColor ? AppColors.white : null,
          gradient:
              isSingleColor
                  ? null
                  : LinearGradient(
                    colors: [AppColors.primary, AppColors.grey],
                    stops: const [0.0, 1.0],
                    begin: AlignmentDirectional.centerEnd,
                    end: AlignmentDirectional.centerStart,
                  ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),

        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: isSingleColor ? AppColors.primary : AppColors.white,
            ),
          ),
        ),
      ),
    );
  }
}
