import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String _id = '';
  String _name = '';
  String _tel = '';
  String _token = '';
  bool _sender = false;
  String _senderId = '';
  String _senderName = '';

  String get id => _id;
  String get name => _name;
  String get tel => _tel;
  String get token => _token;
  bool get sender => _sender;
  String get senderId => _senderId;
  String get senderName => _senderName;

  UserModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    Map<String, dynamic>? data = snapshot.data();
    if (data == null) return;
    _id = data['id'] ?? '';
    _name = data['name'] ?? '';
    _tel = data['tel'] ?? '';
    _token = data['token'] ?? '';
    _sender = data['sender'] ?? false;
    _senderId = data['senderId'] ?? '';
    _senderName = data['senderName'] ?? '';
  }
}
