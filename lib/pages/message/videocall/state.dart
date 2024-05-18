import 'package:get/get.dart';

class VideoCallState {
  RxBool isReadyPreview = false.obs;
  RxBool isJoined = false.obs;
  RxBool isShowAvatar = true.obs;
  RxBool switchCameras = true.obs;
  RxBool switchView = true.obs;
  RxBool switchRender = true.obs;
  RxSet<int> remoteUid = <int>{}.obs;
  RxInt onRemoteUid = 0.obs;
  RxString callTimeNum = "not connected".obs;
  RxString callTime = "00:00".obs;

  var docId = "".obs;
  var channelId = "".obs;
  var toToken = "".obs;
  var toName = "".obs;
  var toAvatar = "".obs;
  var callRole = "audience".obs;
}
