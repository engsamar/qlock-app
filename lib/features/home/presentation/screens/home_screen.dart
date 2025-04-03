import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:q_lock/core/constants/custom_icons.dart';
import 'package:q_lock/core/widgets/gradient_background.dart';
import 'package:q_lock/features/home/presentation/widgets/settings_content.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/routes/app_routes.dart';
import '../widgets/chats_content.dart';
import '../widgets/profile_content.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedBottomIndex = 0;

  final List<Widget> _screens = [
    ChatsContent(),
    ProfileContent(),
    SettingsContent(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(child: _screens[_selectedBottomIndex]),
      ),
      floatingActionButton:
          _selectedBottomIndex == 0
              ? FloatingActionButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.contacts);
                },
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person_add, color: AppColors.white),
              )
              : null,
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            _selectedBottomIndex = value;
          });
        },
        currentIndex: _selectedBottomIndex,
        backgroundColor: AppColors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Icon(CustomIcons.chats),
            label: AppStrings.chats.tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomIcons.profile),
            label: AppStrings.profile.tr(),
          ),
          BottomNavigationBarItem(
            icon: Icon(CustomIcons.settings),
            label: AppStrings.settings.tr(),
          ),
        ],
      ),
    );
  }
}
