import 'package:elderly_prototype_app/features/dashboard/screens/start_screen.dart';
import 'package:elderly_prototype_app/features/authentication/data/auth_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

// You might not need the client ID variable with the older version
// IF your setup files (google-services.json/plist) are correct.
// const String googleWebClientId =
//     "776774578845-u6g6ifbhla06vvjkg414t2ntoa3qtuif.apps.googleusercontent.com";

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. Get the GoogleSignIn instance the simple way.
  final GoogleSignIn googleSignIn =
      GoogleSignIn(); // <-- FIX 1: This constructor should work in v6.1.0

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<User?> signInWithGoogle(BuildContext context) async {
    try {
      // 2. Trigger the interactive sign-in flow.
      final GoogleSignInAccount? googleUser = await googleSignIn
          .signIn(); // <-- FIX 2: Correct method name `signIn()`

      // If the user canceled, signIn() will return null.
      if (googleUser == null) {
        return null;
      }

      // Get authentication tokens
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth
            .accessToken, // You may need access token in older versions
        idToken: googleAuth.idToken,
      );

      final UserCredential result =
          await _auth.signInWithCredential(credential);

      final User? userDetails = result.user;

      if (userDetails != null) {
        final Map<String, dynamic> userInfoMap = {
          "email": userDetails.email,
          "name": userDetails.displayName,
          "imgUrl": userDetails.photoURL,
          "id": userDetails.uid,
        };

        await AuthDatabase().addUser(userDetails.uid, userInfoMap);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => StartScreen()),
        );
      }

      return userDetails;
    } catch (e) {
      // handle errors gracefully
      print('Google sign-in error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $e')),
      );
      debugPrint('Google sign-in failed: $e');

      return null;
    }
  }
}
