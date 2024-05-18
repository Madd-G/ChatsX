import 'package:get/get.dart';
import 'controller.dart';

class PhotoImgViewBinding implements Bindings {

@override
void dependencies() {
  Get.lazyPut<PhotoImgViewController>(() => PhotoImgViewController());
}
}
