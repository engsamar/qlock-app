import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../logic/chat_cubit.dart';
import '../../logic/chat_state.dart';
import '../../../../home/data/models/room_model.dart';
import 'chat_view_error.dart';
import 'chat_view_field.dart';
import 'chat_view_success.dart';

class ChatViewBody extends StatelessWidget {
  const ChatViewBody({super.key, required this.chat});

  final RoomModel chat;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: BlocBuilder<ChatCubit, ChatState>(
            builder: (context, state) {
              return switch (state) {
                ChatErrorState() => ChatViewError(chat: chat, state: state),
                ChatLoadingState() => const Center(
                  child: CircularProgressIndicator(),
                ),
                ChatLoadedState() => ChatViewSuccess(
                  messages: state.messages,
                  room: chat,
                ),
                ChatInitialState() => const Center(
                  child: CircularProgressIndicator(),
                ),
              };
            },
          ),
        ),
        ChatViewField(chat: chat),
      ],
    );
  }
}
