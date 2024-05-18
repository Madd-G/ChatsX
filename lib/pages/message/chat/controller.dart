import 'dart:io';
import 'package:chatsx/common/apis/apis.dart';
import 'package:chatsx/common/routes/names.dart';
import 'package:chatsx/common/widgets/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'state.dart';
import 'package:chatsx/common/entities/entities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chatsx/common/store/store.dart';
import 'package:image_picker/image_picker.dart';

class ChatController extends GetxController {
  ChatController();

  final myInputController = TextEditingController();
  ScrollController myScrollController = ScrollController();
  ScrollController inputScrollController = ScrollController();
  FocusNode contentFocus = FocusNode();
  final ChatState state = ChatState();
  final db = FirebaseFirestore.instance;
  bool isLoadMore = true;
  double inputHeightStatus = 0;
  var listener;
  var docId = null;
  final token = UserStore.to.profile.token;
  File? _photo;
  final ImagePicker _picker = ImagePicker();

  goMore() {
    state.moreStatus.value = state.moreStatus.value ? false : true;
  }

  audioCall() async {
    state.moreStatus.value = false;
    Get.toNamed(AppRoutes.VoiceCall, parameters: {
      "doc_id": docId,
      "to_token": state.toToken.value,
      "to_name": state.toName.value,
      "to_avatar": state.toAvatar.value,
      "call_role": "anchor"
    });
  }

  callVideo() async {
    state.moreStatus.value = false;
    Get.toNamed(AppRoutes.VideoCall, parameters: {
      "doc_id": docId,
      "to_token": state.toToken.value,
      "to_name": state.toName.value,
      "to_avatar": state.toAvatar.value,
      "call_role": "anchor"
    });
  }

  Future imageFromGallery() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _photo = File(pickedFile.path);
      uploadFile();
    } else {
      debugPrint('No image selected.');
    }
  }

  Future imageFromCamera() async {
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
      sendImageMessage(result.data!);
    } else {
      toastInfo(msg: "image error");
    }
  }

  sendMessage() async {
    debugPrint("---------------chat-----------------");
    String sendcontent = myInputController.text;
    if (sendcontent.isEmpty) {
      toastInfo(msg: "content not empty");
      return;
    }
    debugPrint("---------------chat--$sendcontent-----------------");
    final content = Msgcontent(
      token: token,
      content: sendcontent,
      type: "text",
      addtime: Timestamp.now(),
    );

    await db
        .collection("message")
        .doc(docId)
        .collection("msglist")
        .withConverter(
          fromFirestore: Msgcontent.fromFirestore,
          toFirestore: (Msgcontent msgcontent, options) =>
              msgcontent.toFirestore(),
        )
        .add(content)
        .then((DocumentReference doc) {
      debugPrint('DocumentSnapshot added with ID: ${doc.id}');
      myInputController.clear();
    });
    var messageRes = await db
        .collection("message")
        .doc(docId)
        .withConverter(
          fromFirestore: Msg.fromFirestore,
          toFirestore: (Msg msg, options) => msg.toFirestore(),
        )
        .get();
    if (messageRes.data() != null) {
      var item = messageRes.data()!;
      int toMessage = item.toMessageNum == null ? 0 : item.toMessageNum!;
      int fromMessageNum =
          item.fromMessageNum == null ? 0 : item.fromMessageNum!;
      if (item.fromToken == token) {
        fromMessageNum = fromMessageNum + 1;
      } else {
        toMessage = toMessage + 1;
      }
      await db.collection("message").doc(docId).update({
        "to_msg_num": toMessage,
        "from_msg_num": fromMessageNum,
        "last_msg": sendcontent,
        "last_time": Timestamp.now()
      });
    }
    sendNotifications("text");
  }

  sendImageMessage(String url) async {
    state.moreStatus.value = false;
    debugPrint("---------------chat-----------------");
    final content = Msgcontent(
      token: token,
      content: url,
      type: "image",
      addtime: Timestamp.now(),
    );

    await db
        .collection("message")
        .doc(docId)
        .collection("msglist")
        .withConverter(
          fromFirestore: Msgcontent.fromFirestore,
          toFirestore: (Msgcontent msgcontent, options) =>
              msgcontent.toFirestore(),
        )
        .add(content)
        .then((DocumentReference doc) {
      debugPrint('DocumentSnapshot added with ID: ${doc.id}');
    });
    var messageRes = await db
        .collection("message")
        .doc(docId)
        .withConverter(
          fromFirestore: Msg.fromFirestore,
          toFirestore: (Msg msg, options) => msg.toFirestore(),
        )
        .get();
    if (messageRes.data() != null) {
      var item = messageRes.data()!;
      int toMessageNum = item.toMessageNum == null ? 0 : item.toMessageNum!;
      int fromMessageNum =
          item.fromMessageNum == null ? 0 : item.fromMessageNum!;
      if (item.fromToken == token) {
        fromMessageNum = fromMessageNum + 1;
      } else {
        toMessageNum = toMessageNum + 1;
      }
      await db.collection("message").doc(docId).update({
        "to_msg_num": toMessageNum,
        "from_msg_num": fromMessageNum,
        "last_msg": "【image】",
        "last_time": Timestamp.now()
      });
    }

    sendNotifications("text");
  }

  sendNotifications(String callType) async {
    CallRequestEntity callRequestEntity = CallRequestEntity();
    // text,voice,video,cancel
    callRequestEntity.callType = callType;
    callRequestEntity.toToken = state.toToken.value;
    callRequestEntity.toAvatar = state.toAvatar.value;
    callRequestEntity.docId = docId;
    callRequestEntity.toName = state.toName.value;
    var res = await ChatAPI.callNotifications(params: callRequestEntity);
    debugPrint('res: $res');
    if (res.code == 0) {
      debugPrint("sendNotifications success");
    } else {
      // Get.snackbar("Tips", "Notification error!");
      // Get.offAllNamed(AppRoutes.Message);
    }
  }

  clearMessageNum(String docId) async {
    var messageRes = await db
        .collection("message")
        .doc(docId)
        .withConverter(
          fromFirestore: Msg.fromFirestore,
          toFirestore: (Msg msg, options) => msg.toFirestore(),
        )
        .get();
    if (messageRes.data() != null) {
      var item = messageRes.data()!;
      int toMessageNum = item.toMessageNum == null ? 0 : item.toMessageNum!;
      int fromMessageNum =
          item.fromMessageNum == null ? 0 : item.fromMessageNum!;
      if (item.fromToken == token) {
        toMessageNum = 0;
      } else {
        fromMessageNum = 0;
      }
      await db
          .collection("message")
          .doc(docId)
          .update({"to_msg_num": toMessageNum, "from_msg_num": fromMessageNum});
    }
  }

  asyncLoadMoreData(int page) async {
    final messages = await db
        .collection("message")
        .doc(docId)
        .collection("msglist")
        .withConverter(
          fromFirestore: Msgcontent.fromFirestore,
          toFirestore: (Msgcontent msgcontent, options) =>
              msgcontent.toFirestore(),
        )
        .orderBy("addtime", descending: true)
        .where("addtime",
            isLessThan: state.messageContentList.value.last.addtime)
        .limit(10)
        .get();
    debugPrint(state.messageContentList.value.last.content);
    debugPrint("isGreaterThan-----");
    if (messages.docs.isNotEmpty) {
      messages.docs.forEach((element) {
        var data = element.data();
        state.messageContentList.value.add(data);
        debugPrint(data.content);
      });

      SchedulerBinding.instance.addPostFrameCallback((_) {
        isLoadMore = true;
      });
    }
    state.isLoading.value = false;
  }

  closeAllPop() async {
    Get.focusScope?.unfocus();
    state.moreStatus.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    debugPrint("onInit------------");
    var data = Get.parameters;
    debugPrint('$data');
    docId = data["doc_id"];
    state.toToken.value = data["to_token"] ?? "";
    state.toName.value = data["to_name"] ?? "";
    state.toAvatar.value = data["to_avatar"] ?? "";
    state.toOnline.value = data["to_online"] ?? "1";
    clearMessageNum(docId);
  }

  @override
  void onReady() {
    super.onReady();
    debugPrint("onReady------------");
    state.messageContentList.clear();
    final messages = db
        .collection("message")
        .doc(docId)
        .collection("msglist")
        .withConverter(
          fromFirestore: Msgcontent.fromFirestore,
          toFirestore: (Msgcontent msgcontent, options) =>
              msgcontent.toFirestore(),
        )
        .orderBy("addtime", descending: true)
        .limit(15);

    listener = messages.snapshots().listen(
      (event) {
        debugPrint("current data: ${event.docs}");
        debugPrint("current data: ${event.metadata.hasPendingWrites}");
        List<Msgcontent> tempMsgList = <Msgcontent>[];
        for (var change in event.docChanges) {
          switch (change.type) {
            case DocumentChangeType.added:
              debugPrint("added----: ${change.doc.data()}");
              if (change.doc.data() != null) {
                tempMsgList.add(change.doc.data()!);
              }
              break;
            case DocumentChangeType.modified:
              debugPrint("Modified City: ${change.doc.data()}");
              break;
            case DocumentChangeType.removed:
              debugPrint("Removed City: ${change.doc.data()}");
              break;
          }
        }
        tempMsgList.reversed.forEach((element) {
          state.messageContentList.value.insert(0, element);
        });
        state.messageContentList.refresh();

        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (myScrollController.hasClients) {
            myScrollController.animateTo(
              myScrollController.position.minScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      },
      onError: (error) => debugPrint("Listen failed: $error"),
    );

    myScrollController.addListener(() {
      // debugPrint(myscrollController.offset);
      //  debugPrint(myscrollController.position.maxScrollExtent);
      if ((myScrollController.offset + 10) >
          myScrollController.position.maxScrollExtent) {
        if (isLoadMore) {
          state.isLoading.value = true;
          isLoadMore = false;
          asyncLoadMoreData(state.messageContentList.length);
        }
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    debugPrint("onClose-------");
    clearMessageNum(docId);
  }

  @override
  void dispose() {
    listener.cancel();
    myInputController.dispose();
    inputScrollController.dispose();
    debugPrint("dispose-------");
    super.dispose();
  }
}
