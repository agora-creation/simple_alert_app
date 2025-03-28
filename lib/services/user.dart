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
    String? tel,
  }) async {
    UserModel? ret;
    if (id != null) {
      await firestore
          .collection(collection)
          .where('id', isEqualTo: id)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          ret = UserModel.fromSnapshot(value.docs.first);
        }
      });
    }
    if (tel != null) {
      await firestore
          .collection(collection)
          .where('tel', isEqualTo: tel)
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
