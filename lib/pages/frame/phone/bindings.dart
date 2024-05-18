import 'package:get/get.dart';

import 'controller.dart';

class PhoneBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PhoneController>(() => PhoneController());
  }
}
