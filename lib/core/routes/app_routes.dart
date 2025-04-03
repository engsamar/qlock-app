import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:q_lock/features/home/presentation/screens/contacts_screen.dart';
import 'package:q_lock/features/home/presentation/screens/home_screen.dart';

import '../../features/auth/presentation/screens/complete_profile_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/chat/presentation/views/chat_view.dart';
import '../../features/home/data/models/room_model.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../constants/app_strings.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String completeProfile = '/complete-profile';
  static const String home = '/home';
  static const String contacts = '/contacts';
  static const String chat = '/chat';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case otp:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder:
              (_) => OTPScreen(
                phoneNumber: args['phoneNumber'],
                code: args['code'],
              ),
        );
      case completeProfile:
        return MaterialPageRoute(builder: (_) => CompleteProfileScreen());
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case contacts:
        return MaterialPageRoute(builder: (_) => ContactsScreen());
      case chat:
        final args = settings.arguments as RoomModel;
        return MaterialPageRoute(builder: (_) => ChatView(chat: args));
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(child: Text(AppStrings.routeNotFound.tr())),
              ),
        );
    }
  }
}
