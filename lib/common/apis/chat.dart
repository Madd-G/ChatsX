import 'dart:io';
import 'package:dio/dio.dart';
import 'package:chatsx/common/entities/entities.dart';
import 'package:chatsx/common/utils/utils.dart';

class ChatAPI {

  static Future<BaseResponseEntity> bindFCMtoken(
      {BindFcmTokenRequestEntity? params}
      ) async {
    var response = await HttpUtil().post(
      'api/bind_fcmtoken',
      queryParameters: params?.toJson(),
    );
    return BaseResponseEntity.fromJson(response);
  }

  static Future<BaseResponseEntity> callNotifications(
      {CallRequestEntity? params}
      ) async {
    var response = await HttpUtil().post(
      'api/send_notice',
      queryParameters: params?.toJson(),
    );
    return BaseResponseEntity.fromJson(response);
  }

  static Future<BaseResponseEntity> callToken(
      {CallTokenRequestEntity? params}
      ) async {
    var response = await HttpUtil().post(
      'api/get_rtc_token',
      queryParameters: params?.toJson(),
    );
    return BaseResponseEntity.fromJson(response);
  }

  static Future<BaseResponseEntity> sendMessage(
      {ChatRequestEntity? params}
      ) async {
    var response = await HttpUtil().post(
      'api/message',
      queryParameters: params?.toJson(),
    );
    return BaseResponseEntity.fromJson(response);
  }

  static Future<BaseResponseEntity> uploadImage(
      {File? file}
      ) async {

    String fileName = file!.path.split('/').last;

    FormData data = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });
    var response = await HttpUtil().post(
      'api/upload_photo',
      data: data,
    );
    return BaseResponseEntity.fromJson(response);
  }

  static Future<SyncMessageResponseEntity> syncMessage(
      {SyncMessageRequestEntity? params}
      ) async {
    var response = await HttpUtil().post(
      'api/sync_message',
      queryParameters: params?.toJson(),
    );
    return SyncMessageResponseEntity.fromJson(response);
  }


}
