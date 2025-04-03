import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../auth/presentation/logic/auth_cubit.dart';
import '../../../data/models/message_model.dart';
import 'message_text_item.dart';

class MessageImageItem extends StatelessWidget {
  const MessageImageItem({
    super.key,
    required this.message,
    required this.size,
  });

  final MessageModel message;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bool isMyMessage =
        message.sender.id == context.read<AuthCubit>().currentUser!.id;

    final isRemoteUrl =
        (Uri.tryParse(message.mediaUrl ?? '')?.hasAbsolutePath ?? false) &&
            message.mediaUrl!.contains('http');

    final isLocalFile = File(message.mediaUrl ?? '').existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isRemoteUrl)
          CachedNetworkImage(
            imageUrl: message.mediaUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) =>
                _ImageError(AppStrings.imageNotFound),
          )
        else if (isLocalFile)
          Image.file(
            File(message.mediaUrl!),
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                _ImageError(AppStrings.failedToLoadImage),
          )
        else
          _ImageError(AppStrings.failedToLoadImage),
        if (message.message.receiver.isNotEmpty) ...[
          const SizedBox(height: 4),
          MessageTextItem(
            message: message.message,
            isMyMessage: isMyMessage,
          ),
        ],
      ],
    );
  }
}

class _ImageError extends StatelessWidget {
  const _ImageError(this.errorMessage);
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        errorMessage,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onError,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
