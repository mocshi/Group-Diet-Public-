import 'package:cloud_firestore/cloud_firestore.dart';
import 'common.dart';

class FirebaseUser {
  static Future<Map<String, dynamic>?> initializeUser({
    required Map user,
  }) async {
    Map<String, dynamic>? response = null;

    var snapshotquery = await FirebaseFirestore.instance
        .collection('user')
        .where('user_mail', isEqualTo: user['user_mail'])
        .get();

    if (snapshotquery.docs.length != 0) {
      response = snapshotquery.docs[0].data();
      response['id'] = snapshotquery.docs[0].id;
    }
    return response;
  }

  static Future<DocumentReference<Map<String, dynamic>>?> addUser(
      Map user) async {
    DocumentReference<Map<String, dynamic>>? docRef = null;
    int date = getIntToday();
    try {
      docRef = await FirebaseFirestore.instance.collection('user').add({
        'user_mail': user['user_mail'],
        'icon_url': user['icon_url'],
        'mainColor': user['mainColor'],
        'iconBack_url': user['iconBack_url'],
        'account_name': user['account_name'],
        'weight_init': user['weight_init'],
        'weight_goal': user['weight_goal'],
        'height': user['height'],
        'birth': user['birth'],
        'sex': user['sex'],
        'pal': user['pal'],
        'stress': user['stress'],
        'createdAt': date,
        'lastseen': date,
        'option_item_n': user['option_item_n'],
        'option_item_v': user['option_item_v'],
      });
    } on FirebaseException catch (e) {
      return null;
    }
    return docRef;
  }

  static Future<bool> updateUser(
      {required String docid, required Map<String, dynamic> data}) async {
    try {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(docid)
          .update(data);
    } on FirebaseException catch (e) {
      return false;
    }
    return true;
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>> getUser(
      {required String docid}) async {
    return await FirebaseFirestore.instance.collection('user').doc(docid).get();
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getUserSnapshot({
    required String docid,
  }) {
    return FirebaseFirestore.instance.collection('user').doc(docid).snapshots();
  }
}
