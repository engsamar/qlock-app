import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
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

    // Get the actual message content which might be base64 encoded
    final String messageContent = message.message.receiver;

    // Check if it's a remote URL
    final isRemoteUrl =
        (Uri.tryParse(message.mediaUrl ?? '')?.hasAbsolutePath ?? false) &&
        message.mediaUrl!.contains('http');

    // Check if it's a local file
    final isLocalFile = File(message.mediaUrl ?? '').existsSync();

    // Try to detect if the content is a base64 encoded image
    bool isBase64Image = false;
    Uint8List? imageBytes;

    if (messageContent.isNotEmpty) {
      try {
        // Try to decode as base64
        imageBytes = base64Decode(messageContent);
        // If we get here without an exception, it's likely base64
        isBase64Image = imageBytes.isNotEmpty;
      } catch (e) {
        // Not a valid base64 string
        isBase64Image = false;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isRemoteUrl)
          CachedNetworkImage(
            imageUrl: message.mediaUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorWidget:
                (context, url, error) =>
                    _ImageError(AppStrings.imageNotFound.tr()),
          )
        else if (isLocalFile)
          Image.file(
            File(message.mediaUrl!),
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) =>
                    _ImageError(AppStrings.failedToLoadImage.tr()),
          )
        else if (isBase64Image && imageBytes != null)
          Image.memory(
            imageBytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder:
                (context, error, stackTrace) =>
                    _ImageError(AppStrings.failedToLoadImage.tr()),
          )
        else
          _ImageError(AppStrings.failedToLoadImage.tr()),
        if (message.message.receiver.isNotEmpty && !isBase64Image) ...[
          const SizedBox(height: 4),
          MessageTextItem(message: message.message, isMyMessage: isMyMessage),
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
