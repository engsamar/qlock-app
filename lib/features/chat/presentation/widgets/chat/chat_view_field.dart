import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/functions.dart';
import '../../../../auth/presentation/logic/auth_cubit.dart';
import '../../../../home/data/models/room_model.dart';
import '../../../data/models/message_model.dart';
import '../../logic/chat_cubit.dart';

class ChatViewField extends StatefulWidget {
  const ChatViewField({super.key, required this.chat});
  final RoomModel chat;

  @override
  State<ChatViewField> createState() => _ChatViewFieldState();
}

class _ChatViewFieldState extends State<ChatViewField> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58.h,
      color: AppColors.grey,
      child: Row(
        children: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add)),
          Expanded(
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                  border: InputBorder.none,
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: AppColors.darkGrey),
                ),
              ),
            ),
          ),
          IconButton(onPressed: _sendTextMessage, icon: const Icon(Icons.send)),
        ],
      ),
    );
  }

  void _sendTextMessage() {
    context.read<ChatCubit>().sendMessage(
      chatId: widget.chat.id,
      message: _messageController.text,
      type: MessageType.text,
      sender: context.read<AuthCubit>().currentUser!,
      myPublicKey: decodePublicKeyFromString(
        context.read<AuthCubit>().currentUser?.publicKey ?? '',
      ),
      otherPublicKey: decodePublicKeyFromString(
        widget.chat.user.publicKey ?? '',
      ),
    );
  }

  Future<void> _pickMedia(
    BuildContext context, {
    required bool isVideo,
  }) async {}

  OutlineInputBorder buildFieldBorder({required Color color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: 2),
    );
  }
}

class _FieldIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _FieldIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      color: Theme.of(context).colorScheme.onSecondary,
    );
  }
}
