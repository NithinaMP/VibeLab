// ============================================================
// VibeLab — auth_service.dart
// Handles all Firebase Authentication operations.
// Google Sign-in + Email/Password + Profile management.
// ============================================================

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ----------------------------------------------------------
  // Current user getter
  // ----------------------------------------------------------
  User? get currentUser => _auth.currentUser;

  // ----------------------------------------------------------
  // Auth state stream
  // Listen to this in AuthProvider to react to login/logout
  // ----------------------------------------------------------
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ----------------------------------------------------------
  // GOOGLE SIGN IN
  // ----------------------------------------------------------
  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User cancelled

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // Create/update user profile in Firestore
      await _createOrUpdateUserProfile(userCredential.user!);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e.code));
    } catch (e) {
      throw Exception('Google sign in failed: $e');
    }
  }

  // ----------------------------------------------------------
  // EMAIL + PASSWORD REGISTER
  // ----------------------------------------------------------
  Future<UserCredential> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Set display name
      await userCredential.user!.updateDisplayName(displayName);
      await userCredential.user!.reload();

      // Create user profile in Firestore
      await _createOrUpdateUserProfile(
        _auth.currentUser!,
        displayName: displayName,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e.code));
    }
  }

  // ----------------------------------------------------------
  // EMAIL + PASSWORD SIGN IN
  // ----------------------------------------------------------
  Future<UserCredential> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update last seen
      await _createOrUpdateUserProfile(userCredential.user!);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e.code));
    }
  }

  // ----------------------------------------------------------
  // SIGN OUT
  // ----------------------------------------------------------
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ----------------------------------------------------------
  // UPDATE DISPLAY NAME
  // ----------------------------------------------------------
  Future<void> updateDisplayName(String newName) async {
    await _auth.currentUser!.updateDisplayName(newName);
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .update({'display_name': newName});
  }

  // ----------------------------------------------------------
  // UPDATE PROFILE PHOTO URL
  // ----------------------------------------------------------
  Future<void> updatePhotoUrl(String photoUrl) async {
    await _auth.currentUser!.updatePhotoURL(photoUrl);
    await _firestore
        .collection('users')
        .doc(_auth.currentUser!.uid)
        .update({'photo_url': photoUrl});
  }

  // ----------------------------------------------------------
  // FORGOT PASSWORD
  // ----------------------------------------------------------
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_friendlyAuthError(e.code));
    }
  }

  // ----------------------------------------------------------
  // DELETE ACCOUNT
  // Deletes Firestore data + Auth account
  // ----------------------------------------------------------
  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Delete all user vibes from Firestore
      final vibesSnapshot = await _firestore
          .collection('vibes')
          .where('user_id', isEqualTo: user.uid)
          .get();

      for (final doc in vibesSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete user profile
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth account
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        throw Exception(
          'Please sign out and sign back in before deleting your account.',
        );
      }
      throw Exception(_friendlyAuthError(e.code));
    }
  }

  // ----------------------------------------------------------
  // GET USER STATS FROM FIRESTORE
  // ----------------------------------------------------------
  Future<Map<String, dynamic>> getUserStats(String uid) async {
    try {
      final userDoc =
      await _firestore.collection('users').doc(uid).get();

      final vibesSnapshot = await _firestore
          .collection('vibes')
          .where('user_id', isEqualTo: uid)
          .get();

      return {
        'total_vibes': vibesSnapshot.docs.length,
        'joined_at': userDoc.data()?['created_at'],
        'display_name': userDoc.data()?['display_name'] ?? '',
        'photo_url': userDoc.data()?['photo_url'] ?? '',
      };
    } catch (e) {
      return {'total_vibes': 0};
    }
  }

  // ----------------------------------------------------------
  // PRIVATE: Create or update user profile in Firestore
  // Called after every sign in to keep data fresh
  // ----------------------------------------------------------
  Future<void> _createOrUpdateUserProfile(
      User user, {
        String? displayName,
      }) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    if (!userDoc.exists) {
      // First time — create profile
      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'display_name': displayName ?? user.displayName ?? 'Vibe Creator',
        'photo_url': user.photoURL ?? '',
        'created_at': FieldValue.serverTimestamp(),
        'last_seen': FieldValue.serverTimestamp(),
        'total_vibes': 0,
      });
    } else {
      // Returning user — update last seen
      await userRef.update({
        'last_seen': FieldValue.serverTimestamp(),
        if (user.photoURL != null) 'photo_url': user.photoURL,
      });
    }
  }

  // ----------------------------------------------------------
  // PRIVATE: Friendly error messages
  // ----------------------------------------------------------
  String _friendlyAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection. Check your network.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }
}