import 'package:chatsx/common/entities/entities.dart';
import 'package:get/get.dart';

class PhoneState {
  RxString username = "".obs;
  RxString email = "".obs;
  RxString password = "".obs;
  RxString verifyCode = "".obs;
  var chooseIndex = 0.obs;
  var chooseIndexFlag = "🇦🇫".obs;
  var chooseIndexDialCode = "+93".obs;
  var phoneNumber = "".obs;
  RxList<Country> countryList = RxList<Country>();
}
