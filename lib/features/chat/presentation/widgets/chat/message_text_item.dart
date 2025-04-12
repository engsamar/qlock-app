import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/message_model.dart';

class MessageTextItem extends StatelessWidget {
  const MessageTextItem({
    super.key,
    required this.message,
    required this.isMyMessage,
  });
  final MessageContentModel message;
  final bool isMyMessage;

  @override
  Widget build(BuildContext context) {
    return Text(
      message.sender,
      textAlign:
          Directionality.of(context) == TextDirection.rtl
              ? TextAlign.end
              : TextAlign.start,
      style: TextStyle(color: AppColors.black, fontSize: 16),
    );
  }
}
