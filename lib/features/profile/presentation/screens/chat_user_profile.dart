import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:q_lock/core/widgets/gradient_background.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/custom_icons.dart';
import '../../../../core/widgets/custom_circle_network_image.dart';
import '../../../home/data/models/room_model.dart';

class ChatUserProfile extends StatelessWidget {
  const ChatUserProfile({super.key, required this.chat});
  final RoomModel chat;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppStrings.contactInfo.tr(),
          style: TextStyle(fontSize: 17.sp),
        ),
      ),
      body: GradientBackground(
        gradientHeight: .25,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.r),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 16.h),
                CustomCircleNetworkImage(
                  imageUrl: chat.user.image,
                  radius: 60.r,
                ),
                Text(
                  chat.nameOnContact,
                  style: TextStyle(
                    fontSize: 27.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  chat.user.mobile,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.normal,
                    color: AppColors.myMessageColor,
                  ),
                ),
                SizedBox(height: 24.h),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: Icon(CustomIcons.media),
                        title: Text(
                          AppStrings.media.tr(),
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: AppColors.grey,
                        ),
                      ),
                      Divider(color: AppColors.grey, indent: 36.w, height: 0),
                      ListTile(
                        leading: Icon(CustomIcons.star),
                        title: Text(
                          AppStrings.starredMessages.tr(),
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 18,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Card(
                  child: ListTile(
                    leading: Icon(CustomIcons.notification),
                    title: Text(
                      AppStrings.notificationsAndSounds.tr(),
                      style: TextStyle(fontWeight: FontWeight.normal),
                    ),
                    trailing: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: AppColors.grey,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          AppStrings.shareContact.tr(),
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      Divider(color: AppColors.grey, indent: 36.w, height: 0),
                      ListTile(
                        title: Text(
                          AppStrings.clearChat.tr(),
                          style: TextStyle(
                            color: AppColors.red,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(
                          '${AppStrings.block.tr()} ${chat.nameOnContact}',
                          style: TextStyle(
                            color: AppColors.red,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                      Divider(color: AppColors.grey, indent: 36.w, height: 0),
                      ListTile(
                        title: Text(
                          '${AppStrings.report.tr()} ${chat.nameOnContact}',
                          style: TextStyle(
                            color: AppColors.red,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
