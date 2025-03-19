import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_alert_app/models/map_notice_user.dart';
import 'package:simple_alert_app/models/map_send_user.dart';

class UserModel {
  String _id = '';
  String _name = '';
  String _email = '';
  String _password = '';
  String _token = '';
  List<MapNoticeUserModel> mapNoticeUsers = [];
  bool _isSender = false;
  String _senderNumber = '';
  String _senderName = '';
  int _sendUserLimit = 0;
  List<MapSendUserModel> mapSendUsers = [];

  String get id => _id;
  String get name => _name;
  String get email => _email;
  String get password => _password;
  String get token => _token;
  bool get isSender => _isSender;
  String get senderNumber => _senderNumber;
  String get senderName => _senderName;
  int get sendUserLimit => _sendUserLimit;

  UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic>? data = snapshot.data();
    if (data == null) return;
    _id = data['id'] ?? '';
    _name = data['name'] ?? '';
    _email = data['email'] ?? '';
    _password = data['password'] ?? '';
    _token = data['token'] ?? '';
    mapNoticeUsers = _convertMapNoticeUsers(data['mapNoticeUsers'] ?? []);
    _isSender = data['isSender'] ?? false;
    _senderNumber = data['senderNumber'] ?? '';
    _senderName = data['senderName'] ?? '';
    _sendUserLimit = data['sendUserLimit'] ?? 0;
    mapSendUsers = _convertMapSendUsers(data['mapSendUsers'] ?? []);
  }

  List<MapNoticeUserModel> _convertMapNoticeUsers(List list) {
    List<MapNoticeUserModel> ret = [];
    for (Map data in list) {
      ret.add(MapNoticeUserModel.fromMap(data));
    }
    return ret;
  }

  List<MapSendUserModel> _convertMapSendUsers(List list) {
    List<MapSendUserModel> ret = [];
    for (Map data in list) {
      ret.add(MapSendUserModel.fromMap(data));
    }
    return ret;
  }
}
