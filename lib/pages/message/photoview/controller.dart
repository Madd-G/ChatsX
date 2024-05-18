import 'package:get/get.dart';
import 'state.dart';

class PhotoImgViewController extends GetxController {
  final PhotoImgViewState state = PhotoImgViewState();

  @override
  void onInit() {
    super.onInit();
    var data = Get.parameters;
    if (data["url"] != null) {
      state.url.value = data["url"]!;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
