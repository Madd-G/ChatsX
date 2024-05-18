import 'package:get/get.dart';

import 'controller.dart';

class SendCodeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SendCodeController>(() => SendCodeController());
  }
}
