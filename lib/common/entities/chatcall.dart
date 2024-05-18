import 'package:cloud_firestore/cloud_firestore.dart';

class ChatCall {
  final String? docId;
  final String? fromToken;
  final String? toToken;
  final String? fromName;
  final String? toName;
  final String? fromAvatar;
  final String? toAvatar;
  final String? callTime;
  final String? type;
  final Timestamp? lastTime;

  ChatCall({
    this.docId,
    this.fromToken,
    this.toToken,
    this.fromName,
    this.toName,
    this.fromAvatar,
    this.toAvatar,
    this.callTime,
    this.type,
    this.lastTime,
  });

  factory ChatCall.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return ChatCall(
      fromToken: data?['from_token'],
      toToken: data?['to_token'],
      fromName: data?['from_name'],
      toName: data?['to_name'],
      fromAvatar: data?['from_avatar'],
      toAvatar: data?['to_avatar'],
      lastTime: data?['last_time'],
      type: data?['type'],
      callTime: data?['call_time'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      if (fromToken != null) "from_token": fromToken,
      if (toToken != null) "to_token": toToken,
      if (fromName != null) "from_name": fromName,
      if (toName != null) "to_name": toName,
      if (fromAvatar != null) "from_avatar": fromAvatar,
      if (toAvatar != null) "to_avatar": toAvatar,
      if (callTime != null) "call_time": callTime,
      if (type != null) "type": type,
      if (lastTime != null) "last_time": lastTime,
    };
  }
}
