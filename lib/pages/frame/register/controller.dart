import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chatsx/common/values/server.dart';
import 'package:chatsx/common/widgets/toast.dart';
import 'index.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterController extends GetxController {
  final state = RegisterState();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController? userNameEditingController = TextEditingController();
  TextEditingController? emailEditingController = TextEditingController();
  TextEditingController? passwordEditingController = TextEditingController();

  RegisterController();

  handleEmailRegister() async {
    String userName = state.username.value;
    String emailAddress = state.email.value;
    String password = state.password.value;

    if (userName.isEmpty) {
      toastInfo(msg: "UserName not empty!");
      return;
    }
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
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailAddress,
        password: password,
      );
      debugPrint('$credential');
      await credential.user?.sendEmailVerification();
      await credential.user?.updateDisplayName(userName);
      String photoURL = "${SERVER_API_URL}uploads/default.png";
      await credential.user?.updatePhotoURL(photoURL);
      toastInfo(
          msg:
              "An email has been sent to your registered email. To activate your account, please open the link from the email.");
      Get.back();
        } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        debugPrint('The password provided is too weak.');
        toastInfo(msg: "The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        debugPrint('The account already exists for that email.');
        toastInfo(msg: "The account already exists for that email.");
      }
    } catch (e) {
      debugPrint('$e');
    }
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
