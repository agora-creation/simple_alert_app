import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_alert_app/models/user_noticer_group.dart';

class UserNoticerGroupService {
  String collection = 'user';
  String subCollection = 'noticerGroup';
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

  Future<UserNoticerGroupModel?> selectData({
    required String id,
    required String userId,
  }) async {
    UserNoticerGroupModel? ret;
    await firestore
        .collection(collection)
        .doc(userId)
        .collection(subCollection)
        .where('id', isEqualTo: id)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        ret = UserNoticerGroupModel.fromSnapshot(value.docs.first);
      }
    });
    return ret;
  }

  Future<List<UserNoticerGroupModel>> selectList({
    required String userId,
  }) async {
    List<UserNoticerGroupModel> ret = [];
    await firestore
        .collection(collection)
        .doc(userId)
        .collection(subCollection)
        .orderBy('name', descending: true)
        .get()
        .then((value) {
      for (DocumentSnapshot<Map<String, dynamic>> map in value.docs) {
        ret.add(UserNoticerGroupModel.fromSnapshot(map));
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
        .orderBy('name', descending: true)
        .snapshots();
  }

  List<UserNoticerGroupModel> generateList({
    required QuerySnapshot<Map<String, dynamic>>? data,
  }) {
    List<UserNoticerGroupModel> ret = [];
    for (DocumentSnapshot<Map<String, dynamic>> doc in data!.docs) {
      ret.add(UserNoticerGroupModel.fromSnapshot(doc));
    }
    return ret;
  }
}
