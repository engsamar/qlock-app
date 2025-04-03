import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/functions.dart';
import '../../../../auth/presentation/logic/auth_cubit.dart';
import '../../../../chat/data/models/message_model.dart';
import '../../../data/models/room_model.dart';

class RoomsItemSubtitle extends StatelessWidget {
  const RoomsItemSubtitle({super.key, required this.room});
  final RoomModel room;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleTextStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.primary,
    );
    final isMyMessage =
        room.lastMessageModel?.sender.id ==
        context.read<AuthCubit>().currentUser!.id;

    final decodedMessageForMe = decryptWithRSA(
      isMyMessage
          ? room.lastMessageModel?.message.sender ?? ''
          : room.lastMessageModel?.message.receiver ?? '',
      decodePrivateKeyFromString(
        context.read<AuthCubit>().currentUser?.privateKey ?? '',
      ),
    );

    final decodedMessageForOther = decryptWithRSA(
      isMyMessage
          ? room.lastMessageModel?.message.receiver ?? ''
          : room.lastMessageModel?.message.sender ?? '',
      decodePrivateKeyFromString(room.user.privateKey ?? ''),
    );

    final decodedMessage = MessageContentModel(
      receiver: isMyMessage ? decodedMessageForOther : decodedMessageForMe,
      sender: isMyMessage ? decodedMessageForMe : decodedMessageForOther,
    );

    if (room.lastMessageModel?.type == MessageType.text) {
      return Text(
        decodedMessage.sender,
        style: subtitleTextStyle,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (room.lastMessageModel != null)
          Row(
            children: [
              Icon(
                _getIconForMessageType(
                  room.lastMessageModel?.type ?? MessageType.text,
                ),
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 4),
            ],
          ),
        // Text(
        //   room.lastMessageModel?.message.receiver.isNotEmpty ?? false
        //       ? room.lastMessageModel?.sender.id ==
        //               context.read<AuthCubit>().currentUser!.id
        //           ? room.lastMessageModel?.message.sender ?? ''
        //           : room.lastMessageModel?.message.receiver ??
        //               'waiting for message...'
        //       : room.lastMessageModel?.type.name.toUpperCase() ??
        //           'waiting for message...',
        //   style: subtitleTextStyle,
        // ),
      ],
    );
  }

  IconData _getIconForMessageType(MessageType type) {
    switch (type) {
      case MessageType.image:
        return Icons.image_outlined;
      case MessageType.video:
        return Icons.video_library_outlined;
      case MessageType.audio:
        return Icons.audio_file_outlined;
      case MessageType.file:
        return Icons.attach_file_outlined;
      case MessageType.text:
        return Icons.message_outlined;
    }
  }
}
