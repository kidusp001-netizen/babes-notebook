import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test placeholder', (WidgetTester tester) async {
    // Full app requires Supabase credentials; integration tests run separately.
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text("Babe's Notebook"))),
    );
    expect(find.text("Babe's Notebook"), findsOneWidget);
  });
}
