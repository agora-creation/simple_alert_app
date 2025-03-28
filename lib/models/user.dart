import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_alert_app/models/map_user.dart';

class UserModel {
  String _id = '';
  String _name = '';
  String _tel = '';
  String _token = '';
  List<MapUserModel> noticeMapUsers = [];
  List<MapUserModel> sendMapUsers = [];

  String get id => _id;
  String get name => _name;
  String get tel => _tel;
  String get token => _token;

  UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic>? data = snapshot.data();
    if (data == null) return;
    _id = data['id'] ?? '';
    _name = data['name'] ?? '';
    _tel = data['tel'] ?? '';
    _token = data['token'] ?? '';
    noticeMapUsers = _convertMapUsers(data['noticeMapUsers'] ?? []);
    sendMapUsers = _convertMapUsers(data['sendMapUsers'] ?? []);
  }

  List<MapUserModel> _convertMapUsers(List list) {
    List<MapUserModel> ret = [];
    for (Map data in list) {
      ret.add(MapUserModel.fromMap(data));
    }
    return ret;
  }
}
