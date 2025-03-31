import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_alert_app/common/functions.dart';
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
    required String id,
    required String userId,
  }) async {
    UserSendModel? ret;
    await firestore
        .collection(collection)
        .doc(userId)
        .collection(subCollection)
        .where('id', isEqualTo: id)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        ret = UserSendModel.fromSnapshot(value.docs.first);
      }
    });
    return ret;
  }

  Future<int> selectMonthSendCount({
    required String? userId,
  }) async {
    int ret = 0;
    DateTime now = DateTime.now();
    DateTime start = DateTime(now.year, now.month, 1);
    DateTime end = DateTime(now.year, now.month + 1, 1).subtract(Duration(
      days: 1,
    ));
    Timestamp startAt = convertTimestamp(start, false);
    Timestamp endAt = convertTimestamp(end, true);
    await firestore
        .collection(collection)
        .doc(userId ?? 'error')
        .collection(subCollection)
        .where('draft', isEqualTo: true)
        .orderBy('sendAt', descending: true)
        .startAt([endAt])
        .endAt([startAt])
        .get()
        .then((value) {
          if (value.docs.isNotEmpty) {
            for (final doc in value.docs) {
              UserSendModel userSend = UserSendModel.fromSnapshot(doc);
              ret += userSend.sendMapUsers.length;
            }
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
