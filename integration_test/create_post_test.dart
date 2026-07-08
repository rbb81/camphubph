import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/data/sample_profile.dart';
import 'package:camper/screens/create_post_screen.dart';

Future<void> pumpCreatePostScreen(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(home: CreatePostScreen(author: sampleProfile)),
  );
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Create Post (real browser)', () {
    testWidgets('shows a validation error when caption is empty', (
      tester,
    ) async {
      await pumpCreatePostScreen(tester);

      await tester.tap(find.byKey(const Key('publishPostButton')));
      await tester.pumpAndSettle();

      expect(find.text('Write something to post.'), findsOneWidget);
    });

    testWidgets('cancel pops the screen', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreatePostScreen(author: sampleProfile),
                    ),
                  ),
                  child: const Text('Open Create Post'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open Create Post'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('cancelPostButton')));
      await tester.pumpAndSettle();

      expect(find.text('Open Create Post'), findsOneWidget);
    });
  });
}
