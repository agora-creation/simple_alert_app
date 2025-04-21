import 'package:cloud_firestore/cloud_firestore.dart';

//受信者側が登録する送信者
class UserSenderModel {
  String _id = '';
  String _userId = '';
  String _senderUserId = '';
  String _senderUserName = '';
  bool _block = false;

  String get id => _id;
  String get userId => _userId;
  String get senderUserId => _senderUserId;
  String get senderUserName => _senderUserName;
  bool get block => _block;

  UserSenderModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    Map<String, dynamic>? data = snapshot.data();
    if (data == null) return;
    _id = data['id'] ?? '';
    _userId = data['userId'] ?? '';
    _senderUserId = data['senderUserId'] ?? '';
    _senderUserName = data['senderUserName'] ?? '';
    _block = data['block'] ?? false;
  }
}
