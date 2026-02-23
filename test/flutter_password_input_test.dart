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

      // Use .first because IconButton internally creates additional SizedBoxes
      final sizedBox = tester.widget<SizedBox>(
        find.descendant(
          of: find.byType(PasswordTextField),
          matching: find.byType(SizedBox),
        ).first,
      );

      expect(sizedBox.width, 300);
      expect(sizedBox.height, 60);
    });

    testWidgets('calls onLostFocus when focus is lost', (tester) async {
      bool lostFocusCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PasswordTextField(
                  labelText: 'Password',
                  onLostFocus: () => lostFocusCalled = true,
                ),
                const TextField(key: Key('other')),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField).first);
      await tester.pump();

      await tester.tap(find.byKey(const Key('other')));
      await tester.pump();

      expect(lostFocusCalled, isTrue);
    });

    testWidgets('calls onSubmitted when text is submitted', (tester) async {
      String? submittedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              onSubmitted: (value) => submittedValue = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'mypassword');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(submittedValue, 'mypassword');
    });

    testWidgets('uses labelText as hintText when useFloatingLabel is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              useFloatingLabel: false,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.labelText, isNull);
      expect(textField.decoration?.hintText, 'Password');
    });

    testWidgets('applies maxLength to text field', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              maxLength: 16,
            ),
          ),
        ),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.maxLength, 16);
    });

    testWidgets('shows custom visibility icons', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              visibilityOffIcon: Icon(Icons.lock),
              visibilityOnIcon: Icon(Icons.lock_open),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.lock_open), findsNothing);

      await tester.tap(find.byIcon(Icons.lock));
      await tester.pump();

      expect(find.byIcon(Icons.lock_open), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsNothing);
    });

    testWidgets('calls prefixWidgetBuilder with none warning initially',
        (tester) async {
      PasswordFieldWarning? capturedWarning;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              prefixWidgetBuilder: (context, warning) {
                capturedWarning = warning;
                return const Icon(Icons.person);
              },
            ),
          ),
        ),
      );

      expect(capturedWarning, PasswordFieldWarning.none);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows suffixWidgetBuilder alongside visibility toggle',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              suffixWidgetBuilder: (context, warning) =>
                  const Icon(Icons.info),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.info), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('calls onPasteBlocked when paste is blocked', (tester) async {
      bool pasteCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              disablePaste: true,
              onPasteBlocked: () => pasteCalled = true,
            ),
          ),
        ),
      );

      final element = tester.element(find.byType(TextField));
      Actions.invoke(
          element, const PasteTextIntent(SelectionChangedCause.keyboard));
      await tester.pump();

      expect(pasteCalled, isTrue);
    });

    testWidgets('shows default paste warning when paste is blocked',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              disablePaste: true,
            ),
          ),
        ),
      );

      final element = tester.element(find.byType(TextField));
      Actions.invoke(
          element, const PasteTextIntent(SelectionChangedCause.keyboard));
      await tester.pump();

      expect(find.text('Paste is disabled'), findsOneWidget);
    });

    testWidgets('shows custom paste warning text', (tester) async {
      const customWarning = 'Paste not allowed here';

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              disablePaste: true,
              pasteWarningText: customWarning,
            ),
          ),
        ),
      );

      final element = tester.element(find.byType(TextField));
      Actions.invoke(
          element, const PasteTextIntent(SelectionChangedCause.keyboard));
      await tester.pump();

      expect(find.text(customWarning), findsOneWidget);
    });

    testWidgets('hides paste warning after the specified duration',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              disablePaste: true,
              pasteWarningDuration: Duration(seconds: 2),
            ),
          ),
        ),
      );

      final element = tester.element(find.byType(TextField));
      Actions.invoke(
          element, const PasteTextIntent(SelectionChangedCause.keyboard));
      await tester.pump();

      expect(find.text('Paste is disabled'), findsOneWidget);

      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Paste is disabled'), findsNothing);
    });

    testWidgets('does not show paste warning when showPasteWarning is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              disablePaste: true,
              showPasteWarning: false,
            ),
          ),
        ),
      );

      final element = tester.element(find.byType(TextField));
      Actions.invoke(
          element, const PasteTextIntent(SelectionChangedCause.keyboard));
      await tester.pump();

      expect(find.text('Paste is disabled'), findsNothing);
    });

    testWidgets(
        'passes customError warning to builder when hasCustomError becomes true',
        (tester) async {
      PasswordFieldWarning? capturedWarning;
      bool hasError = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  PasswordTextField(
                    labelText: 'Password',
                    hasCustomError: hasError,
                    prefixWidgetBuilder: (context, warning) {
                      capturedWarning = warning;
                      return const Icon(Icons.person);
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => hasError = true),
                    child: const Text('Set Error'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(capturedWarning, PasswordFieldWarning.none);

      await tester.tap(find.text('Set Error'));
      await tester.pump();

      expect(capturedWarning, PasswordFieldWarning.customError);
    });

    testWidgets(
        'clears customError warning in builder when hasCustomError becomes false',
        (tester) async {
      // _activeWarning is only updated via didUpdateWidget, so we must
      // transition false → true → false to exercise the clear path.
      PasswordFieldWarning? capturedWarning;
      bool hasError = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  PasswordTextField(
                    labelText: 'Password',
                    hasCustomError: hasError,
                    prefixWidgetBuilder: (context, warning) {
                      capturedWarning = warning;
                      return const Icon(Icons.person);
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => hasError = !hasError),
                    child: const Text('Toggle Error'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(capturedWarning, PasswordFieldWarning.none);

      // false → true
      await tester.tap(find.text('Toggle Error'));
      await tester.pump();
      expect(capturedWarning, PasswordFieldWarning.customError);

      // true → false
      await tester.tap(find.text('Toggle Error'));
      await tester.pump();
      expect(capturedWarning, PasswordFieldWarning.none);
    });

    testWidgets('renders in tooltip display mode without error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              warningDisplayMode: WarningDisplayMode.tooltip,
            ),
          ),
        ),
      );

      expect(find.byType(PasswordTextField), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('uses custom capsLockWarningText', (tester) async {
      // Verifies the widget accepts a custom caps lock warning text without error.
      // Actual display requires caps lock to be active (platform-dependent).
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              capsLockWarningText: 'CAPS LOCK IS ACTIVE',
            ),
          ),
        ),
      );

      expect(find.byType(PasswordTextField), findsOneWidget);
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

    test('defaults includes contentPadding', () {
      const defaults = PasswordTextFieldTheme.defaults;

      expect(
        defaults.contentPadding,
        const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      );
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

  group('WarningTooltipTheme', () {
    test('merge combines themes with this taking priority', () {
      const theme1 = WarningTooltipTheme(
        backgroundColor: Colors.black,
        elevation: 2.0,
      );
      const theme2 = WarningTooltipTheme(
        backgroundColor: Colors.white, // theme1 takes priority
        elevation: 8.0, // theme1 takes priority
        offset: 12.0,
      );

      final merged = theme1.merge(theme2);

      expect(merged.backgroundColor, Colors.black);
      expect(merged.elevation, 2.0);
      expect(merged.offset, 12.0); // from theme2
    });

    test('merge returns this when other is null', () {
      const theme = WarningTooltipTheme(backgroundColor: Colors.black);
      final merged = theme.merge(null);

      expect(merged.backgroundColor, Colors.black);
      expect(merged.elevation, isNull);
    });

    test('copyWith creates copy with overrides', () {
      const original = WarningTooltipTheme(
        backgroundColor: Colors.black,
        elevation: 4.0,
        offset: 8.0,
      );

      final copied = original.copyWith(elevation: 12.0);

      expect(copied.backgroundColor, Colors.black); // unchanged
      expect(copied.elevation, 12.0); // overridden
      expect(copied.offset, 8.0); // unchanged
    });
  });
}
