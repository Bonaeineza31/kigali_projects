import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Track auth state changes
  Stream<User?> get user {
    return _auth.authStateChanges();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Error in signInWithEmailAndPassword: ${e.toString()}');
      rethrow;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(String email, String password, String name) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      User? user = result.user;
      if (user != null) {
        // Create user profile in Firestore
        await _db.collection('users').doc(user.uid).set({
          'email': email,
          'name': name,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        // Send verification email
        await user.sendEmailVerification();
      }
      return user;
    } catch (e) {
      print('Error in registerWithEmailAndPassword: ${e.toString()}');
      rethrow;
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      print('Error sending verification email: $e');
    }
  }

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Reload user to get updated verification status
  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  // Sign out
  Future<void> signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print('Error signing out: ${e.toString()}');
    }
  }
}
