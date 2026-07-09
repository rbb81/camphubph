import 'user_role.dart';

/// The account info resolved after a successful sign-in — used to route
/// by [role] and, for camp owners, to populate the dashboard's business
/// header without a separate profile fetch.
class AuthResult {
  const AuthResult({
    required this.role,
    required this.email,
    required this.fullName,
    this.campsiteName,
  });

  final UserRole role;
  final String email;
  final String fullName;
  final String? campsiteName;
}
