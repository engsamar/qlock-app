import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../auth/presentation/logic/auth_cubit.dart';
import '../../../data/models/message_model.dart';
import 'message_item_content.dart';

class ChatViewMessageItem extends StatelessWidget {
  const ChatViewMessageItem({super.key, required this.message});

  final MessageModel message;

  @override
  Widget build(BuildContext context) {
    final isMyMessage =
        message.sender.id == (context.read<AuthCubit>().currentUser!.id);
    final itemWidth = MediaQuery.of(context).size.width * .6;

    return Align(
      alignment:
          isMyMessage
              ? AlignmentDirectional.centerEnd
              : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(8),
        constraints: BoxConstraints(maxWidth: itemWidth),
        decoration: BoxDecoration(
          color:
              isMyMessage
                  ? AppColors.myMessageColor
                  : AppColors.otherMessageColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: isMyMessage ? const Radius.circular(12) : Radius.zero,
            bottomRight: isMyMessage ? Radius.zero : const Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: .25),
              blurRadius: 4,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            MessageItemContent(
              message: message,
              isMyMessage: isMyMessage,
              size: itemWidth,
            ),
            SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  formatIntTime(message.createdAt.millisecondsSinceEpoch),
                  style: TextStyle(
                    color:
                        isMyMessage
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 12,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.check_rounded,
                  size: 14.r,
                  color:
                      message.status == 'sent'
                          ? AppColors.grey
                          : AppColors.blue,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String formatIntTime(int time) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(time);
    return DateFormat('hh:mm a').format(dateTime);
  }
}
