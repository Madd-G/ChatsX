import 'package:chatsx/common/apis/apis.dart';
import 'package:flutter/material.dart';
import 'package:chatsx/common/entities/entities.dart';
import 'package:chatsx/common/routes/routes.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:chatsx/common/store/store.dart';
import 'package:chatsx/common/values/server.dart';
import 'package:chatsx/common/widgets/toast.dart';
import 'index.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SendCodeController extends GetxController {
  final state = SendCodeState();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController? emailEditingController = TextEditingController();

  SendCodeController();

  String verificationId = "";

  void submitOTP() async {
    /// get the `smsCode` from the user
    String smsCode = state.verifycode.value;
    if (smsCode.isEmpty) {
      toastInfo(msg: "smsCode not empty!");
      return;
    }
    Get.focusScope?.unfocus();
    var phoneAuthCredential = await PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);

    _login(phoneAuthCredential);
  }

  Future<void> _login(AuthCredential phoneAuthCredential) async {
    try {
      var user =
          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      debugPrint("user-------------");
      debugPrint('$user');
      if (user.user != null) {
        String displayName = "phone_user";
        String email = user.user!.phoneNumber ?? "phone@email.com";
        String id = user.user!.uid;
        String photoUrl = "${SERVER_API_URL}uploads/default.png";
        debugPrint(photoUrl);
        debugPrint("phone uid----");
        debugPrint(id);
        LoginRequestEntity loginPageListRequestEntity = LoginRequestEntity();
        loginPageListRequestEntity.avatar = photoUrl;
        loginPageListRequestEntity.name = displayName;
        loginPageListRequestEntity.email = email;
        loginPageListRequestEntity.openId = id;
        loginPageListRequestEntity.type = 5;
        asyncPostAllData(loginPageListRequestEntity);
      } else {
        toastInfo(msg: 'apple login error');
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  asyncPostAllData(LoginRequestEntity loginRequestEntity) async {
    EasyLoading.show(
        indicator: const CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: true);
    var result = await UserAPI.login(params: loginRequestEntity);
    debugPrint('$result');
    if (result.code == 0) {
      await UserStore.to.saveProfile(result.data!);
      EasyLoading.dismiss();
      Get.offAllNamed(AppRoutes.Message);
    } else {
      EasyLoading.dismiss();
      toastInfo(msg: 'internet error');
    }
  }

  @override
  void onReady() {
    super.onReady();
    var data = Get.parameters;
    debugPrint('$data');
    verificationId = data["verificationId"] ?? "";
  }

  @override
  void dispose() {
    super.dispose();
  }
}
