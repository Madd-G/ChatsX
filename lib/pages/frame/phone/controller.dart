import 'package:chatsx/common/utils/data.dart';
import 'package:chatsx/common/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:chatsx/common/routes/routes.dart';
import 'package:get/get.dart';
import 'package:chatsx/common/widgets/toast.dart';
import 'index.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneController extends GetxController {
  final state = PhoneState();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController? phoneEditingController = TextEditingController();
  FixedExtentScrollController? fixedExtentScrollController =
      FixedExtentScrollController(initialItem: 0);

  PhoneController();

  handlePhone() async {
    try {
      String phone = state.phoneNumber.value.trim();
      Get.focusScope?.unfocus();
      if (phone.isEmpty) {
        toastInfo(msg: "phone number not empty!");
        return;
      }
      String dialCode = state.chooseIndexDialCode.value;
      debugPrint(phone);
      debugPrint(dialCode);

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: '$dialCode $phone',
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint("verificationCompleted----");
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint("verificationFailed----");
          debugPrint('$e');
          if (e.code == 'invalid-phone-number') {
            debugPrint('The provided phone number is not valid.');
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('codeSent----------');
          debugPrint(verificationId);
          Get.toNamed(AppRoutes.SendCode,
              parameters: {"verificationId": verificationId});
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('codeAutoRetrievalTimeout-------------');
          debugPrint(verificationId);
        },
        timeout: const Duration(milliseconds: 10000),
      );
    } catch (error) {
      toastInfo(msg: 'login error');
      debugPrint("Login--------------------------");
      debugPrint('$error');
    }
  }

  saveAddress() async {
    state.chooseIndexFlag.value =
        state.countryList.elementAt(state.chooseIndex.value).flag;
    state.chooseIndexDialCode.value =
        state.countryList.elementAt(state.chooseIndex.value).dialCode;

    Get.back();
  }

  @override
  void onReady() {
    super.onReady();

    state.countryList.value = Countries.list;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
