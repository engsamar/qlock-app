import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/custom_icons.dart';
import '../../../../core/di.dart';
import '../../../auth/presentation/logic/auth_cubit.dart';
import 'rooms/rooms_view_body.dart';
import '../logic/rooms/rooms_cubit.dart';

class ChatsContent extends StatefulWidget {
  const ChatsContent({super.key});

  @override
  State<ChatsContent> createState() => _ChatsContentState();
}

class _ChatsContentState extends State<ChatsContent> {
  int _selectedTabIndex = 0;
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => RoomsCubit(roomsRepository: getIt())..fetchRooms(
            currentUserId: (context.read<AuthCubit>().currentUser!.id),
          ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.chats.tr(),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    CustomIcons.search,
                    color: AppColors.white,
                    size: 24.r,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 0;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration:
                          _selectedTabIndex == 0
                              ? BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(24.r),
                              )
                              : null,
                      child: Center(
                        child: Text(
                          AppStrings.all.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color:
                                _selectedTabIndex == 0
                                    ? AppColors.white
                                    : AppColors.darkBlue.withValues(alpha: .5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 1;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration:
                          _selectedTabIndex == 1
                              ? BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(24.r),
                              )
                              : null,
                      child: Center(
                        child: Text(
                          AppStrings.read.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color:
                                _selectedTabIndex == 1
                                    ? AppColors.white
                                    : AppColors.darkBlue.withValues(alpha: .5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 2;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration:
                          _selectedTabIndex == 2
                              ? BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(24.r),
                              )
                              : null,
                      child: Center(
                        child: Text(
                          AppStrings.unread.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color:
                                _selectedTabIndex == 2
                                    ? AppColors.white
                                    : AppColors.darkBlue.withValues(alpha: .5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: RoomsViewBody()),
        ],
      ),
    );
  }
}
