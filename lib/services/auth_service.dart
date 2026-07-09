import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';
import '../models/user_role.dart';

/// Wraps Supabase Auth calls. When Supabase isn't configured
/// (see [Env.isConfigured]), falls back to a dummy implementation that
/// always succeeds after a short delay, so the app can be clicked through
/// end to end without a real backend. Wiring up real credentials in `.env`
/// switches this back to real Supabase calls automatically.
class AuthService {
  AuthService._();

  static final instance = AuthService._();

  /// Tracks the [UserRole] chosen at sign-up when running in dummy mode,
  /// since there's no real backend to persist it. Mirrors what
  /// `user_metadata` does for real Supabase accounts.
  final Map<String, UserRole> _dummyRoles = {};

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
  }) {
    if (!Env.isConfigured) {
      _dummyRoles[_normalize(email)] = role;
      return _dummyDelay();
    }
    return Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName, 'role': role.value},
    );
  }

  Future<UserRole> signIn({
    required String email,
    required String password,
  }) async {
    if (!Env.isConfigured) {
      await _dummyDelay();
      return _dummyRoles[_normalize(email)] ?? UserRole.camper;
    }
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return UserRole.fromValue(response.user?.userMetadata?['role'] as String?);
  }

  Future<void> resetPassword(String email) {
    if (!Env.isConfigured) return _dummyDelay();
    return Supabase.instance.client.auth.resetPasswordForEmail(email);
  }

  Future<void> _dummyDelay() =>
      Future.delayed(const Duration(milliseconds: 500));

  String _normalize(String email) => email.trim().toLowerCase();
}
