import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_alert_app/models/send_user.dart';

const kDefaultChoices = ['はい', 'いいえ'];

class UserSendModel {
  String _id = '';
  String _userId = '';
  String _title = '';
  String _content = '';
  bool _isChoice = false;
  List<String> choices = [];
  bool _draft = false;
  DateTime _sendAt = DateTime.now();
  List<SendUserModel> sendUsers = [];
  String _createdUserId = '';
  String _createdUserName = '';
  DateTime _createdAt = DateTime.now();

  String get id => _id;
  String get userId => _userId;
  String get title => _title;
  String get content => _content;
  bool get isChoice => _isChoice;
  bool get draft => _draft;
  DateTime get sendAt => _sendAt;
  String get createdUserId => _createdUserId;
  String get createdUserName => _createdUserName;
  DateTime get createdAt => _createdAt;

  UserSendModel.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    Map<String, dynamic>? data = snapshot.data();
    if (data == null) return;
    _id = data['id'] ?? '';
    _userId = data['userId'] ?? '';
    _title = data['title'] ?? '';
    _content = data['content'] ?? '';
    _isChoice = data['isChoice'] ?? false;
    choices = _convertChoices(data['choices'] ?? []);
    _draft = data['draft'] ?? false;
    _sendAt = data['sendAt'].toDate() ?? DateTime.now();
    sendUsers = _convertSendUsers(data['sendUsers'] ?? []);
    _createdUserId = data['createdUserId'] ?? '';
    _createdUserName = data['createdUserName'] ?? '';
    _createdAt = data['createdAt'].toDate() ?? DateTime.now();
  }

  List<String> _convertChoices(List list) {
    List<String> ret = [];
    for (String data in list) {
      ret.add(data);
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
