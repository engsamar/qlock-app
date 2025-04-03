import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_strings.dart';

class ChatViewDateItem extends StatelessWidget {
  const ChatViewDateItem({super.key, required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            color: AppColors.groupDateColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _formatDate(date, context),
            style: TextStyle(
              color: AppColors.darkBlue,
              fontSize: 12,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));

    if (DateUtils.isSameDay(date, today)) {
      return AppStrings.today.tr();
    } else if (DateUtils.isSameDay(date, yesterday)) {
      return AppStrings.yesterday.tr();
    } else {
      return DateFormat('dd MMM yyyy', context.locale.languageCode).format(date);
    }
  }
}
