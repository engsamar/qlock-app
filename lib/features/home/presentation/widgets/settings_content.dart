import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/custom_icons.dart';

class SettingsContent extends StatelessWidget {
  const SettingsContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AppStrings.settings.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 55.h),
          Card(
            child: ListTile(
              leading: Icon(CustomIcons.language),
              title: Text(AppStrings.language.tr()),
              onTap: () {},
            ),
          ),
          SizedBox(height: 18.h),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(CustomIcons.notification),
                  title: Text(AppStrings.customNotifications.tr()),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(CustomIcons.volume),
                  title: Text(AppStrings.muteNotifications.tr()),
                  trailing: Switch(value: false, onChanged: (value) {}),
                  onTap: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(CustomIcons.invite_friends),
                  title: Text(AppStrings.inviteFriends.tr()),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
                ListTile(
                  leading: Icon(CustomIcons.layers),
                  title: Text(AppStrings.aboutApp.tr()),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          Card(
            child: ListTile(
              iconColor: AppColors.red,
              textColor: AppColors.red,
              leading: Icon(CustomIcons.logout),
              title: Text(AppStrings.logout.tr()),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
