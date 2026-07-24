import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';
import '../models/auth_result.dart';
import '../models/user_role.dart';

/// Tracks what was submitted at sign-up when running in dummy mode, since
/// there's no real backend to persist it. Mirrors what `user_metadata`
/// does for real Supabase accounts.
class _DummyAccount {
  const _DummyAccount({
    required this.role,
    required this.fullName,
    this.campsiteName,
  });

  final UserRole role;
  final String fullName;
  final String? campsiteName;
}

/// Wraps Supabase Auth calls. When Supabase isn't configured
/// (see [Env.isConfigured]), falls back to a dummy implementation that
/// always succeeds after a short delay, so the app can be clicked through
/// end to end without a real backend. Wiring up real credentials in `.env`
/// switches this back to real Supabase calls automatically.
class AuthService {
  AuthService._();

  static final instance = AuthService._();

  final Map<String, _DummyAccount> _dummyAccounts = {};

  /// The most recently signed-in account, if any. Screens that need
  /// account-specific display data (e.g. the Camp Owner Dashboard's
  /// business header) read this instead of receiving it via constructor
  /// args, since this app has no shared state/session layer.
  AuthResult? currentSession;

  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    String? campsiteName,
  }) {
    if (!Env.isConfigured) {
      _dummyAccounts[_normalize(email)] = _DummyAccount(
        role: role,
        fullName: fullName,
        campsiteName: campsiteName,
      );
      return _dummyDelay();
    }
    return Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'role': role.value,
        'campsite_name': ?campsiteName,
      },
    );
  }

  Future<AuthResult> signIn({
    required String email,
    required String password,
  }) async {
    final AuthResult result;
    if (!Env.isConfigured) {
      await _dummyDelay();
      final account = _dummyAccounts[_normalize(email)];
      result = AuthResult(
        role: account?.role ?? UserRole.camper,
        email: email,
        fullName: account?.fullName ?? email,
        campsiteName: account?.campsiteName,
      );
    } else {
      final response = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final metadata = response.user?.userMetadata;
      result = AuthResult(
        role: UserRole.fromValue(metadata?['role'] as String?),
        email: response.user?.email ?? email,
        fullName: metadata?['full_name'] as String? ?? email,
        campsiteName: metadata?['campsite_name'] as String?,
      );
    }
    currentSession = result;
    return result;
  }

  Future<void> resetPassword(String email) {
    if (!Env.isConfigured) return _dummyDelay();
    return Supabase.instance.client.auth.resetPasswordForEmail(email);
  }

  Future<void> signOut() async {
    if (Env.isConfigured) {
      await Supabase.instance.client.auth.signOut();
    }
    currentSession = null;
  }

  Future<void> _dummyDelay() =>
      Future.delayed(const Duration(milliseconds: 500));

  String _normalize(String email) => email.trim().toLowerCase();
}
