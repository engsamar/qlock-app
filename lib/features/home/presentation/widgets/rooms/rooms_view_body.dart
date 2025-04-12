import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../../auth/presentation/logic/auth_cubit.dart';
import '../../logic/rooms/rooms_cubit.dart';
import '../../logic/rooms/rooms_state.dart';
import 'rooms_view_error.dart';
import 'rooms_view_success.dart';

class RoomsViewBody extends StatelessWidget {
  const RoomsViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RoomsCubit, RoomsState>(
      builder: (context, state) {
        final currentUserId = (context.read<AuthCubit>().currentUser!.id);
        return switch (state) {
          RoomsErrorState() => RoomsViewError(
            currentUserId: currentUserId,
            state: state,
          ),
          RoomsLoadingState() => const Center(
            child: CircularProgressIndicator(),
          ),
          RoomsLoadedState() => _buildLoadedState(state, currentUserId),
          RoomsInitialState() => const Center(
            child: CircularProgressIndicator(),
          ),
        };
      },
    );
  }

  Widget _buildLoadedState(RoomsLoadedState state, int currentUserId) {
    if (state.filteredRooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(AppImages.noChats),
            SizedBox(height: 30.h),
            Text(
              _getEmptyStateMessage(state.filterType),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      );
    }

    return RoomsViewSuccess(
      rooms: state.filteredRooms,
      currentUserId: currentUserId,
    );
  }

  String _getEmptyStateMessage(FilterType filterType) {
    switch (filterType) {
      case FilterType.read:
        return AppStrings.noReadChatsYet.tr();
      case FilterType.unread:
        return AppStrings.noUnreadChatsYet.tr();
      case FilterType.all:
      default:
        return AppStrings.noChatsYet.tr();
    }
  }
}
