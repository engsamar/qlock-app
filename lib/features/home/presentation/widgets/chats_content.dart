import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/custom_icons.dart';
import '../../../../core/di.dart';
import '../../../auth/presentation/logic/auth_cubit.dart';
import '../../../home/data/models/room_model.dart';
import '../logic/rooms/rooms_cubit.dart';
import '../logic/rooms/rooms_state.dart';
import 'rooms/rooms_view_body.dart';
import 'rooms/rooms_view_success.dart';

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
                for (int i = 0; i < 3; i++)
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTabIndex = i;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                        decoration:
                            _selectedTabIndex == i
                                ? BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(24.r),
                                )
                                : null,
                        child: Center(
                          child: Text(
                            i == 0
                                ? AppStrings.all.tr()
                                : i == 1
                                ? AppStrings.read.tr()
                                : AppStrings.unread.tr(),
                            style: TextStyle(
                              fontSize: 14.sp,
                              color:
                                  _selectedTabIndex == i
                                      ? AppColors.white
                                      : AppColors.darkBlue.withValues(
                                        alpha: .5,
                                      ),
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
          Expanded(
            child: BlocBuilder<RoomsCubit, RoomsState>(
              builder: (context, state) {
                if (state is RoomsLoadedState) {
                  // Filter rooms based on the selected tab
                  final List<RoomModel> filteredRooms = _filterRooms(
                    state.rooms,
                  );
                  return _buildFilteredRoomsView(filteredRooms, context);
                }
                return RoomsViewBody();
              },
            ),
          ),
        ],
      ),
    );
  }

  List<RoomModel> _filterRooms(List<RoomModel> rooms) {
    switch (_selectedTabIndex) {
      case 0: // All rooms
        return rooms;
      case 1: // Read rooms
        return rooms
            .where(
              (room) => room.unreadMessages == null || room.unreadMessages == 0,
            )
            .toList();
      case 2: // Unread rooms
        return rooms
            .where(
              (room) => room.unreadMessages != null && room.unreadMessages! > 0,
            )
            .toList();
      default:
        return rooms;
    }
  }

  Widget _buildFilteredRoomsView(
    List<RoomModel> filteredRooms,
    BuildContext context,
  ) {
    final currentUserId = context.read<AuthCubit>().currentUser!.id;

    if (filteredRooms.isEmpty) {
      return Center(
        child: Text(
          _getEmptyStateMessage(),
          style: TextStyle(fontSize: 16.sp, color: AppColors.darkBlue),
        ),
      );
    }

    return RoomsViewSuccess(rooms: filteredRooms, currentUserId: currentUserId);
  }

  String _getEmptyStateMessage() {
    switch (_selectedTabIndex) {
      case 1:
        return AppStrings.noReadChatsYet.tr();
      case 2:
        return AppStrings.noUnreadChatsYet.tr();
      default:
        return AppStrings.noChatsYet.tr();
    }
  }
}
