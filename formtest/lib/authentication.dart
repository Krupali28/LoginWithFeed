import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:formtest/user.dart';

abstract class BaseAuth {
  Future<String> signIn(String email, String password, BuildContext context);

  Future<String> signUp(String email, String password);

  Future<FirebaseUser> getCurrentUser();

  Future<void> sendEmailVerification();

  Future<void> signOut();

  Future<bool> isEmailVerified();
}

class Auth implements BaseAuth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  

  Future<String> signIn(String email, String password, context) async {
    FirebaseUser user;
    try {
      user = await _firebaseAuth.signInWithEmailAndPassword(
          email: email, password: password);
      return user.uid;
    } on AuthException catch (error) {
      // return _buildErrorDialog(error.message, context);
      return ("error");
    } on Exception catch (error) {
      //  return _buildErrorDialog(error.toString(), context);
      return ("error");
    }
  }
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Future<String> signUp(String email, String password) async {
    FirebaseUser user = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
        _addNewUser(email, user.uid);
    return user.uid;
  }

  Future<FirebaseUser> getCurrentUser() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user;
  }

  Future<void> signOut() async {
    return _firebaseAuth.signOut();
  }

  Future<void> sendEmailVerification() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    user.sendEmailVerification();
  }

  Future<bool> isEmailVerified() async {
    FirebaseUser user = await _firebaseAuth.currentUser();
    return user.isEmailVerified;
  }

  _addNewUser(String email,String userId) {
    if (email.length > 0) {
      User objUser = new User( userId,'test', email,0,null);
      _database.reference().child("user").push().set(objUser.toJson());
    }
  }

  _updateUser(User user) {
    //Toggle completed
    user.postCount = user.postCount++;
    if (user != null) {
      _database.reference().child("user").child(user.userId).set(user.toJson());
    }
  }
}
