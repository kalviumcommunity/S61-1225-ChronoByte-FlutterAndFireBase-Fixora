import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Validates password according to requirements:
  /// 1. At least 6 characters
  /// 2. Starts with a capital letter
  /// 3. Contains at least one symbol
  String? validatePassword(String password) {
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!password[0].contains(RegExp(r'[A-Z]'))) {
      return 'Password must start with a capital letter';
    }
    if (!password.contains(RegExp(r'[!@#$%^&*(),.?\":{}|<>]'))) {
      return 'Password must contain at least one symbol (!@#\$%^&*(),.?\":{}|<>)';
    }
    return null;
  }

  /// Checks if username already exists in Firestore
  Future<bool> isUsernameExists(String username) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error checking username: $e');
    }
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Store username in Firestore
    await _firestore.collection('users').doc(userCredential.user!.uid).set({
      'username': username,
      'email': email,
      'createdAt': DateTime.now(),
    });

    return userCredential;
  }

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signOut() => _auth.signOut();
}
