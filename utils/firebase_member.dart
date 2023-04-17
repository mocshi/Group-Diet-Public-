import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:badges/badges.dart' as badges;

class FirebaseMember {
  static Future<bool> addMember({required Map<String, dynamic> value}) async {
    try {
      await FirebaseFirestore.instance.collection('member').doc().set(value);
    } on FirebaseException catch (e) {
      return false;
    }
    return true;
  }

  static Map<String, dynamic> createData(
      {required List related, required String from, required String to}) {
    return {
      'related': related,
      'member': [],
      'req_from': from,
      'req_to': to,
    };
  }

  static Future<bool> updateMember({
    required String docid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('member')
          .doc(docid)
          .update(data);
    } on FirebaseException catch (e) {
      return false;
    }
    return true;
  }

  static Map<String, dynamic> createUpdateData({required List member}) {
    return {
      'member': member,
      'req_from': "",
      'req_to': "",
    };
  }

  static Future<bool> deleteMember({
    required String docid,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('member').doc(docid).delete();
    } on FirebaseException catch (e) {
      return false;
    }
    return true;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getMemberSnapshot(
      {required String uid}) {
    return FirebaseFirestore.instance
        .collection('member')
        .where('related', arrayContains: uid)
        .snapshots();
  }

  static Future<QuerySnapshot<Map<String, dynamic>>> getMember({
    required Map<String, dynamic> rule,
  }) {
    return FirebaseFirestore.instance.collection('member').where(rule).get();
  }
}
