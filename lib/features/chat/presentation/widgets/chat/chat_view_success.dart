import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/functions.dart';
import '../../../../auth/presentation/logic/auth_cubit.dart';
import '../../../../home/data/models/room_model.dart';
import '../../../data/models/message_model.dart';
import 'chat_view_date_item.dart';
import 'chat_view_message_item.dart';

class ChatViewSuccess extends StatefulWidget {
  const ChatViewSuccess({
    super.key,
    required this.messages,
    required this.room,
  });

  final List<MessageModel> messages;
  final RoomModel room;

  @override
  State<ChatViewSuccess> createState() => _ChatViewSuccessState();
}

class _ChatViewSuccessState extends State<ChatViewSuccess> {
  final ScrollController _scrollController = ScrollController();
  late List<dynamic> groupedMessages;

  @override
  void initState() {
    super.initState();
    groupedMessages = _groupMessagesByDate(widget.messages);
  }

  @override
  void didUpdateWidget(ChatViewSuccess oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messages != oldWidget.messages) {
      setState(() {
        groupedMessages = _groupMessagesByDate(widget.messages);
      });
      if (widget.messages.isNotEmpty &&
          oldWidget.messages.isNotEmpty &&
          widget.messages.length > oldWidget.messages.length &&
          widget.messages.first.createdAt !=
              oldWidget.messages.first.createdAt) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListView.builder(
          controller: _scrollController,
          reverse: true,
          itemCount: groupedMessages.length,
          itemBuilder: (context, index) {
            final item = groupedMessages.toList()[index];

            if (item is DateTime) {
              return ChatViewDateItem(date: item);
            } else if (item is MessageModel) {
              final isMyMessage =
                  item.sender.id == context.read<AuthCubit>().currentUser?.id;

              final decodedMessageForMe = decryptWithRSA(
                isMyMessage ? item.message.sender : item.message.receiver,
                decodePrivateKeyFromString(
                  context.read<AuthCubit>().currentUser?.privateKey ?? '',
                ),
              );

              final decodedMessageForOther = decryptWithRSA(
                isMyMessage ? item.message.receiver : item.message.sender,
                decodePrivateKeyFromString(
                  widget.room.user.privateKey ?? '',
                ),
              );

              final decodedMessage = item.copyWith(
                message: MessageContentModel(
                  receiver: isMyMessage
                      ? decodedMessageForOther
                      : decodedMessageForMe,
                  sender: isMyMessage
                      ? decodedMessageForMe
                      : decodedMessageForOther,
                ),
              );
              // TODO: call api to mark message as read if it's not me
              return ChatViewMessageItem(
                message: decodedMessage,
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  List<dynamic> _groupMessagesByDate(List<MessageModel> messages) {
    final List<dynamic> groupedMessages = [];
    DateTime? currentDate;

    for (final message in messages) {
      final messageDate =
          DateTime.fromMillisecondsSinceEpoch(
            message.createdAt.millisecondsSinceEpoch,
          ).toLocal();
      final dateOnly = DateTime(
        messageDate.year,
        messageDate.month,
        messageDate.day,
      );

      if (currentDate == null || currentDate == dateOnly) {
        groupedMessages.add(message);
        currentDate = dateOnly;
      } else {
        groupedMessages.add(currentDate);
        groupedMessages.add(message);
        currentDate = dateOnly;
      }
    }

    if (messages.isNotEmpty) {
      groupedMessages.add(
        DateTime.fromMillisecondsSinceEpoch(
          messages.last.createdAt.millisecondsSinceEpoch,
        ).toLocal(),
      );
    }
    return groupedMessages;
  }
}
