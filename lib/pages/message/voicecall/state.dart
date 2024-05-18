import 'package:get/get.dart';

class VoiceCallState {
  RxString url = "".obs;
  RxBool isJoined = false.obs;
  RxBool openMicrophone = true.obs;
  RxBool enableSpeakerphone = true.obs;
  RxString callTime = "00:00".obs;
  RxString callTimeNum = "not connected".obs;

  var channelId = "".obs;
  var toToken = "".obs;
  var toName = "".obs;
  var toAvatar = "".obs;
  var docId = "".obs;
  // receiver = audience
  // anchor = caller
  var callRole = "audience".obs; // 1，anchor 2，audience
}
