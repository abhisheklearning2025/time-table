import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Anonymous Authentication Service
/// Auto sign-in on app launch, persist user ID
/// No visible login UI - everything happens in background
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Get current user ID (Anonymous UID)
  String? get currentUserId => _auth.currentUser?.uid;

  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;

  /// Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in anonymously
  /// This is called automatically on app launch
  /// If user already signed in, returns existing user
  Future<String> signInAnonymously() async {
    try {
      // Check if already signed in
      if (isSignedIn) {
        return currentUserId!;
      }

      // Sign in anonymously
      final userCredential = await _auth.signInAnonymously();
      final userId = userCredential.user?.uid;

      if (userId == null) {
        throw Exception('Failed to get user ID after anonymous sign-in');
      }

      return userId;
    } catch (e) {
      throw Exception('Anonymous sign-in failed: $e');
    }
  }

  /// Sign out (for testing/debugging only)
  /// Note: Signing out will lose access to user's shared timetables
  /// since anonymous auth doesn't have account recovery
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Delete account (for testing/debugging only)
  /// Warning: This permanently deletes the user and all their data
  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user != null) {
      await user.delete();
    }
  }

  /// Get user creation timestamp
  DateTime? get userCreatedAt => currentUser?.metadata.creationTime;

  /// Get last sign-in timestamp
  DateTime? get lastSignInAt => currentUser?.metadata.lastSignInTime;

  /// Check if this is a new user (created in last 5 minutes)
  bool get isNewUser {
    final createdAt = userCreatedAt;
    if (createdAt == null) return false;
    return DateTime.now().difference(createdAt).inMinutes < 5;
  }
}
