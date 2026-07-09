import 'package:flutter_test/flutter_test.dart';

import 'package:camper/models/user_role.dart';
import 'package:camper/services/auth_service.dart';

String _uniqueEmail(String prefix) =>
    '$prefix-${DateTime.now().microsecondsSinceEpoch}@example.com';

void main() {
  group('AuthService role handling (dummy auth fallback)', () {
    test(
      'signIn defaults to camper for an email that never signed up',
      () async {
        final result = await AuthService.instance.signIn(
          email: _uniqueEmail('unknown'),
          password: 'whatever123',
        );

        expect(result.role, UserRole.camper);
        expect(result.campsiteName, isNull);
      },
    );

    test('signUp as camp owner then signIn returns campOwner', () async {
      final email = _uniqueEmail('owner');

      await AuthService.instance.signUp(
        email: email,
        password: 'password123',
        fullName: 'Test Owner',
        role: UserRole.campOwner,
      );
      final result = await AuthService.instance.signIn(
        email: email,
        password: 'password123',
      );

      expect(result.role, UserRole.campOwner);
    });

    test('signUp as camper then signIn returns camper', () async {
      final email = _uniqueEmail('camper');

      await AuthService.instance.signUp(
        email: email,
        password: 'password123',
        fullName: 'Test Camper',
        role: UserRole.camper,
      );
      final result = await AuthService.instance.signIn(
        email: email,
        password: 'password123',
      );

      expect(result.role, UserRole.camper);
    });

    test(
      'signUp with a campsite name round-trips through signIn and sets currentSession',
      () async {
        final email = _uniqueEmail('owner-with-campsite');

        await AuthService.instance.signUp(
          email: email,
          password: 'password123',
          fullName: 'Mang Rodel',
          role: UserRole.campOwner,
          campsiteName: 'Daraitan Basecamp',
        );
        final result = await AuthService.instance.signIn(
          email: email,
          password: 'password123',
        );

        expect(result.fullName, 'Mang Rodel');
        expect(result.campsiteName, 'Daraitan Basecamp');
        expect(result.email, email);
        expect(AuthService.instance.currentSession, same(result));
      },
    );
  });
}
