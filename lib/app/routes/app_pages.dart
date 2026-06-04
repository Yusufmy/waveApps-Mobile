import 'package:get/get.dart';

import '../modules/CallScreen/bindings/call_screen_binding.dart';
import '../modules/CallScreen/views/call_screen_view.dart';
import '../modules/ChatScreen/ChatDetailScreen/CallDetailScreen/bindings/call_detail_screen_binding.dart';
import '../modules/ChatScreen/ChatDetailScreen/CallDetailScreen/views/call_detail_screen_view.dart';
import '../modules/ChatScreen/ChatDetailScreen/bindings/chat_screen_chat_detail_screen_binding.dart';
import '../modules/ChatScreen/ChatDetailScreen/views/chat_screen_chat_detail_screen_view.dart';
import '../modules/ChatScreen/SearchUserScreen/bindings/chat_screen_search_user_screen_binding.dart';
import '../modules/ChatScreen/SearchUserScreen/views/chat_screen_search_user_screen_view.dart';
import '../modules/ChatScreen/bindings/chat_screen_binding.dart';
import '../modules/ChatScreen/views/chat_screen_tab.dart';
import '../modules/ChatScreen/views/chat_screen_view.dart';
import '../modules/ProfileScreen/ChangeProfileScreen/bindings/profile_screen_change_profile_screen_binding.dart';
import '../modules/ProfileScreen/ChangeProfileScreen/views/profile_screen_change_profile_screen_view.dart';
import '../modules/ProfileScreen/bindings/profile_screen_binding.dart';
import '../modules/ProfileScreen/views/profile_screen_view.dart';
import '../modules/SplashScreen/bindings/splash_screen_binding.dart';
import '../modules/SplashScreen/views/splash_screen_view.dart';
import '../modules/WelcomeScreen/bindings/welcome_screen_binding.dart';
import '../modules/WelcomeScreen/views/welcome_screen_view.dart';
import '../modules/auth/LoginScreen/bindings/login_screen_binding.dart';
import '../modules/auth/LoginScreen/views/login_screen_view.dart';
import '../modules/auth/RegisterScreen/bindings/register_screen_binding.dart';
import '../modules/auth/RegisterScreen/views/register_screen_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH_SCREEN;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH_SCREEN,
      page: () => const SplashScreenView(),
      binding: SplashScreenBinding(),
    ),
    GetPage(
      name: _Paths.CHAT_SCREEN,
      page: () => const ChatScreenTab(),
      binding: ChatScreenBinding(),
      children: [
        GetPage(
          name: _Paths.CHAT_DETAIL_SCREEN,
          page: () => const ChatScreenChatDetailScreenView(),
          binding: ChatScreenChatDetailScreenBinding(),
          transition: Transition.downToUp,
          children: [
            GetPage(
              name: _Paths.CALL_DETAIL_SCREEN,
              page: () => const CallDetailScreenView(),
              binding: CallDetailScreenBinding(),
            ),
          ],
        ),
        GetPage(
          name: _Paths.SEARCH_USER_SCREEN,
          page: () => const ChatScreenSearchUserScreenView(),
          binding: ChatScreenSearchUserScreenBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.LOGIN_SCREEN,
      page: () => const LoginScreenView(),
      binding: LoginScreenBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER_SCREEN,
      page: () => const RegisterScreenView(),
      binding: RegisterScreenBinding(),
    ),
    GetPage(
      name: _Paths.CALL_SCREEN,
      page: () => const CallScreenView(),
      binding: CallScreenBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE_SCREEN,
      page: () => const ProfileScreenView(),
      binding: ProfileScreenBinding(),
      children: [
        GetPage(
          name: _Paths.CHANGE_PROFILE_SCREEN,
          page: () => const ProfileScreenChangeProfileScreenView(),
          binding: ProfileScreenChangeProfileScreenBinding(),
        ),
      ],
    ),
    GetPage(
      name: _Paths.WELCOME_SCREEN,
      page: () => const WelcomeScreenView(),
      binding: WelcomeScreenBinding(),
    ),
  ];
}
