import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_alert_app/models/user_send.dart';

class UserSendService {
  String collection = 'user';
  String subCollection = 'send';
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String id({
    required String userId,
  }) {
    return firestore
        .collection(collection)
        .doc(userId)
        .collection(subCollection)
        .doc()
        .id;
  }

  void create(Map<String, dynamic> values) {
    firestore
        .collection(collection)
        .doc(values['userId'])
        .collection(subCollection)
        .doc(values['id'])
        .set(values);
  }

  void update(Map<String, dynamic> values) {
    firestore
        .collection(collection)
        .doc(values['userId'])
        .collection(subCollection)
        .doc(values['id'])
        .update(values);
  }

  void delete(Map<String, dynamic> values) {
    firestore
        .collection(collection)
        .doc(values['userId'])
        .collection(subCollection)
        .doc(values['id'])
        .delete();
  }

  Future<UserSendModel?> selectData({
    String? id,
  }) async {
    UserSendModel? ret;
    if (id != null) {
      await firestore
          .collection(collection)
          .where('id', isEqualTo: id)
          .get()
          .then((value) {
        if (value.docs.isNotEmpty) {
          ret = UserSendModel.fromSnapshot(value.docs.first);
        }
      });
    }
    return ret;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? streamList({
    required String userId,
  }) {
    return FirebaseFirestore.instance
        .collection(collection)
        .doc(userId)
        .collection(subCollection)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  List<UserSendModel> generateList({
    required QuerySnapshot<Map<String, dynamic>>? data,
  }) {
    List<UserSendModel> ret = [];
    for (DocumentSnapshot<Map<String, dynamic>> doc in data!.docs) {
      ret.add(UserSendModel.fromSnapshot(doc));
    }
    return ret;
  }
}
