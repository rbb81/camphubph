import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/models/community.dart';
import 'package:camper/screens/create_community_screen.dart';

class _ResultCapture {
  Community? value;
}

/// Hosts CreateCommunityScreen behind a button push so the popped result can
/// be captured, mirroring how CommunitiesScreen actually opens it.
Future<_ResultCapture> _pumpCreateCommunityHost(WidgetTester tester) async {
  final capture = _ResultCapture();
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () async {
                capture.value = await Navigator.of(context).push<Community>(
                  MaterialPageRoute(
                    builder: (_) => const CreateCommunityScreen(),
                  ),
                );
              },
              child: const Text('Open Create Community'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open Create Community'));
  await tester.pumpAndSettle();
  return capture;
}

void main() {
  group('CreateCommunityScreen', () {
    testWidgets('shows validation errors when name and description are empty', (
      tester,
    ) async {
      await _pumpCreateCommunityHost(tester);

      await tester.tap(find.byKey(const Key('createCommunitySubmitButton')));
      await tester.pump();

      expect(find.text('Give your community a name.'), findsOneWidget);
      expect(
        find.text('Describe what this community is about.'),
        findsOneWidget,
      );
    });

    testWidgets('defaults to Public and pops a Community with the entered fields', (
      tester,
    ) async {
      final capture = await _pumpCreateCommunityHost(tester);

      await tester.enterText(
        find.byKey(const Key('communityNameField')),
        'Sierra Madre Hikers',
      );
      await tester.enterText(
        find.byKey(const Key('communityDescriptionField')),
        'Trail conditions and meetups around the Sierra Madre range.',
      );
      await tester.tap(find.byKey(const Key('createCommunitySubmitButton')));
      await tester.pumpAndSettle();

      expect(capture.value, isNotNull);
      expect(capture.value!.name, 'Sierra Madre Hikers');
      expect(
        capture.value!.description,
        'Trail conditions and meetups around the Sierra Madre range.',
      );
      expect(capture.value!.isPrivate, isFalse);
      expect(capture.value!.isJoined, isTrue);
      expect(capture.value!.memberCount, 1);
    });

    testWidgets('selecting Private pops a Community with isPrivate true', (
      tester,
    ) async {
      final capture = await _pumpCreateCommunityHost(tester);

      await tester.enterText(
        find.byKey(const Key('communityNameField')),
        'Private Trailblazers',
      );
      await tester.enterText(
        find.byKey(const Key('communityDescriptionField')),
        'Invite-only group for close friends.',
      );
      await tester.tap(find.text('Private'));
      await tester.pump();
      await tester.tap(find.byKey(const Key('createCommunitySubmitButton')));
      await tester.pumpAndSettle();

      expect(capture.value, isNotNull);
      expect(capture.value!.isPrivate, isTrue);
    });

    testWidgets('cancel pops without a result', (tester) async {
      final capture = await _pumpCreateCommunityHost(tester);

      await tester.tap(find.byKey(const Key('cancelCreateCommunityButton')));
      await tester.pumpAndSettle();

      expect(capture.value, isNull);
    });
  });
}
