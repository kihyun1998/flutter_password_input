import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_password_input/flutter_password_input.dart';

void main() {
  group('PasswordTextField', () {
    testWidgets('renders correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
            ),
          ),
        ),
      );

      expect(find.byType(PasswordTextField), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows hint text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              hintText: 'Enter password',
            ),
          ),
        ),
      );

      expect(find.text('Enter password'), findsOneWidget);
    });

    testWidgets('toggles password visibility', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
            ),
          ),
        ),
      );

      // Initial state: password hidden (visibility_off icon)
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsNothing);

      // Tap toggle button
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Password visible state (visibility icon)
      expect(find.byIcon(Icons.visibility), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsNothing);
    });

    testWidgets('hides visibility toggle when disabled', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              showVisibilityToggle: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.visibility_off), findsNothing);
      expect(find.byIcon(Icons.visibility), findsNothing);
    });

    testWidgets('calls onChange when text changes', (tester) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              onChange: (value) => changedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test123');
      expect(changedValue, 'test123');
    });

    testWidgets('calls onFocus when focused', (tester) async {
      bool focusCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              onFocus: () => focusCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();

      expect(focusCalled, isTrue);
    });

    testWidgets('applies theme styles', (tester) async {
      const theme = PasswordTextFieldTheme(
        width: 300,
        height: 60,
        borderRadius: 12,
        backgroundColor: Colors.grey,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              theme: theme,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(PasswordTextField),
          matching: find.byType(SizedBox),
        ),
      );

      expect(sizedBox.width, 300);
      expect(sizedBox.height, 60);
    });
  });

  group('PasswordTextFieldTheme', () {
    test('defaults provides default values', () {
      const defaults = PasswordTextFieldTheme.defaults;

      expect(defaults.width, 250);
      expect(defaults.height, 48);
      expect(defaults.borderWidth, 1);
      expect(defaults.borderRadius, 8);
      expect(defaults.visibilityIconSize, 20);
    });

    test('merge combines two themes', () {
      const theme1 = PasswordTextFieldTheme(
        width: 300,
        borderRadius: 12,
      );

      const theme2 = PasswordTextFieldTheme(
        width: 200, // theme1 takes priority
        height: 50,
        borderWidth: 2,
      );

      final merged = theme1.merge(theme2);

      expect(merged.width, 300); // keeps theme1 value
      expect(merged.height, 50); // from theme2
      expect(merged.borderRadius, 12); // keeps theme1 value
      expect(merged.borderWidth, 2); // from theme2
    });

    test('copyWith creates a copy with overrides', () {
      const original = PasswordTextFieldTheme(
        width: 300,
        height: 50,
        borderRadius: 8,
      );

      final copied = original.copyWith(
        width: 400,
        borderWidth: 2,
      );

      expect(copied.width, 400);
      expect(copied.height, 50); // keeps original
      expect(copied.borderRadius, 8); // keeps original
      expect(copied.borderWidth, 2);
    });
  });
}
