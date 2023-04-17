import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'common.dart';

class Authentication {
  static Future<Map<String, dynamic>?> initializeFirebase() async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    User? user = FirebaseAuth.instance.currentUser;
    Map<String, dynamic>? _response = null;

    if (user != null) {
      _response = {'user_mail': user.email};
      return _response;
    }
    return _response;
  }

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn().catchError((onError) {
      customSnackBar(content: onError.toString());
    });

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);
        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          await customSnackBar(
            content: 'The account already exists with a different credential.',
          );
        } else if (e.code == 'invalid-credential') {
          await customSnackBar(
            content: 'Error occurred while accessing credentials. Try again.',
          );
        }
      } catch (e) {
        await customSnackBar(
          content: 'Error occurred using Google Sign-In. Try again.',
        );
      }
    }
    return user;
  }

  static Future<void> signOut({required BuildContext context}) async {
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      if (!kIsWeb) {
        await googleSignIn.signOut();
      }
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      await customSnackBar(
        content: 'Error signing out. Try again.',
      );
    }
  }
}
