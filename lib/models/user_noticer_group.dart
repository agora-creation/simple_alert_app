//送信者側が登録する受信者のグループ分け
import 'package:cloud_firestore/cloud_firestore.dart';

class UserNoticerGroupModel {
  String _id = '';
  String _userId = '';
  String _name = '';
  List<String> userIds = [];

  String get id => _id;
  String get userId => _userId;
  String get name => _name;

  UserNoticerGroupModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    Map<String, dynamic>? data = snapshot.data();
    if (data == null) return;
    _id = data['id'] ?? '';
    _userId = data['userId'] ?? '';
    _name = data['name'] ?? '';
    userIds = _convertUserIds(data['userIds']);
  }

  List<String> _convertUserIds(List list) {
    List<String> ret = [];
    for (dynamic id in list) {
      ret.add('$id');
    }
    return ret;
  }
}
