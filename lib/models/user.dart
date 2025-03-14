import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String _id = '';
  String _name = '';
  String _email = '';
  String _password = '';
  List<String> tokens = [];

  String get id => _id;
  String get name => _name;
  String get email => _email;
  String get password => _password;

  UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    Map<String, dynamic>? data = snapshot.data();
    if (data == null) return;
    _id = data['id'] ?? '';
    _name = data['name'] ?? '';
    _email = data['email'] ?? '';
    _password = data['password'] ?? '';
    tokens = _convertTokens(data['tokens'] ?? []);
  }

  List<String> _convertTokens(List list) {
    List<String> ret = [];
    for (dynamic id in list) {
      ret.add('$id');
    }
    return ret;
  }
}
