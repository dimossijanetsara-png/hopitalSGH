import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sghl_mobile/app.dart';

void main() {
  testWidgets('SGHL app démarre sans erreur', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SGHLApp()),
    );
    // L'écran de chargement initial doit s'afficher (CircularProgressIndicator)
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
