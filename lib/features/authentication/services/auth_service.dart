import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

// 1. Define the Notifier
class AuthNotifier extends StateNotifier<User?> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  // FIX: one shared GoogleSignIn instance, reused by both sign-in and
  // sign-out, so signing out actually clears the cached Google account too.
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Initial state is set to the current user (if logged in) or null.
  AuthNotifier(this._auth, this._firestore) : super(_auth.currentUser) {
    _auth.authStateChanges().listen((user) {
      // Update the state whenever Firebase reports a change
      state = user;
    });
  }

  // --- Sign Up Method ---
  Future<void> signUpWithEmail(
      {required String email,
      required String password,
      required String name}) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        // 1. Update display name (for profile screen)
        await user.updateDisplayName(name);

        // 2. Save user data to Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': email,
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 3. Explicitly set the state to the new user.
        state = user;
      }
    } catch (e) {
      rethrow;
    }
  }

  // --- Sign In Method ---
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Explicitly set the state to the logged-in user.
      state = userCredential.user;
    } catch (e) {
      rethrow;
    }
  }

  // --- Sign In with Google Method ---
  // FIX: previously called _auth.signInWithPopup(googleProvider), which is
  // a web-only Firebase Auth method with no Android implementation. This
  // now uses the standard native flow: the google_sign_in package shows the
  // on-device account picker, then its tokens are exchanged for a Firebase
  // credential.
  Future<void> signInWithGoogle() async {
    try {
      // Step 1: native Google account picker. Returns null if the user
      // cancels, which is a normal outcome, not an error.
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return;
      }

      // Step 2: get the auth tokens for the chosen Google account.
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Step 3: build a Firebase credential from those tokens.
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Step 4: sign in to Firebase with that credential.
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null &&
          (userCredential.additionalUserInfo?.isNewUser ?? false)) {
        // If it's a new Google user, save them to Firestore, same as a
        // brand-new email/password sign-up.
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Explicitly set the state to the logged-in user.
      state = user;
    } catch (e) {
      rethrow;
    }
  }

  // --- Sign Out Method ---
  Future<void> signOut() async {
    try {
      // FIX: also sign out of Google, not just Firebase. Without this, the
      // Google account picker can silently skip straight back to the same
      // account next time, instead of letting the user choose again.
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      // Explicitly set state to null on sign out
      state = null;
    } catch (e) {
      // Handle sign out error
      rethrow;
    }
  }
}

// 2. This is the main provider that holds the authentication state (User?)
final authNotifierProvider = StateNotifierProvider<AuthNotifier, User?>(
  (ref) {
    final auth = FirebaseAuth.instance;
    final firestore = FirebaseFirestore.instance;
    return AuthNotifier(auth, firestore);
  },
);

// 3. This is the provider the UI calls methods on (e.g., signIn, signUp).
final authServiceProvider = Provider<AuthNotifier>(
  (ref) => ref.read(authNotifierProvider.notifier),
);
