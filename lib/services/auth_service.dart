import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

/// Wraps Supabase Auth calls. When Supabase isn't configured
/// (see [Env.isConfigured]), falls back to a dummy implementation that
/// always succeeds after a short delay, so the app can be clicked through
/// end to end without a real backend. Wiring up real credentials in `.env`
/// switches this back to real Supabase calls automatically.
class AuthService {
  AuthService._();

  static final instance = AuthService._();

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
  }) {
    if (!Env.isConfigured) return _dummyDelay();
    return Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': fullName},
    );
  }

  Future<void> signIn({required String email, required String password}) {
    if (!Env.isConfigured) return _dummyDelay();
    return Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> resetPassword(String email) {
    if (!Env.isConfigured) return _dummyDelay();
    return Supabase.instance.client.auth.resetPasswordForEmail(email);
  }

  Future<void> _dummyDelay() =>
      Future.delayed(const Duration(milliseconds: 500));
}
