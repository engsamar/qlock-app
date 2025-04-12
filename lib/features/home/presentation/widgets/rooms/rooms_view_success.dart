import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../data/models/room_model.dart';
import 'rooms_view_item.dart';

class RoomsViewSuccess extends StatelessWidget {
  const RoomsViewSuccess({
    super.key,
    required this.rooms,
    required this.currentUserId,
  });
  final List<RoomModel> rooms;
  final int currentUserId;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: rooms.length,
      separatorBuilder: (context, index) => SizedBox(height: 8.h),
      itemBuilder: (context, index) {
        final room = rooms[index];
        return RoomsViewItem(room: room);
      },
    );
  }
}
