import 'package:chatsx/common/entities/entities.dart';
import 'package:chatsx/common/utils/utils.dart';

class ContactAPI {
  /// refresh
  static Future<ContactResponseEntity> postContact() async {
    var response = await HttpUtil().post(
      'api/contact',
    );
    return ContactResponseEntity.fromJson(response);
  }


}
