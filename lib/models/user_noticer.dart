import 'package:cloud_firestore/cloud_firestore.dart';

//送信者側が登録する受信者
class UserNoticerModel {
  String _id = '';
  String _userId = '';
  String _noticerUserId = '';
  String _noticerUserName = '';

  String get id => _id;
  String get userId => _userId;
  String get noticerUserId => _noticerUserId;
  String get noticerUserName => _noticerUserName;

  UserNoticerModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    Map<String, dynamic>? data = snapshot.data();
    if (data == null) return;
    _id = data['id'] ?? '';
    _userId = data['userId'] ?? '';
    _noticerUserId = data['noticerUserId'] ?? '';
    _noticerUserName = data['noticerUserName'] ?? '';
  }
}
