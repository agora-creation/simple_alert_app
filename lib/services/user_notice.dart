import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_alert_app/models/user_notice.dart';

class UserNoticeService {
  String collection = 'user';
  String subCollection = 'notice';
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String id({
    required String userId,
  }) {
    return firestore
        .collection(collection)
        .doc(userId)
        .collection(subCollection)
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

  List<UserNoticeModel> generateList({
    required QuerySnapshot<Map<String, dynamic>>? data,
  }) {
    List<UserNoticeModel> ret = [];
    for (DocumentSnapshot<Map<String, dynamic>> doc in data!.docs) {
      ret.add(UserNoticeModel.fromSnapshot(doc));
    }
    return ret;
  }
}
