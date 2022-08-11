import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthenticationService {
  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Future<String?> signIn({required String email, required String password}) async {
    await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    return "Signed in";
  }

  Future<UserCredential?> signUp({required String email, required String password, required BuildContext context}) async {
      UserCredential creds = await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return creds;
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

}