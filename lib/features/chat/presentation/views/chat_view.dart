import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../home/data/models/room_model.dart';
import '../logic/chat_cubit.dart';
import '../widgets/chat/chat_app_bar_title.dart';
import '../widgets/chat/chat_view_body.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key, required this.chat});
  final RoomModel chat;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) =>
              ChatCubit(chatRepository: getIt())
                ..fetchMessages(chatId: chat.id.toString()),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          titleSpacing: 0,
          title: ChatAppBarTitle(chat: chat),
          backgroundColor: Colors.transparent,
        ),
        body: GradientBackground(
          gradientHeight: .1,
          child: Padding(
            padding: EdgeInsets.only(
              top:
                  MediaQuery.of(context).padding.top +
                  AppBar().preferredSize.height,
            ),
            child: ChatViewBody(chat: chat),
          ),
        ),
      ),
    );
  }
}
