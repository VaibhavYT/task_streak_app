import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  User? _user;
  bool _isLoading = false;
  late StreamSubscription<AuthState> _authSubscription;

  AuthProvider() {
    _initialize();
  }

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _user != null;

  void _initialize() {
    // Set initial user from current session
    _user = _supabase.auth.currentUser;

    // Listen to auth state changes
    _authSubscription = _supabase.auth.onAuthStateChange.listen(
      (AuthState state) {
        final event = state.event;
        final session = state.session;
        _onAuthStateChange(event, session);
      },
    );
  }

  void _onAuthStateChange(AuthChangeEvent event, Session? session) {
    debugPrint('Auth state changed: $event');

    switch (event) {
      case AuthChangeEvent.signedIn:
        _user = session?.user;
        _isLoading = false;
        break;
      case AuthChangeEvent.signedOut:
        _user = null;
        _isLoading = false;
        break;
      case AuthChangeEvent.userUpdated:
        _user = session?.user;
        _isLoading = false;
        break;
      case AuthChangeEvent.passwordRecovery:
        _isLoading = false;
        break;
      default:
        _isLoading = false;
        break;
    }

    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        debugPrint('Sign up successful for: ${response.user!.email}');
      }
    } on AuthException catch (error) {
      debugPrint('Sign up error: ${error.message}');
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (error) {
      debugPrint('Unexpected sign up error: $error');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signInWithPassword(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        debugPrint('Sign in successful for: ${response.user!.email}');
      }
    } on AuthException catch (error) {
      debugPrint('Sign in error: ${error.message}');
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (error) {
      debugPrint('Unexpected sign in error: $error');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.signOut();
      debugPrint('Sign out successful');
    } on AuthException catch (error) {
      debugPrint('Sign out error: ${error.message}');
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (error) {
      debugPrint('Unexpected sign out error: $error');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _supabase.auth.resetPasswordForEmail(email);
      debugPrint('Password reset email sent to: $email');

      _isLoading = false;
      notifyListeners();
    } on AuthException catch (error) {
      debugPrint('Password reset error: ${error.message}');
      _isLoading = false;
      notifyListeners();
      rethrow;
    } catch (error) {
      debugPrint('Unexpected password reset error: $error');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
