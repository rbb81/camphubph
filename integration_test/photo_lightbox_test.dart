import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:camper/screens/photo_lightbox_screen.dart';

// A real, minimal 1x1 transparent PNG — Image.memory needs decodable bytes.
final Uint8List _pixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhf'
  'DwAChwGA60e6kgAAAABJRU5ErkJggg==',
);

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Photo Lightbox (real browser)', () {
    testWidgets('swiping to the next photo updates the counter', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(home: PhotoLightboxScreen(photos: [_pixel, _pixel])),
      );
      await tester.pumpAndSettle();

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
