import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseInfo {
  static Future<bool> addData(
      {required Map<String, dynamic> value, required String uid}) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .collection('info')
          .doc()
          .set(value);
    } on FirebaseException catch (e) {
      return false;
    }
    return true;
  }

  static Map<String, dynamic> createData(
      {required int timestamp, required String doc}) {
    return {"createdAt": timestamp, "doc": doc, "isRead": false};
  }

  static Future<bool> readedInfo(
      {required String dataid, required String uid}) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .collection('info')
          .doc(dataid)
          .update({"isRead": true});
    } on FirebaseException catch (e) {
      return false;
    }
    return true;
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getInfo({
    required String uid,
  }) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('info')
        .orderBy("createdAt", descending: true)
        .get();
  }

  static Future<bool> deleteInfo(
      {required String docid, required String uid}) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .collection('info')
          .doc(docid)
          .delete();
    } on FirebaseException catch (e) {
      return false;
    }
    return true;
  }

  static Future<bool> updateData(
      {required String dataid,
      required Map<String, dynamic> data,
      required String uid}) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .collection('data')
          .doc(dataid)
          .update(data);
    } on FirebaseException catch (e) {
      return false;
    }
    return true;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getInfoNotReadSnapshot({
    required String uid,
  }) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('info')
        .where("isRead", isEqualTo: false)
        .snapshots();
  }
}
