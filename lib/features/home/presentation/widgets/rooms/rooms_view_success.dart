import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_images.dart';
import '../../../../../core/constants/app_strings.dart';
import '../../../data/models/room_model.dart';
import 'rooms_view_item.dart';

class RoomsViewSuccess extends StatefulWidget {
  const RoomsViewSuccess({
    super.key,
    required this.rooms,
    required this.currentUserId,
  });
  final List<RoomModel> rooms;
  final int currentUserId;

  @override
  State<RoomsViewSuccess> createState() => _RoomsViewSuccessState();
}

class _RoomsViewSuccessState extends State<RoomsViewSuccess> {
  @override
  Widget build(BuildContext context) {
    if (widget.rooms.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(AppImages.noChats),
          SizedBox(height: 30.h),
          Text(
            AppStrings.noChatsYet.tr(),
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      );
    }
    return ListView.separated(
      itemCount: widget.rooms.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final room = widget.rooms[index];
        return RoomsViewItem(room: room);
      },
    );
  }
}
