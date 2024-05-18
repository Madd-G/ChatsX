import 'package:get/get.dart';

import 'controller.dart';

class EmailLoginBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmailLoginController>(() => EmailLoginController());
  }
}
