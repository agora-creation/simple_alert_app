import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:simple_alert_app/models/user_sender.dart';

class UserSenderService {
  String collection = 'user';
  String subCollection = 'sender';
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

  Future<UserSenderModel?> selectData({
    required String userId,
    required String senderUserId,
  }) async {
    UserSenderModel? ret;
    await firestore
        .collection(collection)
        .doc(userId)
        .collection(subCollection)
        .where('senderUserId', isEqualTo: senderUserId)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        ret = UserSenderModel.fromSnapshot(value.docs.first);
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
        .orderBy('senderUserName')
        .snapshots();
  }

  List<UserSenderModel> generateList({
    required QuerySnapshot<Map<String, dynamic>>? data,
  }) {
    List<UserSenderModel> ret = [];
    for (DocumentSnapshot<Map<String, dynamic>> doc in data!.docs) {
      ret.add(UserSenderModel.fromSnapshot(doc));
    }
    return ret;
  }
}
