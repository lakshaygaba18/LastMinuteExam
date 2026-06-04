import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final _supabase = Supabase.instance.client;

  // Get current user
  static User? get currentUser => _supabase.auth.currentUser;

  // Check if logged in
  static bool get isLoggedIn => currentUser != null;

  // Sign up with email and password
  static Future<String?> signUp(String email, String password, String name) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      if (response.user != null) return null; // success
      return "Signup failed. Please try again.";
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  // Login with email and password
  static Future<String?> login(String email, String password) async {
    try {
      await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return null; // success
    } on AuthException catch (e) {
      return e.message;
    } catch (e) {
      return "Something went wrong. Please try again.";
    }
  }

  // Logout
  static Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  // Get user name
  static String get userName {
    final meta = currentUser?.userMetadata;
    return meta?['name'] ?? currentUser?.email?.split('@').first ?? 'Student';
  }
}
