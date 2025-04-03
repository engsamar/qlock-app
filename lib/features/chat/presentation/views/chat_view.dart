import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di.dart';
import '../../../../core/functions.dart';
import '../../../../core/widgets/gradient_background.dart';
import '../../../auth/presentation/logic/auth_cubit.dart';
import '../../../home/data/models/room_model.dart';
import '../logic/chat_cubit.dart';
import '../widgets/chat/chat_app_bar_title.dart';
import '../widgets/chat/chat_view_body.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key, required this.chat});
  final RoomModel chat;

  @override
  Widget build(BuildContext context) {
    final otherPublicKey = decodePublicKeyFromString(chat.user.publicKey ?? '');
    final myPublicKey = decodePublicKeyFromString(
      context.read<AuthCubit>().currentUser?.publicKey ?? '',
    );

    final otherPrivateKey = decodePrivateKeyFromString(
      chat.user.privateKey ?? '',
    );
    final myPrivateKey = decodePrivateKeyFromString(
      context.read<AuthCubit>().currentUser?.privateKey ?? '',
    );

    final encryptedMessageForOther = encryptWithRSA(
      'Test First',
      otherPublicKey,
    );
    final encryptedMessageForMe = encryptWithRSA('Test First', myPublicKey);

    log('$encryptedMessageForOther------------\n');
    log(encryptedMessageForMe);

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
          child: ChatViewBody(chat: chat),
        ),
      ),
    );
  }
}
