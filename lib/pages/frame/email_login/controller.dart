import 'package:chatsx/common/apis/apis.dart';
import 'package:flutter/material.dart';
import 'package:chatsx/common/entities/entities.dart';
import 'package:chatsx/common/routes/routes.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:chatsx/common/store/store.dart';
import 'package:chatsx/common/widgets/toast.dart';
import 'index.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmailLoginController extends GetxController {
  final state = EmailLoginState();
  TextEditingController? emailEditingController = TextEditingController();
  TextEditingController? passwordEditingController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  EmailLoginController();

  // login
  handleEmailLogin() async {
    String emailAddress = state.email.value;
    String password = state.password.value;

    if (emailAddress.isEmpty) {
      toastInfo(msg: "Email not empty!");
      return;
    }
    if (password.isEmpty) {
      toastInfo(msg: "Password not empty!");
      return;
    }
    Get.focusScope?.unfocus();
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAddress, password: password);

      if (credential.user == null) {
        toastInfo(msg: "user not login.");
        return;
      }
      if (!credential.user!.emailVerified) {
        toastInfo(msg: "please log in to verify your email address");
        return;
      }
      var user = credential.user;
      if (user != null) {
        String? displayName = user.displayName;
        String? email = user.email;
        String? id = user.uid;
        String? photoUrl = user.photoURL;

        LoginRequestEntity loginPageListRequestEntity = LoginRequestEntity();
        loginPageListRequestEntity.avatar = photoUrl;
        loginPageListRequestEntity.name = displayName;
        loginPageListRequestEntity.email = email;
        loginPageListRequestEntity.openId = id;
        loginPageListRequestEntity.type = 1;
        asyncPostAllData(loginPageListRequestEntity);
      } else {
        toastInfo(msg: 'login error');
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
        toastInfo(msg: "No user found for that email.");
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided for that user.');
        toastInfo(msg: "Wrong password provided for that user.");
      }
    }
  }

  asyncPostAllData(LoginRequestEntity loginRequestEntity) async {
    EasyLoading.show(
        indicator: const CircularProgressIndicator(),
        maskType: EasyLoadingMaskType.clear,
        dismissOnTap: true);
    var result = await UserAPI.login(params: loginRequestEntity);
    debugPrint('result: ${result.data}');
    if (result.code == 0) {
      await UserStore.to.saveProfile(result.data!);
      Get.offAllNamed(AppRoutes.Message);
    } else {
      toastInfo(msg: 'internet error');
    }
    EasyLoading.dismiss();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
