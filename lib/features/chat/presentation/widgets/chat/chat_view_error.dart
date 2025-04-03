import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/chat_cubit.dart';
import '../../logic/chat_state.dart';
import '../../../../home/data/models/room_model.dart';
import 'chat_view_success.dart';

class ChatViewError extends StatelessWidget {
  const ChatViewError({super.key, required this.chat, required this.state});

  final RoomModel chat;
  final ChatErrorState state;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Expanded(child: Text(state.message)),
              IconButton(
                onPressed: () {
                  context.read<ChatCubit>().fetchMessages(chatId: chat.id.toString());
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          if (state.currentMessages.isNotEmpty)
            Expanded(
              child: ChatViewSuccess(
                messages: state.currentMessages,
                room: chat,
              ),
            ),
        ],
      ),
    );
  }
}
