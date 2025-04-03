import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../data/models/message_model.dart';

class MessageTextItem extends StatelessWidget {
  const MessageTextItem({
    super.key,
    required this.message,
    required this.isMyMessage,
  });
  final MessageContentModel message;
  final bool isMyMessage;

  @override
  Widget build(BuildContext context) {
    return Text(
      message.sender,
      textAlign: _getTextAlign(message.sender),
      style: TextStyle(color: AppColors.black, fontSize: 16),
    );
  }

  TextAlign _getTextAlign(String text) {
    final isArabic = text.characters.any((char) => _isArabicCharacter(char));

    return isArabic ? TextAlign.right : TextAlign.left;
  }

  bool _isArabicCharacter(String char) {
    const arabicCharRange = [0x0600, 0x06FF];
    const arabicSupplementRange = [0x0750, 0x077F];
    const arabicExtendedRangeA = [0x08A0, 0x08FF];
    const arabicPresentationFormsA = [0xFB50, 0xFDFF];
    const arabicPresentationFormsB = [0xFE70, 0xFEFF];

    final codeUnit = char.codeUnitAt(0);
    return (codeUnit >= arabicCharRange[0] && codeUnit <= arabicCharRange[1]) ||
        (codeUnit >= arabicSupplementRange[0] &&
            codeUnit <= arabicSupplementRange[1]) ||
        (codeUnit >= arabicExtendedRangeA[0] &&
            codeUnit <= arabicExtendedRangeA[1]) ||
        (codeUnit >= arabicPresentationFormsA[0] &&
            codeUnit <= arabicPresentationFormsA[1]) ||
        (codeUnit >= arabicPresentationFormsB[0] &&
            codeUnit <= arabicPresentationFormsB[1]);
  }
}
