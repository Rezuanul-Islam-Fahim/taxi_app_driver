import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/database_service.dart';

import '../models/user_model.dart' as user;

class AuthServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _db = DatabaseService();

  Future<bool> login({String? email, String? password}) async {
    if (kDebugMode) {
      print(email);
      print(password);
    }

    try {
      if (await _db.checkUser(email!)) {
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password!,
        );
      } else {
        if (kDebugMode) {
          print('User not found');

          return false;
        }
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }

      return false;
    }
  }

  Future<bool> createAccount({
    String? userName,
    String? email,
    String? password,
  }) async {
    if (kDebugMode) {
      print(userName);
      print(email);
      print(password);
    }

    try {
      UserCredential userData = await _auth.createUserWithEmailAndPassword(
        email: email!,
        password: password!,
      );
      await _db.storeUser(
        user.User(
          id: userData.user!.uid,
          username: userName,
          email: email,
        ),
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }

      return false;
    }
  }
}
