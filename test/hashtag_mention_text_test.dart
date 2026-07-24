import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/screens/other_user_profile_screen.dart';
import 'package:camper/screens/search_screen.dart';
import 'package:camper/widgets/hashtag_mention_text.dart';

TextSpan? _findSpan(InlineSpan root, String text) {
  if (root is TextSpan) {
    if (root.text == text) return root;
    for (final child in root.children ?? const <InlineSpan>[]) {
      final found = _findSpan(child, text);
      if (found != null) return found;
    }
  }
  return null;
}

TextSpan _rootSpan(WidgetTester tester) {
  final richText = tester.widget<RichText>(
    find.descendant(
      of: find.byType(HashtagMentionText),
      matching: find.byType(RichText),
    ),
  );
  return richText.text as TextSpan;
}

Future<void> _pumpTriggerButton(
  WidgetTester tester,
  void Function(BuildContext context) onPressed,
) async {
  // Some destinations (Other User Profile) use sliver-based content that
  // only mounts within the viewport — bump the surface like
  // other_user_profile_screen_test.dart does for the same reason.
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MaterialApp(
      routes: {
        '/profile': (context) =>
            const Scaffold(body: Text('Profile page')),
      },
      home: Builder(
        builder: (context) => Scaffold(
          body: ElevatedButton(
            onPressed: () => onPressed(context),
            child: const Text('Trigger'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Trigger'));
  await tester.pumpAndSettle();
}

void main() {
  group('HashtagMentionText', () {
    testWidgets('renders plain text with no tokens as a single span', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HashtagMentionText('Hello world, no tags here.'),
        ),
      );

      final span = _findSpan(_rootSpan(tester), 'Hello world, no tags here.');
      expect(span, isNotNull);
      expect(span!.recognizer, isNull);
    });

    testWidgets('a hashtag span fires onHashtagTap with the tag minus #', (
      tester,
    ) async {
      String? tapped;
      await tester.pumpWidget(
        MaterialApp(
          home: HashtagMentionText(
            'Great climb! #Daraitan',
            onHashtagTap: (tag) => tapped = tag,
          ),
        ),
      );

      final span = _findSpan(_rootSpan(tester), '#Daraitan');
      expect(span, isNotNull);
      expect(span!.recognizer, isA<TapGestureRecognizer>());
      (span.recognizer! as TapGestureRecognizer).onTap!();

      expect(tapped, 'Daraitan');
    });

    testWidgets('a mention span fires onMentionTap with the handle minus @', (
      tester,
    ) async {
      String? tapped;
      await tester.pumpWidget(
        MaterialApp(
          home: HashtagMentionText(
            'Nice one @MiguelIbarra!',
            onMentionTap: (handle) => tapped = handle,
          ),
        ),
      );

      final span = _findSpan(_rootSpan(tester), '@MiguelIbarra');
      expect(span, isNotNull);
      (span!.recognizer! as TapGestureRecognizer).onTap!();

      expect(tapped, 'MiguelIbarra');
    });

    testWidgets('trailing punctuation is excluded from the token', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: HashtagMentionText('Great climb! #Daraitan.')),
      );

      final root = _rootSpan(tester);
      expect(_findSpan(root, '#Daraitan'), isNotNull);
      expect(_findSpan(root, '#Daraitan.'), isNull);
    });

    testWidgets('mixed plain and tagged text renders both in order', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HashtagMentionText('Hey @MiguelIbarra, check out #Daraitan!'),
        ),
      );

      final root = _rootSpan(tester);
      expect(_findSpan(root, 'Hey '), isNotNull);
      expect(_findSpan(root, '@MiguelIbarra'), isNotNull);
      expect(_findSpan(root, ', check out '), isNotNull);
      expect(_findSpan(root, '#Daraitan'), isNotNull);
      expect(_findSpan(root, '!'), isNotNull);
    });
  });

  group('openHashtagSearch', () {
    testWidgets('opens Search pre-filled and already showing results', (
      tester,
    ) async {
      await _pumpTriggerButton(
        tester,
        (context) => openHashtagSearch(context, 'Daraitan'),
      );

      expect(find.byType(SearchScreen), findsOneWidget);
      expect(find.text('Mt. Daraitan campsite'), findsOneWidget);
    });
  });

  group('openMentionedProfile', () {
    testWidgets('a self-mention navigates to the /profile route', (
      tester,
    ) async {
      await _pumpTriggerButton(
        tester,
        (context) => openMentionedProfile(context, 'AnaDelaCruz'),
      );

      expect(find.text('Profile page'), findsOneWidget);
    });

    testWidgets('a known user resolves to their real profile', (
      tester,
    ) async {
      await _pumpTriggerButton(
        tester,
        (context) => openMentionedProfile(context, 'MiguelIbarra'),
      );

      expect(find.byType(OtherUserProfileScreen), findsOneWidget);
      expect(
        find.text('Lakeside camping enthusiast. Always up for a crew trip.'),
        findsOneWidget,
      );
    });

    testWidgets('an unknown handle still opens a synthesized profile', (
      tester,
    ) async {
      await _pumpTriggerButton(
        tester,
        (context) => openMentionedProfile(context, 'SomeoneNew'),
      );

      expect(find.byType(OtherUserProfileScreen), findsOneWidget);
      expect(find.text('SomeoneNew'), findsWidgets);
    });
  });
}
