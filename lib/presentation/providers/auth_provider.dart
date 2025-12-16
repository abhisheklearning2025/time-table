import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/services/auth_service.dart';

/// Provider for managing Firebase authentication state
/// Handles anonymous sign-in, sign-out, and auth state changes
class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  AuthProvider({required AuthService authService}) : _authService = authService {
    _init();
  }

  /// Initialize provider and listen to auth state changes
  void _init() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      _currentUser = user;
      notifyListeners();
    });

    // Set initial user
    _currentUser = _authService.currentUser;
  }

  /// Current user
  User? get currentUser => _currentUser;

  /// Current user ID
  String? get currentUserId => _currentUser?.uid;

  /// Check if user is signed in
  bool get isSignedIn => _currentUser != null;

  /// Check if user is a new user (created < 5 minutes ago)
  bool get isNewUser => _authService.isNewUser;

  /// Check if loading
  bool get isLoading => _isLoading;

  /// Error message
  String? get error => _error;

  /// User metadata
  UserMetadata? get metadata => _currentUser?.metadata;

  /// Creation time
  DateTime? get createdAt => _currentUser?.metadata.creationTime;

  /// Last sign-in time
  DateTime? get lastSignInAt => _currentUser?.metadata.lastSignInTime;

  /// Sign in anonymously
  /// Auto-called on app launch, but can be called manually if needed
  Future<void> signInAnonymously() async {
    if (isSignedIn) {
      debugPrint('AuthProvider: Already signed in');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final userId = await _authService.signInAnonymously();
      debugPrint('AuthProvider: Signed in successfully - $userId');
      // User will be updated via auth state listener
    } catch (e) {
      _setError('Failed to sign in: $e');
      debugPrint('AuthProvider: Sign in error - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Sign out
  /// Clears anonymous user session
  Future<void> signOut() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.signOut();
      debugPrint('AuthProvider: Signed out successfully');
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to sign out: $e');
      debugPrint('AuthProvider: Sign out error - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Delete account
  /// Permanently deletes the anonymous user account
  Future<void> deleteAccount() async {
    if (!isSignedIn) {
      _setError('No user signed in');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      await _authService.deleteAccount();
      debugPrint('AuthProvider: Account deleted successfully');
      _currentUser = null;
      notifyListeners();
    } catch (e) {
      _setError('Failed to delete account: $e');
      debugPrint('AuthProvider: Delete account error - $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Reload current user
  /// Fetches latest user data from Firebase
  Future<void> reloadUser() async {
    if (!isSignedIn) return;

    try {
      await _currentUser?.reload();
      _currentUser = _authService.currentUser;
      notifyListeners();
    } catch (e) {
      debugPrint('AuthProvider: Reload user error - $e');
    }
  }

  /// Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Set error message
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error message
  void _clearError() {
    _error = null;
  }

  /// Clear error manually (for UI)
  void clearError() {
    _clearError();
    notifyListeners();
  }

  @override
  void dispose() {
    // Don't dispose auth service (it's managed by GetIt)
    super.dispose();
  }
}
