import 'package:flutter/material.dart';

import '../../../data/models/message_model.dart';
import 'message_image_item.dart';
import 'message_text_item.dart';

class MessageItemContent extends StatelessWidget {
  const MessageItemContent({
    super.key,
    required this.message,
    required this.isMyMessage,
    required this.size,
  });
  final MessageModel message;
  final bool isMyMessage;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.image) {
      return MessageImageItem(message: message, size: size);
    } else {
      return MessageTextItem(
        message: message.message,
        isMyMessage: isMyMessage,
      );
    }
  }
}
