// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter_tutorials/main.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('switches between login and register screens', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('login-primary-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('register-primary-button')), findsNothing);

    await tester.ensureVisible(
      find.byKey(const ValueKey('login-secondary-button')),
    );
    await tester.tap(find.byKey(const ValueKey('login-secondary-button')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('register-primary-button')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('login-primary-button')), findsNothing);

    await tester.ensureVisible(
      find.byKey(const ValueKey('register-secondary-button')),
    );
    await tester.tap(find.byKey(const ValueKey('register-secondary-button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('login-primary-button')), findsOneWidget);
    expect(find.byKey(const ValueKey('register-primary-button')), findsNothing);
  });

  testWidgets('logs in with mock credentials and opens main tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('email-field')),
      'admin@claude.ai',
    );
    await tester.enterText(
      find.byKey(const ValueKey('password-field')),
      '147258369',
    );

    await tester.tap(find.byKey(const ValueKey('login-primary-button')));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsWidgets);
    expect(find.text('Categories'), findsWidgets);
    expect(find.text('Cart'), findsWidgets);
    expect(find.text('Updates'), findsWidgets);
    expect(find.text('Account'), findsWidgets);
    expect(find.text('Good morning, Tony'), findsOneWidget);
  });
}
