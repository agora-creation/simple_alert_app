import 'package:cloud_firestore/cloud_firestore.dart';

class UserNoticeModel {
  String _id = '';
  String _userId = '';
  String _title = '';
  String _content = '';
  bool _isChoice = false;
  List<String> choices = [];
  String _answer = '';
  bool _read = false;
  String _token = '';
  String _createdUserId = '';
  String _createdUserName = '';
  DateTime _createdAt = DateTime.now();

  String get id => _id;
  String get userId => _userId;
  String get title => _title;
  String get content => _content;
  bool get isChoice => _isChoice;
  String get answer => _answer;
  bool get read => _read;
  String get token => _token;
  String get createdUserId => _createdUserId;
  String get createdUserName => _createdUserName;
  DateTime get createdAt => _createdAt;

  UserNoticeModel.fromSnapshot(
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
    _answer = data['answer'] ?? '';
    _read = data['read'] ?? false;
    _token = data['token'] ?? '';
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
}
