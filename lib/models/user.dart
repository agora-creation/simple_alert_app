import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_alert_app/models/receive_user.dart';
import 'package:simple_alert_app/models/send_user.dart';

class UserModel {
  String _id = '';
  String _name = '';
  String _email = '';
  String _password = '';
  List<String> tokens = [];
  List<ReceiveUserModel> receiveUsers = [];
  bool _isSender = false;
  String _senderNumber = '';
  String _senderName = '';
  int _sendUserLimit = 0;
  List<SendUserModel> sendUsers = [];

  String get id => _id;
  String get name => _name;
  String get email => _email;
  String get password => _password;
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
    tokens = _convertTokens(data['tokens'] ?? []);
    receiveUsers = _convertReceiveUsers(data['receiveUsers'] ?? []);
    _isSender = data['isSender'] ?? false;
    _senderNumber = data['senderNumber'] ?? '';
    _senderName = data['senderName'] ?? '';
    _sendUserLimit = data['sendUserLimit'] ?? 0;
    sendUsers = _convertSendUsers(data['sendUsers'] ?? []);
  }

  List<String> _convertTokens(List list) {
    List<String> ret = [];
    for (dynamic id in list) {
      ret.add('$id');
    }
    return ret;
  }

  List<ReceiveUserModel> _convertReceiveUsers(List list) {
    List<ReceiveUserModel> ret = [];
    for (Map data in list) {
      ret.add(ReceiveUserModel.fromMap(data));
    }
    return ret;
  }

  List<SendUserModel> _convertSendUsers(List list) {
    List<SendUserModel> ret = [];
    for (Map data in list) {
      ret.add(SendUserModel.fromMap(data));
    }
    return ret;
  }
}
