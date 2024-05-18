import 'package:chatsx/pages/frame/email_login/index.dart';
import 'package:chatsx/pages/frame/forgot/index.dart';
import 'package:chatsx/pages/frame/phone/index.dart';
import 'package:chatsx/pages/frame/register/index.dart';
import 'package:chatsx/pages/frame/send_code/index.dart';
import 'package:chatsx/pages/message/photoview/binding.dart';
import 'package:chatsx/pages/message/photoview/view.dart';
import 'package:chatsx/pages/message/videocall/index.dart';
import 'package:chatsx/pages/message/voicecall/index.dart';
import 'package:chatsx/pages/profile/index.dart';
import 'package:flutter/material.dart';
import 'package:chatsx/common/middlewares/middlewares.dart';
import 'package:chatsx/pages/contact/index.dart';
import 'package:chatsx/pages/message/chat/index.dart';
import 'package:chatsx/pages/message/index.dart';
import 'package:chatsx/pages/frame/sign_in/index.dart';
import 'package:chatsx/pages/frame/welcome/index.dart';
import 'package:get/get.dart';

import 'routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.INITIAL;
  static final RouteObserver<Route> observer = RouteObservers();
  static List<String> history = [];

  static final List<GetPage> routes = [
    GetPage(
      name: AppRoutes.INITIAL,
      page: () => const WelcomePage(),
      binding: WelcomeBinding(),
    ),
    GetPage(
      name: AppRoutes.SIGN_IN,
      page: () => const SignInPage(),
      binding: SignInBinding(),
    ),

    // GetPage(
    //   name: AppRoutes.Application,
    //   page: () => ApplicationPage(),
    //   binding: ApplicationBinding(),
    //   middlewares: [
    //     RouteAuthMiddleware(priority: 1),
    //   ],
    // ),

    GetPage(name: AppRoutes.EmailLogin, page: () => const EmailLoginPage(), binding: EmailLoginBinding()),
    GetPage(name: AppRoutes.Register, page: () => const RegisterPage(), binding: RegisterBinding()),
    GetPage(name: AppRoutes.Forgot, page: () => const ForgotPage(), binding: ForgotBinding()),
    GetPage(name: AppRoutes.Phone, page: () => const PhonePage(), binding: PhoneBinding()),
    GetPage(name: AppRoutes.SendCode, page: () => const SendCodePage(), binding: SendCodeBinding()),
    GetPage(name: AppRoutes.Contact, page: () => const ContactPage(), binding: ContactBinding()),
    GetPage(name: AppRoutes.Message, page: () => const MessagePage(), binding: MessageBinding(),middlewares: [
       RouteAuthMiddleware(priority: 1),
     ],),
    GetPage(name: AppRoutes.Profile, page: () => const ProfilePage(), binding: ProfileBinding()),
    GetPage(name: AppRoutes.Chat, page: () => const ChatPage(), binding: ChatBinding()),
    GetPage(name: AppRoutes.Photoimgview, page: () => const PhotoImgViewPage(), binding: PhotoImgViewBinding()),
    GetPage(name: AppRoutes.VoiceCall, page: () => VoiceCallViewPage(), binding: VoiceCallViewBinding()),
    GetPage(name: AppRoutes.VideoCall, page: () => const VideoCallPage(), binding: VideoCallBinding()),
  ];






}
