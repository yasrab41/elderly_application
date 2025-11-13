import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 1. Define the Notifier
class AuthNotifier extends StateNotifier<User?> {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

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
  Future<void> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();
      final userCredential = await _auth.signInWithPopup(googleProvider);

      final user = userCredential.user;

      if (user != null && userCredential.additionalUserInfo!.isNewUser) {
        // If it's a new Google user, save them to Firestore
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

// 3. 🚀 CRITICAL FIX: Add a new provider to expose the Notifier (AuthService/AuthNotifier)
// This is the provider the UI will call methods on (e.g., signIn, signUp).
final authServiceProvider = Provider<AuthNotifier>(
  (ref) => ref.read(authNotifierProvider.notifier),
);
