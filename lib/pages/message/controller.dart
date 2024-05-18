import 'dart:convert';
import 'package:chatsx/common/apis/apis.dart';
import 'package:chatsx/common/routes/names.dart';
import 'package:chatsx/common/values/values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'state.dart';
import 'package:chatsx/common/entities/entities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatsx/common/store/store.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessageController extends GetxController with WidgetsBindingObserver {
  MessageController();

  final MessageState state = MessageState();
  final token = UserStore.to.profile.token;
  final db = FirebaseFirestore.instance;

  goProfile() async {
    var result = await Get.toNamed(AppRoutes.Profile,
        arguments: state.head_detail.value);
    if (result == "finish") {
      getProfile();
    }
  }

  goTabStatus() async {
    EasyLoading.show(
        indicator: const CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: true);
    state.tabStatus.value = !state.tabStatus.value;
    if (state.tabStatus.value) {
      asyncLoadMsgData();
    } else {
      asyncLoadCallData();
    }
    EasyLoading.dismiss();
  }

  asyncLoadMsgData() async {
    debugPrint("-----------state.msgList.value");
    debugPrint('${state.msgList.value}');
    var token = UserStore.to.profile.token;

    var fromMessages = await db
        .collection("message")
        .withConverter(
          fromFirestore: Msg.fromFirestore,
          toFirestore: (Msg msg, options) => msg.toFirestore(),
        )
        .where("from_token", isEqualTo: token)
        .get();
    debugPrint('${fromMessages.docs.length}');

    var toMessages = await db
        .collection("message")
        .withConverter(
          fromFirestore: Msg.fromFirestore,
          toFirestore: (Msg msg, options) => msg.toFirestore(),
        )
        .where("to_token", isEqualTo: token)
        .get();
    debugPrint("toMessages.docs.length------------");
    debugPrint('${toMessages.docs.length}');
    state.msgList.clear();

    if (fromMessages.docs.isNotEmpty) {
      await addMessage(fromMessages.docs);
    }
    if (toMessages.docs.isNotEmpty) {
      await addMessage(toMessages.docs);
    }
    // sort
    state.msgList.value.sort((a, b) {
      if (b.lastTime == null) {
        return 0;
      }
      if (a.lastTime == null) {
        return 0;
      }
      return b.lastTime!.compareTo(a.lastTime!);
    });
  }

  addMessage(List<QueryDocumentSnapshot<Msg>> data) async {
    data.forEach((element) {
      var item = element.data();
      Message message = Message();
      message.docId = element.id;
      message.lastTime = item.lastTime;
      message.messageNum = item.messageNum;
      message.lastMessage = item.lastMessage;
      if (item.fromToken == token) {
        message.name = item.toName;
        message.avatar = item.toAvatar;
        message.token = item.toToken;
        message.online = item.toOnline;
        message.messageNum = item.toMessageNum ?? 0;
      } else {
        message.name = item.fromName;
        message.avatar = item.fromAvatar;
        message.token = item.fromToken;
        message.online = item.fromOnline;
        message.messageNum = item.fromMessageNum ?? 0;
      }
      state.msgList.add(message);
    });
  }

  _snapshots() async {
    var token = UserStore.to.profile.token;
    debugPrint("token--------");
    debugPrint(token);

    final toMessageRef = db
        .collection("message")
        .withConverter(
          fromFirestore: Msg.fromFirestore,
          toFirestore: (Msg msg, options) => msg.toFirestore(),
        )
        .where("to_token", isEqualTo: token);
    final fromMessageRef = db
        .collection("message")
        .withConverter(
          fromFirestore: Msg.fromFirestore,
          toFirestore: (Msg msg, options) => msg.toFirestore(),
        )
        .where("from_token", isEqualTo: token);
    toMessageRef.snapshots().listen(
      (event) async {
        debugPrint("snapshotslisten-----------");
        debugPrint('${event.metadata.isFromCache}');
        await asyncLoadMsgData();
        // if(!event.metadata.isFromCache){
        //
        // }
        debugPrint("snapshotslisten-----------");
      },
      onError: (error) => debugPrint("Listen failed: $error"),
    );
    fromMessageRef.snapshots().listen(
      (event) async {
        debugPrint("snapshotslisten-----------");
        debugPrint('${event.metadata.isFromCache}');
        await asyncLoadMsgData();
        debugPrint("snapshotslisten-----------");
      },
      onError: (error) => debugPrint("Listen failed: $error"),
    );
  }

  asyncLoadCallData() async {
    state.callList.clear();
    var token = UserStore.to.profile.token;

    var from_chatcall = await db
        .collection("chatcall")
        .withConverter(
          fromFirestore: ChatCall.fromFirestore,
          toFirestore: (ChatCall msg, options) => msg.toFirestore(),
        )
        .where("from_token", isEqualTo: token)
        .limit(30)
        .get();
    var to_chatcall = await db
        .collection("chatcall")
        .withConverter(
          fromFirestore: ChatCall.fromFirestore,
          toFirestore: (ChatCall msg, options) => msg.toFirestore(),
        )
        .where("to_token", isEqualTo: token)
        .limit(30)
        .get();

    if (from_chatcall.docs.isNotEmpty) {
      await addCall(from_chatcall.docs);
    }
    if (to_chatcall.docs.isNotEmpty) {
      await addCall(to_chatcall.docs);
    }
    // sort
    state.callList.value.sort((a, b) {
      if (b.lastTime == null) {
        return 0;
      }
      if (a.lastTime == null) {
        return 0;
      }
      return b.lastTime!.compareTo(a.lastTime!);
    });
  }

  addCall(List<QueryDocumentSnapshot<ChatCall>> data) async {
    data.forEach((element) {
      var item = element.data();
      CallMessage message = CallMessage();
      message.docId = element.id;
      message.lastTime = item.lastTime;
      message.callTime = item.callTime;
      message.type = item.type;
      if (item.fromToken == token) {
        message.name = item.toName;
        message.avatar = item.toAvatar;
        message.token = item.toToken;
      } else {
        message.name = item.fromName;
        message.avatar = item.fromAvatar;
        message.token = item.fromToken;
      }
      state.callList.add(message);
    });
  }

  getProfile() async {
    var profile = await UserStore.to.profile;
    debugPrint('$profile');
    state.head_detail.value = profile;
    state.head_detail.refresh();
  }

  firebaseMessageSetup() async {
    // fcm token = device token
    String? fcmToken = await FirebaseMessaging.instance.getToken();
    debugPrint('fcm token is: $fcmToken');

    if (fcmToken != null) {
      BindFcmTokenRequestEntity bindFcmTokenRequestEntity = BindFcmTokenRequestEntity();
      bindFcmTokenRequestEntity.fcmtoken = fcmToken;
      await ChatAPI.bindFCMtoken(params: bindFcmTokenRequestEntity);
    }
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
      debugPrint("\n notification on onMessageOpenedApp function \n");
      debugPrint('${message.data}');
      if (message.data != null && message.data["call_type"] != null) {
        //  ////1. voice 2. video 3. text, 4.cancel
        if (message.data["call_type"] == "text") {
          //  FirebaseMessagingHandler.flutterLocalNotificationsPlugin.cancelAll();
          var data = message.data;
          var toToken = data["token"];
          var toName = data["name"];
          var toAvatar = data["avatar"];
          //  var doc_id = data["doc_id"];
          if (toToken != null && toName != null && toAvatar != null) {
            var item = state.msgList.value
                .where((element) => element.token == toToken)
                .first;
            debugPrint('$item');
            if (item != null && Get.currentRoute.contains(AppRoutes.Message)) {
              Get.toNamed("/chat", parameters: {
                "doc_id": item.docId!,
                "to_token": item.token!,
                "to_name": item.name!,
                "to_avatar": item.avatar!,
                "to_online": item.online.toString()
              });
            }
          }
        }
      }
    });
  }

  sendNotifications(String callType, String toToken, String toAvatar,
      String toName, String docId) async {
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

  @override
  void onInit() {
    super.onInit();
    getProfile();
    _snapshots();
  }

  @override
  void onReady() async {
    super.onReady();
    firebaseMessageSetup();
    WidgetsBinding.instance.addObserver(this);
    await callVoiceOrVideo();
  }

  @override
  void onClose() {
    super.onClose();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    debugPrint("-didChangeAppLifecycleState-" + state.toString());
    switch (state) {
      case AppLifecycleState.inactive:
        debugPrint("AppLifecycleState.inactive-----");
        break;
      case AppLifecycleState.resumed:
        debugPrint("AppLifecycleState.resumed------");
        await callVoiceOrVideo();
        break;
      case AppLifecycleState.paused:
        debugPrint("AppLifecycleState.paused-----");
        break;
      case AppLifecycleState.detached:
        debugPrint("AppLifecycleState.detached------");
        break;
      case AppLifecycleState.hidden:
      // TODO: Handle this case.
    }
  }

  callVoiceOrVideo() async {
    var _prefs = await SharedPreferences.getInstance();
    await _prefs.reload();
    var res = await _prefs.getString("CallVoiceOrVideo") ?? "";
    debugPrint(res);
    if (res.isNotEmpty) {
      var data = jsonDecode(res);
      await _prefs.setString("CallVoiceOrVideo", "");
      debugPrint(data);
      // "call_role":"audience",
      String toToken = data["to_token"];
      String toName = data["to_name"];
      String toAvatar = data["to_avatar"];
      String callType = data["call_type"];
      String docId = data["doc_id"] ?? "";
      DateTime expireTime = DateTime.parse(data["expire_time"]);
      DateTime nowTime = DateTime.now();
      var seconds = nowTime.difference(expireTime).inSeconds;
      debugPrint("Seconds------");
      debugPrint('$seconds');

      if (seconds < 30) {
        String title = "";
        String appRoute = "";
        if (callType == "voice") {
          title = "Voice call";
          appRoute = AppRoutes.VoiceCall;
        } else {
          title = "Video call";
          appRoute = AppRoutes.VideoCall;
        }

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
          toName,
          title,
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
                      sendNotifications(
                          "cancel", toToken, toAvatar, toName, docId);
                    },
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryElementBg,
                        borderRadius: BorderRadius.all(Radius.circular(30.w)),
                      ),
                      child: Image.asset("assets/icons/a_phone.png"),
                    ),
                  ),
                  GestureDetector(
                      onTap: () {
                        if (Get.isSnackbarOpen) {
                          Get.closeAllSnackbars();
                        }
                        Get.toNamed(appRoute, parameters: {
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
                          borderRadius: BorderRadius.all(Radius.circular(30.w)),
                        ),
                        child: Image.asset("assets/icons/a_telephone.png"),
                      ))
                ],
              ),
            ),
          ),
        );
      }
    }
  }
}
