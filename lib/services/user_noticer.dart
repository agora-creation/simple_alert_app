import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_alert_app/models/user_noticer.dart';

class UserNoticerService {
  String collection = 'user';
  String subCollection = 'noticer';
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

  Future<UserNoticerModel?> selectData({
    required String userId,
    required String noticerUserId,
  }) async {
    UserNoticerModel? ret;
    await firestore
        .collection(collection)
        .doc(userId)
        .collection(subCollection)
        .where('noticerUserId', isEqualTo: noticerUserId)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        ret = UserNoticerModel.fromSnapshot(value.docs.first);
      }
    });
    return ret;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>>? streamList({
    required String userId,
  }) {
    return firestore
        .collection(collection)
        .doc(userId)
        .collection(subCollection)
        .orderBy('noticerUserName', descending: true)
        .snapshots();
  }

  List<UserNoticerModel> generateList({
    required QuerySnapshot<Map<String, dynamic>>? data,
  }) {
    List<UserNoticerModel> ret = [];
    for (DocumentSnapshot<Map<String, dynamic>> doc in data!.docs) {
      ret.add(UserNoticerModel.fromSnapshot(doc));
    }
    return ret;
  }
}
