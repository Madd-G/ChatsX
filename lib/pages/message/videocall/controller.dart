import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
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
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

import 'state.dart';

class VideoCallController extends GetxController {
  final VideoCallState state = VideoCallState();
  late final RtcEngine engine;
  final player = AudioPlayer();

  // 两个人聊天
  ChannelProfileType channelProfileType =
      ChannelProfileType.channelProfileCommunication;
  String appId = APPID;
  final profile_token = UserStore.to.profile.token;
  late final Timer calltimer;
  int call_m = 0;
  int call_s = 0;
  int call_h = 0;
  final db = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    var data = Get.parameters;
    state.toToken.value = data["to_token"] ?? "";
    state.toName.value = data["to_name"] ?? "";
    state.toAvatar.value = data["to_avatar"] ?? "";
    state.callRole.value = data["call_role"] ?? "";
    state.docId.value = data["doc_id"] ?? "";
    _initEngine();
  }

  @override
  void dispose() {
    super.dispose();
    _dispose();
  }

  @override
  void onClose() {
    super.onClose();
    _dispose();
  }

  Future<void> _dispose() async {
    if (calltimer != null) {
      calltimer.cancel();
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
        debugPrint('[onError] err: $err, msg: $msg');
        // if(err!=ErrorCodeType.errOk){
        //   Get.snackbar(
        //       "call error, confirm return！",
        //       "${msg}",
        //       duration: Duration(seconds: 60),
        //       isDismissible: false,
        //       mainButton: TextButton(
        //           onPressed: () {
        //             if (Get.isSnackbarOpen) {
        //               Get.closeAllSnackbars();
        //             }
        //             Get.offAndToNamed(AppRoutes.Message);
        //           },
        //           child: Container(
        //             width: 40.w,
        //             height: 40.w,
        //             padding: EdgeInsets.all(10.w),
        //             decoration: BoxDecoration(
        //               color: AppColors.primaryElementBg,
        //               borderRadius:
        //               BorderRadius.all(Radius.circular(30.w)),
        //             ),
        //             child: Image.asset("assets/icons/back.png"),
        //           )));
        // }
      },
      onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
        debugPrint(
            '[onJoinChannelSuccess] connection: ${connection.toJson()} elapsed: $elapsed');
        state.isJoined.value = true;
      },
      onUserJoined: (RtcConnection connection, int rUid, int elapsed) async {
        debugPrint(
            '[onUserJoined] connection: ${connection.toJson()} remoteUid: $rUid elapsed: $elapsed');
        state.remoteUid.value.add(rUid);
        state.onRemoteUid.value = rUid;
        state.isShowAvatar.value = false;
        await player.pause();
        if (state.callRole == "anchor") {
          callTime();
        }
      },
      onUserOffline:
          (RtcConnection connection, int rUid, UserOfflineReasonType reason) {
        debugPrint(
            '[onUserOffline] connection: ${connection.toJson()}  rUid: $rUid reason: $reason');
        state.remoteUid.value.removeWhere((element) => element == rUid);
        state.onRemoteUid.value = 0;
        state.isShowAvatar.value = true;
        // leaveChannel();
      },
      onLeaveChannel: (RtcConnection connection, RtcStats stats) {
        debugPrint(
            '[onLeaveChannel] connection: ${connection.toJson()} stats: ${stats.toJson()}');
        state.isJoined.value = false;
        state.remoteUid.value.clear();
        state.onRemoteUid.value = 0;
        state.isShowAvatar.value = true;
      },
    ));

    await engine.enableVideo();

    await engine.setVideoEncoderConfiguration(
      const VideoEncoderConfiguration(
        dimensions: VideoDimensions(width: 640, height: 360),
        frameRate: 15,
        bitrate: 0,
      ),
    );

    await engine.startPreview();
    state.isReadyPreview.value = true;
    await joinChannel();
    if (state.callRole == "anchor") {
      await sendNotifications("video");
      await player.play();
    }
  }

  callTime() async {
    calltimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      call_s = call_s + 1;
      if (call_s >= 60) {
        call_s = 0;
        call_m = call_m + 1;
      }
      if (call_m >= 60) {
        call_m = 0;
        call_h = call_h + 1;
      }
      var h = call_h < 10 ? "0$call_h" : "$call_h";
      var m = call_m < 10 ? "0$call_m" : "$call_m";
      var s = call_s < 10 ? "0$call_s" : "$call_s";

      if (call_h == 0) {
        state.callTime.value = "$m:$s";
        state.callTimeNum.value = "$call_m m and $call_s s";
      } else {
        state.callTime.value = "$h:$m:$s";
        state.callTimeNum.value = "$call_h h $call_m m and $call_s s";
      }
    });
  }

  Future<String> getToken() async {
    if (state.callRole == "anchor") {
      state.channelId.value = md5
          .convert(utf8.encode("${profile_token}_${state.toToken}"))
          .toString();
    } else {
      state.channelId.value = md5
          .convert(utf8.encode("${state.toToken}_$profile_token"))
          .toString();
    }
    CallTokenRequestEntity callTokenRequestEntity = CallTokenRequestEntity();
    callTokenRequestEntity.channelName = state.channelId.value;
    log("...channel id is ${state.channelId.value}");
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
      type: "video",
      lastTime: Timestamp.now(),
    );
    var docRes = await db
        .collection("chatcall")
        .withConverter(
          fromFirestore: ChatCall.fromFirestore,
          toFirestore: (ChatCall msg, options) => msg.toFirestore(),
        )
        .add(msgdata);
    String sendContent = "Call time ${state.callTimeNum.value}【video】";
    sendMessage(sendContent);
  }

  sendMessage(String sendContent) async {
    if (state.docId.value.isEmpty) {
      return;
    }
    final content = Msgcontent(
      token: profile_token,
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
      int to_msg_num = item.toMessageNum == null ? 0 : item.toMessageNum!;
      int from_msg_num = item.fromMessageNum == null ? 0 : item.fromMessageNum!;
      if (item.fromToken == profile_token) {
        from_msg_num = from_msg_num + 1;
      } else {
        to_msg_num = to_msg_num + 1;
      }
      await db.collection("message").doc(state.docId.value).update({
        "to_msg_num": to_msg_num,
        "from_msg_num": from_msg_num,
        "last_msg": sendContent,
        "last_time": Timestamp.now()
      });
    }
  }

  Future<void> joinChannel() async {
    await [Permission.microphone, Permission.camera].request();
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
    await engine.joinChannel(
      token: token,
      channelId: state.channelId.value,
      uid: 0,
      options: ChannelMediaOptions(
        channelProfile: channelProfileType,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );

    if (state.callRole == "audience") {
      callTime();
    }
    EasyLoading.dismiss();
  }

  sendNotifications(String call_type) async {
    CallRequestEntity callRequestEntity = CallRequestEntity();
    callRequestEntity.callType = call_type;
    callRequestEntity.toToken = state.toToken.value;
    callRequestEntity.toAvatar = state.toAvatar.value;
    callRequestEntity.docId = state.docId.value;
    callRequestEntity.toName = state.toName.value;
    var res = await ChatAPI.callNotifications(params: callRequestEntity);
    debugPrint('$res');
    if (res.code == 0) {
      debugPrint("sendNotifications success");
    } else {
      //
    }
  }

  Future<void> leaveChannel() async {
    EasyLoading.show(
        indicator: const CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: true);
    await player.pause();
    await sendNotifications("cancel");
    // await engine.leaveChannel();
    state.isJoined.value = false;
    state.switchCameras.value = true;
    EasyLoading.dismiss();
    if (Get.isSnackbarOpen) {
      Get.closeAllSnackbars();
    }
    Get.back();
  }

  Future<void> switchCamera() async {
    await engine.switchCamera();
    state.switchCameras.value = !state.switchCameras.value;
  }
}
