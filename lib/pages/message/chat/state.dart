import 'package:chatsx/common/entities/entities.dart';
import 'package:get/get.dart';

class ChatState {
  RxList<Msgcontent> messageContentList = <Msgcontent>[].obs;
  var toToken = "".obs;
  var toName = "".obs;
  var toAvatar = "".obs;
  var toOnline = "1".obs;
  RxBool moreStatus = false.obs;
  RxBool isLoading = false.obs;
  RxInt inputHeight = 50.obs;
}
