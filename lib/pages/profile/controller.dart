import 'dart:io';
import 'package:chatsx/common/apis/apis.dart';
import 'package:flutter/material.dart';
import 'package:chatsx/common/entities/entities.dart';
import 'package:get/get.dart';
import 'package:chatsx/common/store/store.dart';
import 'package:chatsx/common/widgets/toast.dart';
import 'package:image_picker/image_picker.dart';
import 'index.dart';
import 'package:google_sign_in/google_sign_in.dart';

class ProfileController extends GetxController {
  final state = ProfileState();
  TextEditingController? nameEditingController = TextEditingController();
  TextEditingController? descriptionEditingController = TextEditingController();
  File? _photo;
  final ImagePicker _picker = ImagePicker();

  ProfileController();

  goSave() async {
    if (state.profileDetail.value.name == null ||
        state.profileDetail.value.name!.isEmpty) {
      toastInfo(msg: "name not empty!");
      return;
    }
    if (state.profileDetail.value.description == null ||
        state.profileDetail.value.description!.isEmpty) {
      toastInfo(msg: "description not empty!");
      return;
    }
    if (state.profileDetail.value.avatar == null ||
        state.profileDetail.value.avatar!.isEmpty) {
      toastInfo(msg: "avatar not empty!");
      return;
    }

    LoginRequestEntity updateProfileRequestEntity = LoginRequestEntity();
    UserItem userItem = state.profileDetail.value;
    updateProfileRequestEntity.avatar = userItem.avatar;
    updateProfileRequestEntity.name = userItem.name;
    updateProfileRequestEntity.description = userItem.description;
    updateProfileRequestEntity.online = userItem.online;

    var result = await UserAPI.updateProfile(params: updateProfileRequestEntity);
    debugPrint('${result.code}');
    debugPrint(result.msg);
    if (result.code == 0) {
      UserItem userItem = state.profileDetail.value;
      await UserStore.to.saveProfile(userItem);
      Get.back(result: "finish");
    }
  }

  goLogout() async {
    await GoogleSignIn().signOut();
    await UserStore.to.onLogout();
  }

  Future imgFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _photo = File(pickedFile.path);
      uploadFile();
    } else {
      debugPrint('No image selected.');
    }
  }

  Future imgFromCamera() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      _photo = File(pickedFile.path);
      uploadFile();
    } else {
      debugPrint('No image selected.');
    }
  }

  Future uploadFile() async {
    // if (_photo == null) return;
    // debugPrint(_photo);
    var result = await ChatAPI.uploadImage(file: _photo);
    debugPrint(result.data);
    if (result.code == 0) {
      state.profileDetail.value.avatar = result.data;
      state.profileDetail.refresh();
    } else {
      toastInfo(msg: "image error");
    }
  }

  asyncLoadAllData() async {
    // await
  }

  @override
  void onInit() {
    super.onInit();
    var userItem = Get.arguments;
    if (userItem != null) {
      state.profileDetail.value = userItem;
      if (state.profileDetail.value.name != null) {
        nameEditingController?.text = state.profileDetail.value.name!;
      }
      if (state.profileDetail.value.description != null) {
        descriptionEditingController?.text =
            state.profileDetail.value.description!;
      }
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
