import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/app_colors.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.white,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        minimumSize: Size(double.infinity, 56.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
      tileColor: AppColors.lightGrey,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      textColor: AppColors.darkBlue,
      iconColor: AppColors.darkBlue,
      titleTextStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
    ),
    cardTheme: CardTheme(
      color: AppColors.lightGrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        textStyle: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
          decoration: TextDecoration.underline,
          decorationColor: AppColors.primary,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.lightGrey,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: AppColors.primary),
      ),
    ),
  );
}
