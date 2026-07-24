import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:camper/screens/photo_lightbox_screen.dart';

// A real, minimal 1x1 transparent PNG — Image.memory needs decodable bytes,
// not arbitrary placeholder data, or it fails to paint in the test.
final Uint8List _pixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhf'
  'DwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

void main() {
  group('PhotoLightboxScreen', () {
    testWidgets('shows a 1-based index counter starting at the first photo', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PhotoLightboxScreen(photos: [_pixel, _pixel, _pixel]),
        ),
      );

      expect(find.text('1 of 3'), findsOneWidget);
    });

    testWidgets('honors a non-zero initialIndex', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: PhotoLightboxScreen(
            photos: [_pixel, _pixel, _pixel],
            initialIndex: 2,
          ),
        ),
      );

      expect(find.text('3 of 3'), findsOneWidget);
    });

    testWidgets('swiping to the next photo updates the counter', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: PhotoLightboxScreen(photos: [_pixel, _pixel])),
      );

      expect(find.text('1 of 2'), findsOneWidget);

      await tester.drag(
        find.byKey(const Key('photoLightboxPageView')),
        const Offset(-3000, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('2 of 2'), findsOneWidget);
    });
  });
}
