import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:health_edu_app/theme/uticare_theme.dart';

void main() {
  testWidgets('UtiCare Theme and basic smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: UtiCareTheme.themeData,
        home: const Scaffold(
          body: Center(child: Text('UtiCare')),
        ),
      ),
    );

    expect(find.text('UtiCare'), findsOneWidget);
  });
}
