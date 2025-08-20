import 'dart:core';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthentication {
  FirebaseAuth auth = FirebaseAuth.instance;

  Future<User?> SignupwithEmailandPassword(
      String email, String password) async {
    try {
      UserCredential credential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = credential.user;
      if (user != null) {
        await user.sendEmailVerification();
        Fluttertoast.showToast(
            msg: 'Verification email is sent. Check your Inbox',
            backgroundColor: Colors.green,
            textColor: Colors.white);
      }
      return user;
    } on FirebaseAuthException catch (e) {
      Fluttertoast.showToast(msg:'SignUp failed: $e');
      rethrow;
    }
  }

  Future<User?> SigninwithEmailandPassword(
      String email, String password) async {
    try {
      UserCredential credential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user;
    } on FirebaseAuthException catch (e) {
      _showErrorToast(e.message ?? "Login Failed");
      return null;
    }
  }

 Future<User?> signInWithGoogle() async {
  try {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      _showErrorToast('Google Sign-In was cancelled');
      return null;
    }

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    Fluttertoast.showToast(
      msg: 'Signed in as ${userCredential.user?.displayName}',
      backgroundColor: Colors.blueGrey,
      textColor: Colors.white,
    );

    return userCredential.user;

  } on FirebaseAuthException catch (e) {
    _showErrorToast(e.message ?? "Google Sign-In failed due to Firebase error");
    return null;

  } catch (e) {
    _showErrorToast("Unexpected error: ${e.toString()}");
    return null;
  }
}


  Future<void> ResetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast(
          msg: 'Link Sent to your email',
          backgroundColor: Colors.green,
          textColor: Colors.white);
    } on FirebaseAuthException catch (e) {
      _showErrorToast(e.message ?? 'Something Went Wrong');
    }
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
        textColor: Colors.white);
  }
}
