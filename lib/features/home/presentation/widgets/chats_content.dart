import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/custom_icons.dart';
import '../../../../core/di.dart';
import '../../../auth/presentation/logic/auth_cubit.dart';
import '../logic/rooms/rooms_cubit.dart';
import '../logic/rooms/rooms_state.dart';
import 'rooms/rooms_view_body.dart';

class ChatsContent extends StatefulWidget {
  const ChatsContent({super.key});

  @override
  State<ChatsContent> createState() => _ChatsContentState();
}

class _ChatsContentState extends State<ChatsContent> {
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
          _buildFilterTabs(),
          Expanded(child: RoomsViewBody()),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return BlocBuilder<RoomsCubit, RoomsState>(
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              for (int i = 0; i < FilterType.values.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      final cubit = context.read<RoomsCubit>();
                      final currentUserId =
                          context.read<AuthCubit>().currentUser!.id;
                      cubit.changeFilter(
                        FilterType.values[i],
                        currentUserId: currentUserId,
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration:
                          state.filterType == FilterType.values[i]
                              ? BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(24.r),
                              )
                              : null,
                      child: Center(
                        child: Text(
                          _getFilterTabLabel(FilterType.values[i]),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color:
                                state.filterType == FilterType.values[i]
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
        );
      },
    );
  }

  String _getFilterTabLabel(FilterType filterType) {
    switch (filterType) {
      case FilterType.all:
        return AppStrings.all.tr();
      case FilterType.read:
        return AppStrings.read.tr();
      case FilterType.unread:
        return AppStrings.unread.tr();
    }
  }
}
