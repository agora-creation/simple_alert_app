import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_alert_app/models/user.dart';

class UserService {
  String collection = 'user';
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  void create(Map<String, dynamic> values) {
    firestore.collection(collection).doc(values['id']).set(values);
  }

  void update(Map<String, dynamic> values) {
    firestore.collection(collection).doc(values['id']).update(values);
  }

  void delete(Map<String, dynamic> values) {
    firestore.collection(collection).doc(values['id']).delete();
  }

  Future<UserModel?> selectData({
    String? id,
    String? email,
    String? senderNumber,
  }) async {
    UserModel? ret;
    if (id != null) {
      await firestore.collection(collection).doc(id).get().then((value) {
        ret = UserModel.fromSnapshot(value);
      });
    }
    if (email != null) {
      await firestore
          .collection(collection)
          .where('email', isEqualTo: email)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          ret = UserModel.fromSnapshot(value.docs.first);
        }
      });
    }
    if (senderNumber != null) {
      await firestore
          .collection(collection)
          .where('senderNumber', isEqualTo: senderNumber)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          ret = UserModel.fromSnapshot(value.docs.first);
        }
      });
    }
    return ret;
  }
}
