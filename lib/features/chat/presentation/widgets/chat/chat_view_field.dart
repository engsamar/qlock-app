import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';
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

  // Safe way to show snackbar that doesn't depend on BuildContext
  void _showSnackBar(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 58.h,
      color: AppColors.grey,
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            //  => _showMediaOptions(context),
            icon: const Icon(Icons.add),
          ),
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
                  hintText: AppStrings.sendMessageHint.tr(),
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
    // Check if the trimmed text is not empty
    final trimmedText = _messageController.text.trim();
    if (trimmedText.isEmpty) return;

    _sendMessage(message: trimmedText, type: MessageType.text);

    // Clear the text field after sending
    _messageController.clear();
  }

  void _sendMessage({required String message, required MessageType type}) {
    context.read<ChatCubit>().sendMessage(
      chatId: widget.chat.id,
      message: message,
      type: type,
      sender: context.read<AuthCubit>().currentUser!,
      myPublicKey: decodePublicKeyFromString(
        context.read<AuthCubit>().currentUser?.publicKey ?? '',
      ),
      otherPublicKey: decodePublicKeyFromString(
        widget.chat.user.publicKey ?? '',
      ),
    );
  }

  void _showMediaOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo),
                title: Text(AppStrings.sendImage.tr()),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
            ],
          ),
    );
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 60,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (file == null || !mounted) return;

      // Process the image in a separate function to handle all the async work
      await _processAndSendImage(file);
    } catch (e) {
      if (mounted) {
        _showSnackBar('${AppStrings.errorPickingImage.tr()}${e.toString()}');
      }
    }
  }

  Future<void> _processAndSendImage(XFile file) async {
    try {
      // Get the file size to determine compression strategy
      final fileSize = await File(file.path).length();

      // First compression pass - standard for all images
      final File imageFile = File(file.path);

      // Adjust parameters based on original image size - be much more aggressive
      int initialQuality = 20; // Lower quality
      int initialWidth = 500; // Smaller dimensions
      int initialHeight = 500;

      // For very large images (4K+), use even more aggressive initial compression
      if (fileSize > 4 * 1024 * 1024) {
        // > 4MB
        initialQuality = 15;
        initialWidth = 400;
        initialHeight = 400;
      }

      final compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: initialWidth,
        minHeight: initialHeight,
        quality: initialQuality,
        format: CompressFormat.jpeg,
      );

      if (!mounted) return;

      if (compressedBytes == null) {
        _showSnackBar(AppStrings.failedToCompressImage.tr());
        return;
      }

      Uint8List finalImageBytes = compressedBytes;

      // Define a much smaller maximum size for base64 string
      // For MySQL TEXT column which is typically 64KB, stay well under that
      const int maxBase64Size =
          20 * 1024; // 20KB for binary data (becomes ~27KB as base64)


      // Progressive compression - keep reducing quality/size until it fits
      int attemptCount = 0;
      int currentQuality = initialQuality;
      int currentWidth = initialWidth;
      int currentHeight = initialHeight;

      while (finalImageBytes.length > maxBase64Size && attemptCount < 5) {
        // More attempts
        attemptCount++;

        // More aggressive reduction with each attempt
        currentQuality = (currentQuality * 0.6).round(); // Reduce by 40%
        currentWidth = (currentWidth * 0.6).round(); // Reduce by 40%
        currentHeight = (currentHeight * 0.6).round(); // Reduce by 40%

        // Ensure minimum values - lower minimum dimensions
        currentQuality = currentQuality.clamp(
          5,
          100,
        ); // Allow quality as low as 5%
        currentWidth = currentWidth.clamp(
          200,
          1000,
        ); // Allow width as low as 200px
        currentHeight = currentHeight.clamp(
          200,
          1000,
        ); // Allow height as low as 200px


        final recompressedBytes = await FlutterImageCompress.compressWithList(
          finalImageBytes,
          minWidth: currentWidth,
          minHeight: currentHeight,
          quality: currentQuality,
          format: CompressFormat.jpeg,
        );

        finalImageBytes = recompressedBytes;
      }

      // Final size check - abort if still too large
      if (finalImageBytes.length > maxBase64Size) {
        if (mounted) {
          _showSnackBar(AppStrings.imageTooLarge.tr());
        }
        return;
      }

      // Final check - if the base64 string would be larger than ~60KB, reject it
      final base64String = base64Encode(finalImageBytes);
      if (base64String.length > 60 * 1024) {
        if (mounted) {
          _showSnackBar(AppStrings.encodedImageTooLarge.tr());
        }
        return;
      }


      if (!mounted) return;

      // Send the message
      _sendMessage(message: base64String, type: MessageType.image);
    } catch (e) {
      if (mounted) {
        _showSnackBar('${AppStrings.errorProcessingImage.tr()}${e.toString()}');
      }
    }
  }

  OutlineInputBorder buildFieldBorder({required Color color}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: color, width: 2),
    );
  }
}
