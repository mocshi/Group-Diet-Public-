import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class FirebaseData {
  static Future<bool> addData(
      {required Map<String, dynamic> value, required String uid}) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .collection('data')
          .doc()
          .set(value);
    } on FirebaseException catch (e) {
      return false;
    }
    return true;
  }

  static Map<String, dynamic> createData(
      {required int date, required String keyName, required var data}) {
    return {
      'date': date,
      keyName: data,
      'fields': [keyName],
    };
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getFood({
    required String uid,
    required String foodname,
  }) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('food')
        .where('title', isEqualTo: foodname)
        .get();
  }

  static Future<bool> addFood(
      {required Map<String, dynamic> value, required String uid}) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .collection('food')
          .doc()
          .set(value);
    } on FirebaseException catch (e) {
      return false;
    }
    return true;
  }

  static Future<bool> deleteFood(
      {required String docid, required String uid}) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(uid)
          .collection('food')
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

  static Map<String, dynamic> creatUpdateData(
      {required String keyName, required var data, required List fields}) {
    return {
      keyName: data,
      'fields': fields,
    };
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getDataSnapshot({
    required String uid,
    required int day,
  }) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('data')
        .where('date', isEqualTo: day)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getDataLast7DaySnapshot({
    required String uid,
    required DateTime today,
  }) {
    DateTime day7ago = today.add(const Duration(days: 7) * -1);
    DateFormat outputFormat = DateFormat('yyyyMMdd');
    String date = outputFormat.format(day7ago);

    return FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('data')
        .where('date', isGreaterThan: int.parse(date))
        .snapshots();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getData({
    required String uid,
    required int day,
  }) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('data')
        .where('date', isEqualTo: day)
        .get();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastWeightSnapshot({
    required String uid,
    required int day,
  }) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('data')
        .where('date', isLessThanOrEqualTo: day)
        .orderBy('date', descending: true)
        .snapshots();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getAllData({
    required String uid,
  }) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('data')
        .orderBy('date', descending: true)
        .get();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getAllFood({
    required String uid,
  }) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('food')
        .get();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastDataSnapshot({
    required String uid,
  }) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(uid)
        .collection('data')
        .orderBy('date', descending: true)
        .snapshots();
  }
}
