import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class Authentication {
  final _firebaseAuth = FirebaseAuth.instance;

  Future signOutUser(BuildContext context) async {
    var signOut = await _firebaseAuth.signOut();

    // navigator pop until the initial context
    if (context.mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }

    return signOut;
  }

  Future signInWithEmailPwd(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future registerWithEmailPwd(String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }
}
