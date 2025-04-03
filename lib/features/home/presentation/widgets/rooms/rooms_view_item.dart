import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/routes/app_routes.dart';
import '../../../../../core/widgets/custom_circle_network_image.dart';
import '../../../data/models/room_model.dart';
import 'rooms_item_subtitle.dart';

class RoomsViewItem extends StatelessWidget {
  const RoomsViewItem({super.key, required this.room});

  final RoomModel room;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(AppRoutes.chat, arguments: room);
      },
      minLeadingWidth: 50,
      leading: CustomCircleNetworkImage(imageUrl: room.user.image, radius: 25),
      title: Row(
        children: [
          Expanded(
            child: Text(
              room.nameOnContact,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          Text(
            room.lastMessageAt != null
                ? formatIntTime(
                  DateTime.parse(room.lastMessageAt!).millisecondsSinceEpoch,
                )
                : '',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.normal,
              color: AppColors.darkBlue,
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Expanded(child: RoomsItemSubtitle(room: room)),
          if (room.unreadMessages != null && room.unreadMessages! > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                room.unreadMessages.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String formatIntTime(int time) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    return DateFormat('hh:mm a').format(dateTime);
  }
}
