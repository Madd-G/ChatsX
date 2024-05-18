import 'dart:convert';
import 'package:chatsx/common/apis/apis.dart';
import 'package:chatsx/common/entities/entities.dart';
import 'package:chatsx/common/routes/names.dart';
import 'package:chatsx/common/store/store.dart';
import 'package:chatsx/common/values/values.dart';
import 'package:chatsx/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseMessagingHandler {
  FirebaseMessagingHandler._();

  static AndroidNotificationChannel channelCall =
      const AndroidNotificationChannel(
    'com.alamsyah.chatsx.call', // id
    'ChatsX call', // will show when enable or disable permission on device settings
    importance: Importance.max,
    enableLights: true,
    playSound: true,
    sound: RawResourceAndroidNotificationSound('alert'),
    enableVibration: true,
  );
  static AndroidNotificationChannel channelMessage =
      const AndroidNotificationChannel(
    'com.alamsyah.chatsx.message', // id
    'ChatsX message', // title
    importance: Importance.defaultImportance,
    enableLights: true,
    playSound: true,
    // sound: RawResourceAndroidNotificationSound('alert'),
    enableVibration: true,
  );

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> config() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    try {
      await messaging.requestPermission(
        sound: true,
        badge: true,
        alert: true,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
      );

      // only get called when app terminated
      // have issue with some android phone
      RemoteMessage? initialMessage =
          await FirebaseMessaging.instance.getInitialMessage();
      if (initialMessage != null) {
        debugPrint("initialMessage------");
        debugPrint('$initialMessage');
      }

      /// pop up notification / showing the tray
      var initializationSettingsAndroid =
          const AndroidInitializationSettings("ic_launcher");
      var darwinInitializationSettings = const DarwinInitializationSettings();
      var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: darwinInitializationSettings,
      );
      flutterLocalNotificationsPlugin.initialize(initializationSettings,
          onDidReceiveNotificationResponse: (value) {
        debugPrint("----------onDidReceiveNotificationResponse");
      });

      // for iOS
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
              alert: true, badge: true, sound: true);

      /// when app on the foreground
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        debugPrint("\n notification on onMessage function \n");
        debugPrint('$message');
        _receiveNotification(message);
      });
    } on Exception catch (e) {
      debugPrint("$e");
    }
  }

  static Future<void> _receiveNotification(RemoteMessage message) async {
    if (message.data["call_type"] != null) {
      //  ////1. voice 2. video 3. text, 4.cancel
      if (message.data["call_type"] == "voice") {
        //  FirebaseMessagingHandler.flutterLocalNotificationsPlugin.cancelAll();
        var data = message.data;
        var toToken = data["token"];
        var toName = data["name"];
        var toAvatar = data["avatar"];
        var docId = data["doc_id"] ?? "";
        var call_role = data["call_type"];
        if (toToken != null && toName != null && toAvatar != null) {
          // it shows the notification tray
          Get.snackbar(
              icon: Container(
                width: 40.w,
                height: 40.w,
                padding: EdgeInsets.all(0.w),
                decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill, image: NetworkImage(toAvatar)),
                  borderRadius: BorderRadius.all(Radius.circular(20.w)),
                ),
              ),
              "$toName",
              "Voice call",
              duration: const Duration(seconds: 30),
              isDismissible: false,
              mainButton: TextButton(
                  onPressed: () {},
                  child: SizedBox(
                      width: 90.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (Get.isSnackbarOpen) {
                                Get.closeAllSnackbars();
                              }
                              FirebaseMessagingHandler._sendNotifications(
                                  "cancel", toToken, toAvatar, toName, docId);
                            },
                            child: Container(
                              width: 40.w,
                              height: 40.w,
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: AppColors.primaryElementBg,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.w)),
                              ),
                              child: Image.asset("assets/icons/a_phone.png"),
                            ),
                          ),
                          GestureDetector(
                              onTap: () {
                                if (Get.isSnackbarOpen) {
                                  Get.closeAllSnackbars();
                                }
                                Get.toNamed(AppRoutes.VoiceCall, parameters: {
                                  "to_token": toToken,
                                  "to_name": toName,
                                  "to_avatar": toAvatar,
                                  "doc_id": docId,
                                  "call_role": "audience"
                                });
                              },
                              child: Container(
                                width: 40.w,
                                height: 40.w,
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryElementStatus,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.w)),
                                ),
                                child:
                                    Image.asset("assets/icons/a_telephone.png"),
                              ))
                        ],
                      ))));
        }
      } else if (message.data["call_type"] == "video") {
        //    FirebaseMessagingHandler.flutterLocalNotificationsPlugin.cancelAll();
        //  ////1. voice 2. video 3. text, 4.cancel
        var data = message.data;
        var toToken = data["token"];
        var toName = data["name"];
        var toAvatar = data["avatar"];
        var docId = data["doc_id"] ?? "";
        // var call_role= data["call_type"];
        if (toToken != null && toName != null && toAvatar != null) {
          ConfigStore.to.isCallVoice = true;
          Get.snackbar(
              icon: Container(
                width: 40.w,
                height: 40.w,
                padding: EdgeInsets.all(0.w),
                decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill, image: NetworkImage(toAvatar)),
                  borderRadius: BorderRadius.all(Radius.circular(20.w)),
                ),
              ),
              "$toName",
              "Video call",
              duration: const Duration(seconds: 30),
              isDismissible: false,
              mainButton: TextButton(
                  onPressed: () {},
                  child: SizedBox(
                      width: 90.w,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (Get.isSnackbarOpen) {
                                Get.closeAllSnackbars();
                              }
                              FirebaseMessagingHandler._sendNotifications(
                                  "cancel", toToken, toAvatar, toName, docId);
                            },
                            child: Container(
                              width: 40.w,
                              height: 40.w,
                              padding: EdgeInsets.all(10.w),
                              decoration: BoxDecoration(
                                color: AppColors.primaryElementBg,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30.w)),
                              ),
                              child: Image.asset("assets/icons/a_phone.png"),
                            ),
                          ),
                          GestureDetector(
                              onTap: () {
                                if (Get.isSnackbarOpen) {
                                  Get.closeAllSnackbars();
                                }
                                Get.toNamed(AppRoutes.VideoCall, parameters: {
                                  "to_token": toToken,
                                  "to_name": toName,
                                  "to_avatar": toAvatar,
                                  "doc_id": docId,
                                  "call_role": "audience"
                                });
                              },
                              child: Container(
                                width: 40.w,
                                height: 40.w,
                                padding: EdgeInsets.all(10.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryElementStatus,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.w)),
                                ),
                                child:
                                    Image.asset("assets/icons/a_telephone.png"),
                              ))
                        ],
                      ))));
        }
      } else if (message.data["call_type"] == "cancel") {
        FirebaseMessagingHandler.flutterLocalNotificationsPlugin.cancelAll();

        if (Get.isSnackbarOpen) {
          Get.closeAllSnackbars();
        }

        if (Get.currentRoute.contains(AppRoutes.VoiceCall) ||
            Get.currentRoute.contains(AppRoutes.VideoCall)) {
          Get.back();
        }

        var prefs = await SharedPreferences.getInstance();
        await prefs.setString("CallVoiceOrVideo", "");
      }
    }
  }

  static Future<void> _sendNotifications(String callType, String toToken,
      String toAvatar, String toName, String docId) async {
    CallRequestEntity callRequestEntity = CallRequestEntity();
    callRequestEntity.callType = callType;
    callRequestEntity.toToken = toToken;
    callRequestEntity.toAvatar = toAvatar;
    callRequestEntity.docId = docId;
    callRequestEntity.toName = toName;
    var res = await ChatAPI.callNotifications(params: callRequestEntity);
    debugPrint("sendNotifications");
    debugPrint('$res');
    if (res.code == 0) {
      debugPrint("sendNotifications success");
    } else {
      // Get.snackbar("Tips", "Notification error!");
      // Get.offAllNamed(AppRoutes.Message);
    }
  }

  static Future<void> _showNotification({RemoteMessage? message}) async {
    RemoteNotification? notification = message!.notification;
    AndroidNotification? androidNotification = message.notification!.android;
    AppleNotification? appleNotification = message.notification!.apple;

    if (notification != null &&
        (androidNotification != null || appleNotification != null)) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelMessage.id,
            channelMessage.name,
            icon: "@mipmap/ic_launcher",
            playSound: true,
            enableVibration: true,
            priority: Priority.defaultPriority,
            // channelShowBadge: true,
            importance: Importance.defaultImportance,
            // sound: RawResourceAndroidNotificationSound('alert'),
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
    // PlascoRequests().initReport();
  }

  /// handler when app is in the background to show the notification
  /// and awake the app when click on it
  ///
  /// pragma to make this code priority and accessible from native code
  /// to keep it always alive and ready
  ///
  /// Don't have to use pragma if the function is at the top (outside) of main() function
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackground(RemoteMessage message) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("message data: ${message.data}");
    debugPrint("message data: $message");
    debugPrint("message data: ${message.notification}");

    if (message.data["call_type"] != null) {
      if (message.data["call_type"] == "cancel") {
        FirebaseMessagingHandler.flutterLocalNotificationsPlugin.cancelAll();
        //  await setCallVoiceOrVideo(false);
        var prefs = await SharedPreferences.getInstance();
        await prefs.setString("CallVoiceOrVideo", "");
      }
      if (message.data["call_type"] == "voice" ||
          message.data["call_type"] == "video") {
        var data = {
          "to_token": message.data["token"],
          "to_name": message.data["name"],
          "to_avatar": message.data["avatar"],
          "doc_id": message.data["doc_id"] ?? "",
          "call_type": message.data["call_type"],
          "expire_time": DateTime.now().toString(),
        };
        debugPrint('$data');
        var _prefs = await SharedPreferences.getInstance();
        await _prefs.setString("CallVoiceOrVideo", jsonEncode(data));
      }
    }
  }
}
