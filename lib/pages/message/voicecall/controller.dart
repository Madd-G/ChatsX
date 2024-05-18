import 'dart:async';
import 'dart:convert';
import 'package:chatsx/common/apis/apis.dart';
import 'package:chatsx/common/entities/entities.dart';
import 'package:chatsx/common/store/store.dart';
import 'package:chatsx/common/values/server.dart';
import 'package:chatsx/common/values/values.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:just_audio/just_audio.dart';
import 'state.dart';

class VoiceCallViewController extends GetxController {
  final VoiceCallState state = VoiceCallState();
  final player = AudioPlayer();
  String appId = APPID;
  String title = "Voice Call";
  final db = FirebaseFirestore.instance;
  final profileToken = UserStore.to.profile.token;
  late final RtcEngine engine;

  late final Timer callTimer;
  int callMinute = 0;
  int callSecond = 0;
  int callHour = 0;
  bool isCallTimer = false;

  ChannelProfileType channelProfileType =
      ChannelProfileType.channelProfileCommunication;

  Future<void> _dispose() async {
    if (isCallTimer) {
      callTimer.cancel();
    }
    if (state.callRole == "anchor") {
      addCallTime();
    }
    await player.pause();
    await engine.leaveChannel();
    await engine.release();
    await player.stop();
  }

  Future<void> _initEngine() async {
    await player.setAsset("assets/Sound_Horizon.mp3");
    engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(
      appId: appId,
    ));

    engine.registerEventHandler(RtcEngineEventHandler(
      onError: (ErrorCodeType err, String msg) {
        //logSink.log('[onError] err: $err, msg: $msg');
        debugPrint('[onError] err: $err, msg: $msg');
        // if(err!=ErrorCodeType.errOk){
        // Get.snackbar(
        //     "call error, confirm return！",
        //     "${msg}",
        //     duration: Duration(seconds: 60),
        //     isDismissible: false,
        //     mainButton: TextButton(
        //         onPressed: () {
        //           if (Get.isSnackbarOpen) {
        //             Get.closeAllSnackbars();
        //           }
        //           Get.offAndToNamed(AppRoutes.Message);
        //         },
        //         child: Container(
        //           width: 40.w,
        //           height: 40.w,
        //           padding: EdgeInsets.all(10.w),
        //           decoration: BoxDecoration(
        //             color: AppColors.primaryElementBg,
        //             borderRadius:
        //             BorderRadius.all(Radius.circular(30.w)),
        //           ),
        //           child: Image.asset("assets/icons/back.png"),
        //         )));
        // }
      },
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        debugPrint(
            '[onJoinChannelSuccess] connection: ${connection.toJson()} elapsed: $elapsed');
        state.isJoined.value = true;
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        debugPrint(
            '[onLeaveChannel] connection: ${connection.toJson()} stats: ${stats.toJson()}');
        state.isJoined.value = false;
      },
      onUserJoined:
          (RtcConnection connection, int remoteUid, int elapsed) async {
        await player.pause();
        if (state.callRole == "anchor") {
          // callTime();
          isCallTimer = true;
        }
      },
      onRtcStats: (RtcConnection connection, RtcStats stats) {
        debugPrint("time----- ");
        debugPrint('${stats.duration}');
      },
      onUserOffline: (RtcConnection connection, int remoteUid,
          UserOfflineReasonType reason) {
        debugPrint("---onUserOffline----- ");
      },
    ));

    await engine.enableAudio();
    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine.setAudioProfile(
      profile: AudioProfileType.audioProfileDefault,
      scenario: AudioScenarioType.audioScenarioGameStreaming,
    );
    // is anchor joinChannel
    await joinChannel();
    if (state.callRole == "anchor") {
      await sendNotification("voice");
      await player.play();
    }
  }

  // callTime() async {
  //   callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
  //     callSecond = callSecond + 1;
  //     if (callSecond >= 60) {
  //       callSecond = 0;
  //       callMinute = callMinute + 1;
  //     }
  //     if (callMinute >= 60) {
  //       callMinute = 0;
  //       callHour = callHour + 1;
  //     }
  //     var h = callHour < 10 ? "0$callHour" : "$callHour";
  //     var m = callMinute < 10 ? "0$callMinute" : "$callMinute";
  //     var s = callSecond < 10 ? "0$callSecond" : "$callSecond";
  //
  //     if (callHour == 0) {
  //       state.callTime.value = "$m:$s";
  //       state.callTimeNum.value = "$callMinute m and $callSecond s";
  //     } else {
  //       state.callTime.value = "$h:$m:$s";
  //       state.callTimeNum.value = "$callHour h $callMinute m and $callSecond s";
  //     }
  //   });
  // }

  Future<String> getToken() async {
    // who is the caller
    if (state.callRole == "anchor") {
      state.channelId.value = md5.convert(utf8.encode("${profileToken}_${state.toToken}")).toString();
    } else {
      state.channelId.value = md5.convert(utf8.encode("${state.toToken}_$profileToken")).toString();
    }
    CallTokenRequestEntity callTokenRequestEntity = CallTokenRequestEntity();
    callTokenRequestEntity.channelName = state.channelId.value;
    var res = await ChatAPI.callToken(params: callTokenRequestEntity);
    if (res.code == 0) {
      return res.data!;
    }
    return "";
  }

  addCallTime() async {
    var profile = UserStore.to.profile;
    var msgdata = ChatCall(
      fromToken: profile.token,
      toToken: state.toToken.value,
      fromName: profile.name,
      toName: state.toName.value,
      fromAvatar: profile.avatar,
      toAvatar: state.toAvatar.value,
      callTime: state.callTimeNum.value,
      type: "voice",
      lastTime: Timestamp.now(),
    );
    var docRes = await db
        .collection("chatcall")
        .withConverter(
          fromFirestore: ChatCall.fromFirestore,
          toFirestore: (ChatCall msg, options) => msg.toFirestore(),
        )
        .add(msgdata);
    String sendContent = "Call time ${state.callTimeNum.value} 【voice】";
    sendMessage(sendContent);
  }

  sendMessage(String sendContent) async {
    if (state.docId.value.isEmpty) {
      return;
    }
    final content = Msgcontent(
      token: profileToken,
      content: sendContent,
      type: "text",
      addtime: Timestamp.now(),
    );

    await db
        .collection("message")
        .doc(state.docId.value)
        .collection("msglist")
        .withConverter(
          fromFirestore: Msgcontent.fromFirestore,
          toFirestore: (Msgcontent msgcontent, options) =>
              msgcontent.toFirestore(),
        )
        .add(content);
    var message_res = await db
        .collection("message")
        .doc(state.docId.value)
        .withConverter(
          fromFirestore: Msg.fromFirestore,
          toFirestore: (Msg msg, options) => msg.toFirestore(),
        )
        .get();
    if (message_res.data() != null) {
      var item = message_res.data()!;
      int toMessageNum = item.toMessageNum == null ? 0 : item.toMessageNum!;
      int fromMessageNum =
          item.fromMessageNum == null ? 0 : item.fromMessageNum!;
      if (item.fromToken == profileToken) {
        fromMessageNum = fromMessageNum + 1;
      } else {
        toMessageNum = toMessageNum + 1;
      }
      await db.collection("message").doc(state.docId.value).update({
        "to_msg_num": toMessageNum,
        "from_msg_num": fromMessageNum,
        "last_msg": sendContent,
        "last_time": Timestamp.now()
      });
    }
  }

  joinChannel() async {
    await Permission.microphone.request();

    EasyLoading.show(
        indicator: const CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: true);
    String token = await getToken();
    if (token.isEmpty) {
      EasyLoading.dismiss();
      Get.back();
      return;
    }
    debugPrint('debug: state.channelId.value: ${state.channelId.value}');
    await engine.joinChannel(
        token: token,
        channelId: state.channelId.value,
        uid: 0,
        options: ChannelMediaOptions(
          channelProfile: channelProfileType,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ));
    if (state.callRole == "audience") {
      // callTime();
      isCallTimer = true;
    }
    EasyLoading.dismiss();
  }

  // send notification
  sendNotification(String callType) async {
    CallRequestEntity callRequestEntity = CallRequestEntity();
    callRequestEntity.callType = callType;
    callRequestEntity.toToken = state.toToken.value;
    callRequestEntity.toAvatar = state.toAvatar.value;
    callRequestEntity.docId = state.docId.value;
    callRequestEntity.toName = state.toName.value;
    debugPrint('... the other user\'s token is ${state.toToken.value}');
    var res = await ChatAPI.callNotifications(params: callRequestEntity);
    debugPrint('... res: $res');
    if (res.code == 0) {
      debugPrint("send notifications success");
    } else {
      debugPrint('could not send notification');
      // Get.snackbar("Tips", "Notification error!");
      // Get.offAllNamed(AppRoutes.Message);
    }
  }

  leaveChannel() async {
    EasyLoading.show(
        indicator: const CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: true);
    await player.pause();
    // await sendNotifications("cancel");
    // TODO: try leaveChannel
    //  await engine.leaveChannel();
    state.isJoined.value = false;
    state.openMicrophone.value = true;
    state.enableSpeakerphone.value = true;
    EasyLoading.dismiss();
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    Get.back();
  }

  switchMicrophone() async {
    await engine.enableLocalAudio(!state.openMicrophone.value);
    state.openMicrophone.value = !state.openMicrophone.value;
  }

  switchSpeakerphone() async {
    await engine.setEnableSpeakerphone(!state.enableSpeakerphone.value);
    state.enableSpeakerphone.value = !state.enableSpeakerphone.value;
  }

  @override
  void onInit() {
    super.onInit();
    var data = Get.parameters;
    debugPrint('$data');
    state.toToken.value = data["to_token"] ?? "";
    state.toName.value = data["to_name"] ?? "";
    state.toAvatar.value = data["to_avatar"] ?? "";
    state.callRole.value = data["call_role"] ?? "";
    state.docId.value = data["doc_id"] ?? "";
    _initEngine();
  }

  @override
  void onClose() {
    super.onClose();
    _dispose();
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }
}
