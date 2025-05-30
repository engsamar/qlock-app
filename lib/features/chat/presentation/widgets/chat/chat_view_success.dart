import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/functions.dart';
import '../../../../auth/presentation/logic/auth_cubit.dart';
import '../../../../home/data/models/room_model.dart';
import '../../../data/models/message_model.dart';
import '../../logic/chat_cubit.dart';
import '../../logic/chat_state.dart';
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
                decodePrivateKeyFromString(widget.room.user.privateKey ?? ''),
              );

              final decodedMessage = item.copyWith(
                message: MessageContentModel(
                  receiver:
                      isMyMessage
                          ? decodedMessageForOther
                          : decodedMessageForMe,
                  sender:
                      isMyMessage
                          ? decodedMessageForMe
                          : decodedMessageForOther,
                ),
              );
              if (!isMyMessage && index == 0 && decodedMessage.status != 'read') {
                context.read<ChatCubit>().markMessageAsRead(
                  chatId: widget.room.id,
                );
              }
              return GestureDetector(
                onLongPress: () {
                  _showDeleteDialog(context, decodedMessage);
                },
                child: ChatViewMessageItem(message: decodedMessage),
              );
            }
            return const SizedBox();
          },
        ),
      ],
    );
  }

  void _showDeleteDialog(BuildContext ctx, MessageModel message) {
    showDialog(
      context: ctx,
      builder:
          (context) => BlocProvider.value(
            value: ctx.read<ChatCubit>(),
            child: BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                return AlertDialog(
                  title: Text(AppStrings.deleteMessage.tr()),
                  content: Text(AppStrings.deleteMessageContent.tr()),
                  actions: [
                    TextButton(
                      onPressed: () {
                        context
                            .read<ChatCubit>()
                            .deleteMessage(messageId: message.id)
                            .then((value) {
                              if (context.mounted) {
                                Navigator.pop(context);
                              }
                            });
                      },
                      child: Text(AppStrings.delete.tr()),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(AppStrings.cancel.tr()),
                    ),
                  ],
                );
              },
            ),
          ),
    );
  }

  List<dynamic> _groupMessagesByDate(List<MessageModel> messages) {
    final List<dynamic> groupedMessages = [];
    DateTime? currentDate;

    for (final message in messages) {
      final messageDate = message.createdAt;
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
      groupedMessages.add(messages.last.createdAt);
    }
    return groupedMessages;
  }
}
