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
import '../../../../../core/constants/custom_icons.dart';
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
      color: AppColors.chatFieldColor,
      child: Row(
        children: [
          IconButton(
            onPressed: () => _showMediaOptions(context),
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
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildOption(
                    context,
                    Icons.camera_alt_rounded,
                    AppStrings.camera,
                    AppColors.primary,
                  ),
                  _buildOption(
                    context,
                    CustomIcons.media,
                    AppStrings.photoAndVideoLibrary,
                    AppColors.primary,
                  ),
                  _buildOption(
                    context,
                    CustomIcons.document,
                    AppStrings.document,
                    AppColors.primary,
                  ),
                  _buildOption(
                    context,
                    CustomIcons.location,
                    AppStrings.location,
                    AppColors.primary,
                  ),
                  _buildOption(
                    context,
                    CustomIcons.profile,
                    AppStrings.contact,
                    AppColors.primary,
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            // Cancel button
            Container(
              margin: EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Center(
                  child: Text(
                    AppStrings.cancel.tr(),
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ),
            SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildOption(
    BuildContext context,
    IconData icon,
    String title,
    Color iconColor,
  ) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(title.tr()),
      onTap: () {
        Navigator.pop(context);
        switch (title) {
          case AppStrings.camera:
            _pickImage(ImageSource.camera);
            break;
          case AppStrings.photoAndVideoLibrary:
            _pickImage(ImageSource.gallery);
            break;
          case AppStrings.document:
            break;
          case AppStrings.location:
            break;
          case AppStrings.contact:
            break;
          default:
            break;
        }
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();

    try {
      final XFile? file = await picker.pickImage(
        source: source,
        imageQuality: 60, // Default quality from ImagePicker
        maxWidth: 800,
        maxHeight: 800,
      );

      if (file == null || !mounted) return;

      // Process the image
      await _processAndSendImage(file);
    } catch (e) {
      if (mounted) {
        _showSnackBar('${AppStrings.errorPickingImage.tr()}${e.toString()}');
      }
    }
  }

  Future<void> _processAndSendImage(XFile file) async {
    try {
      // Maximum size for base64 encoded image (much smaller to ensure DB compatibility)
      // Roughly 20KB binary becomes ~27KB base64, should fit in most DB text columns
      const int maxBase64Size = 20 * 1024;

      // Initial compression with moderate settings
      Uint8List? compressedBytes = await FlutterImageCompress.compressWithFile(
        File(file.path).absolute.path,
        minWidth: 500,
        minHeight: 500,
        quality: 40,
        format: CompressFormat.jpeg,
      );

      if (!mounted) return;

      if (compressedBytes == null) {
        _showSnackBar(AppStrings.failedToCompressImage.tr());
        return;
      }

      // If still too large, try more aggressive compression
      if (compressedBytes.length > maxBase64Size) {
        compressedBytes = await FlutterImageCompress.compressWithList(
          compressedBytes,
          minWidth: 400,
          minHeight: 400,
          quality: 25,
          format: CompressFormat.jpeg,
        );
      }

      // If still too large, try even more aggressive compression
      if (compressedBytes.length > maxBase64Size) {
        compressedBytes = await FlutterImageCompress.compressWithList(
          compressedBytes,
          minWidth: 300,
          minHeight: 300,
          quality: 15,
          format: CompressFormat.jpeg,
        );
      }

      // Final check - if still too large, inform the user
      if (compressedBytes.length > maxBase64Size) {
        _showSnackBar(
          '${AppStrings.imageTooLarge.tr()} Please choose a smaller image or take a lower resolution photo.',
        );
        return;
      }

      // Convert compressed image to base64
      final base64String = base64Encode(compressedBytes);

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
