import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_password_input/flutter_password_input.dart';
import 'package:flutter_password_input/src/warning_message_layout.dart';
import 'package:flutter_password_input/src/warning_tooltip_layout.dart';
import 'package:flutter_ime/flutter_ime_platform_interface.dart';
// ignore: implementation_imports
import 'package:flutter_ime/src/platform_support.dart';
import 'package:just_tooltip/just_tooltip.dart';

/// A test double for the flutter_ime platform channel. Replacing
/// [FlutterImePlatform.instance] with this lets us drive Caps Lock / input
/// source streams and observe IME-enforcement calls without touching real
/// platform code — the genuine external boundary of the keyboard integration.
class _FakeImePlatform extends FlutterImePlatform {
  final StreamController<bool> capsController = StreamController<bool>.broadcast();
  final StreamController<bool> inputSourceController =
      StreamController<bool>.broadcast();
  bool capsLockValue = false;

  /// Ordered log of IME-enforcement calls, e.g. 'disableIME', 'enableIME',
  /// 'setEnglishKeyboard'.
  final List<String> calls = [];

  @override
  Future<bool> isCapsLockOn() async => capsLockValue;

  @override
  Stream<bool> get onCapsLockChanged => capsController.stream;

  @override
  Future<void> disableIME() async => calls.add('disableIME');

  @override
  Future<void> enableIME() async => calls.add('enableIME');

  @override
  Future<void> setEnglishKeyboard() async => calls.add('setEnglishKeyboard');

  @override
  Stream<bool> get onInputSourceChanged => inputSourceController.stream;
}

/// Forces flutter_ime's supported-platform policy in tests, independent of the
/// host OS, so IME code paths are reachable on any CI machine.
class _ForceSupport extends PlatformSupport {
  const _ForceSupport({this.windows = true});

  final bool windows;

  @override
  bool get isSupported => true;

  @override
  bool get isWindowsOnly => windows;
}

/// Tracks the create/dispose balance of [JustTooltipController] instances by
/// listening to Flutter's debug-mode object-allocation events. Because
/// [JustTooltipController] is a [ChangeNotifier], every construction dispatches
/// an [ObjectCreated] event and every [ChangeNotifier.dispose] dispatches an
/// [ObjectDisposed] event, letting us assert disposal through a public seam
/// rather than the widget's private fields.
class _TooltipControllerLifecycle {
  int created = 0;
  int disposed = 0;

  int get alive => created - disposed;

  void _onEvent(ObjectEvent event) {
    if (event.object is! JustTooltipController) return;
    if (event is ObjectCreated) created++;
    if (event is ObjectDisposed) disposed++;
  }

  void start() => FlutterMemoryAllocations.instance.addListener(_onEvent);
  void stop() => FlutterMemoryAllocations.instance.removeListener(_onEvent);
}

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
        find
            .descendant(
              of: find.byType(PasswordTextField),
              matching: find.byType(SizedBox),
            )
            .first,
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
      PasswordFieldStatus? capturedWarning;

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

      expect(capturedWarning, PasswordFieldStatus.none);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('shows suffixWidgetBuilder alongside visibility toggle',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              suffixWidgetBuilder: (context, warning) => const Icon(Icons.info),
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
      PasswordFieldStatus? capturedWarning;
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

      expect(capturedWarning, PasswordFieldStatus.none);

      await tester.tap(find.text('Set Error'));
      await tester.pump();

      expect(capturedWarning, PasswordFieldStatus.customError);
    });

    testWidgets(
        'clears customError warning in builder when hasCustomError becomes false',
        (tester) async {
      // Transition false → true → false to exercise both the set and the
      // clear path of the customError status.
      PasswordFieldStatus? capturedWarning;
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

      expect(capturedWarning, PasswordFieldStatus.none);

      // false → true
      await tester.tap(find.text('Toggle Error'));
      await tester.pump();
      expect(capturedWarning, PasswordFieldStatus.customError);

      // true → false
      await tester.tap(find.text('Toggle Error'));
      await tester.pump();
      expect(capturedWarning, PasswordFieldStatus.none);
    });

    testWidgets('renders in tooltip display mode without error',
        (tester) async {
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

  group('WarningMessageLayout', () {
    testWidgets('places a bottom-aligned warning below the field',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WarningMessageLayout(
              width: 250,
              margin: null,
              pasteWarning: WarningMessage(
                text: 'warn',
                style: TextStyle(fontSize: 12),
                alignment: WarningAlignment.bottomLeft,
              ),
              child: SizedBox(key: Key('field'), width: 200, height: 40),
            ),
          ),
        ),
      );

      final fieldY = tester.getTopLeft(find.byKey(const Key('field'))).dy;
      final warnY = tester.getTopLeft(find.text('warn')).dy;
      expect(warnY, greaterThan(fieldY),
          reason: 'a bottom-aligned warning renders below the field');
    });

    testWidgets('places a top-aligned warning above the field', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WarningMessageLayout(
              width: 250,
              margin: null,
              pasteWarning: WarningMessage(
                text: 'warn',
                style: TextStyle(fontSize: 12),
                alignment: WarningAlignment.topLeft,
              ),
              child: SizedBox(key: Key('field'), width: 200, height: 40),
            ),
          ),
        ),
      );

      final fieldY = tester.getTopLeft(find.byKey(const Key('field'))).dy;
      final warnY = tester.getTopLeft(find.text('warn')).dy;
      expect(warnY, lessThan(fieldY),
          reason: 'a top-aligned warning renders above the field');
    });

    testWidgets('center alignment horizontally centers the warning',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: WarningMessageLayout(
                width: 250,
                margin: null,
                pasteWarning: WarningMessage(
                  text: 'warn',
                  style: TextStyle(fontSize: 12),
                  alignment: WarningAlignment.bottomCenter,
                ),
                child: SizedBox(key: Key('field'), width: 250, height: 40),
              ),
            ),
          ),
        ),
      );

      final fieldCenter = tester.getCenter(find.byKey(const Key('field'))).dx;
      final warnCenter = tester.getCenter(find.text('warn')).dx;
      expect(warnCenter, moreOrLessEquals(fieldCenter, epsilon: 1.0),
          reason: 'center alignment horizontally centers the warning');
    });

    testWidgets('maps each alignment to its horizontal placement',
        (tester) async {
      // Expected placement per the alignment spec: start/left values hug the
      // left edge, end/right values hug the right edge.
      const cases = <WarningAlignment, String>{
        WarningAlignment.topRight: 'right',
        WarningAlignment.bottomRight: 'right',
        WarningAlignment.topStartTargetCenter: 'left',
        WarningAlignment.bottomStartTargetCenter: 'left',
        WarningAlignment.topEndTargetCenter: 'right',
        WarningAlignment.bottomEndTargetCenter: 'right',
      };

      for (final entry in cases.entries) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: WarningMessageLayout(
                  width: 250,
                  margin: null,
                  pasteWarning: WarningMessage(
                    text: 'warn',
                    style: const TextStyle(fontSize: 12),
                    alignment: entry.key,
                  ),
                  child: const SizedBox(key: Key('field'), width: 250, height: 40),
                ),
              ),
            ),
          ),
        );

        final field = find.byKey(const Key('field'));
        final warn = find.text('warn');
        if (entry.value == 'left') {
          expect(tester.getTopLeft(warn).dx,
              moreOrLessEquals(tester.getTopLeft(field).dx, epsilon: 1.0),
              reason: '${entry.key} should align to the left edge');
        } else {
          expect(tester.getTopRight(warn).dx,
              moreOrLessEquals(tester.getTopRight(field).dx, epsilon: 1.0),
              reason: '${entry.key} should align to the right edge');
        }
      }
    });

    testWidgets('renders a bottom-aligned caps-lock warning below the field',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WarningMessageLayout(
              width: 250,
              margin: null,
              capsLockWarning: WarningMessage(
                text: 'caps',
                style: TextStyle(fontSize: 12),
                alignment: WarningAlignment.bottomLeft,
              ),
              child: SizedBox(key: Key('field'), width: 200, height: 40),
            ),
          ),
        ),
      );

      expect(find.text('caps'), findsOneWidget);
      final fieldY = tester.getTopLeft(find.byKey(const Key('field'))).dy;
      final capsY = tester.getTopLeft(find.text('caps')).dy;
      expect(capsY, greaterThan(fieldY),
          reason: 'a bottom-aligned caps-lock warning renders below the field');
    });

    testWidgets('renders a top-aligned caps-lock warning above the field',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: WarningMessageLayout(
              width: 250,
              margin: null,
              capsLockWarning: WarningMessage(
                text: 'caps',
                style: TextStyle(fontSize: 12),
                alignment: WarningAlignment.topLeft,
              ),
              child: SizedBox(key: Key('field'), width: 200, height: 40),
            ),
          ),
        ),
      );

      final fieldY = tester.getTopLeft(find.byKey(const Key('field'))).dy;
      final capsY = tester.getTopLeft(find.text('caps')).dy;
      expect(capsY, lessThan(fieldY),
          reason: 'a top-aligned caps-lock warning renders above the field');
    });
  });

  group('WarningTooltipLayout', () {
    testWidgets('maps warning alignment to tooltip direction and alignment',
        (tester) async {
      final tt = const WarningTooltipTheme().merge(WarningTooltipTheme.defaults);

      // Expected (direction, tooltip-alignment) per the alignment spec.
      const cases = <WarningAlignment,
          ({TooltipDirection dir, TooltipAlignment align})>{
        WarningAlignment.topLeft:
            (dir: TooltipDirection.top, align: TooltipAlignment.start),
        WarningAlignment.bottomCenter:
            (dir: TooltipDirection.bottom, align: TooltipAlignment.center),
        WarningAlignment.topRight:
            (dir: TooltipDirection.top, align: TooltipAlignment.end),
        WarningAlignment.bottomStartTargetCenter: (
          dir: TooltipDirection.bottom,
          align: TooltipAlignment.startTargetCenter
        ),
        WarningAlignment.topEndTargetCenter: (
          dir: TooltipDirection.top,
          align: TooltipAlignment.endTargetCenter
        ),
        WarningAlignment.bottomEndTargetCenter: (
          dir: TooltipDirection.bottom,
          align: TooltipAlignment.endTargetCenter
        ),
      };

      for (final entry in cases.entries) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: WarningTooltipLayout(
                activeStatus: PasswordFieldStatus.none,
                margin: null,
                width: 250,
                tooltipTheme: tt,
                capsLockMessage: 'caps',
                capsLockTextStyle: const TextStyle(fontSize: 12),
                capsLockAlignment: entry.key,
                pasteMessage: 'paste',
                pasteTextStyle: const TextStyle(fontSize: 12),
                pasteAlignment: WarningAlignment.bottomLeft,
                pasteGeneration: 0,
                child: const SizedBox(width: 250, height: 40),
              ),
            ),
          ),
        );

        final caps = tester
            .widgetList<JustTooltip>(find.byType(JustTooltip))
            .firstWhere((t) => t.message == 'caps');
        expect(caps.direction, entry.value.dir,
            reason: '${entry.key} → direction');
        expect(caps.alignment, entry.value.align,
            reason: '${entry.key} → alignment');
      }
    });
  });

  group('PasswordTextField checked state', () {
    testWidgets('reports checked status and a green border when isChecked true',
        (tester) async {
      PasswordFieldStatus? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              isChecked: true,
              prefixWidgetBuilder: (context, status) {
                captured = status;
                return const Icon(Icons.person);
              },
            ),
          ),
        ),
      );

      expect(captured, PasswordFieldStatus.checked);

      final textField = tester.widget<TextField>(find.byType(TextField));
      final border = textField.decoration!.enabledBorder as OutlineInputBorder;
      expect(border.borderSide.color, Colors.green,
          reason: 'checked defaults to a green border');
    });

    testWidgets('reports unchecked status when isChecked false', (tester) async {
      PasswordFieldStatus? captured;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              isChecked: false,
              prefixWidgetBuilder: (context, status) {
                captured = status;
                return const Icon(Icons.person);
              },
            ),
          ),
        ),
      );

      expect(captured, PasswordFieldStatus.unchecked);
    });
  });

  group('PasswordTextField status priority', () {
    testWidgets('a blocked paste does not override an active customError',
        (tester) async {
      PasswordFieldStatus? captured;
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
                    disablePaste: true,
                    prefixWidgetBuilder: (context, status) {
                      captured = status;
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

      // Activate the custom error state.
      await tester.tap(find.text('Set Error'));
      await tester.pump();
      expect(captured, PasswordFieldStatus.customError);

      // Block a paste while customError is active.
      final element = tester.element(find.byType(TextField));
      Actions.invoke(
          element, const PasteTextIntent(SelectionChangedCause.keyboard));
      await tester.pump();

      expect(captured, PasswordFieldStatus.customError,
          reason: 'customError outranks pasteBlocked in the priority order');
    });

    testWidgets('a disabled field reports disabled even when hasCustomError sets',
        (tester) async {
      PasswordFieldStatus? captured;
      bool hasError = false;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  PasswordTextField(
                    labelText: 'Password',
                    enabled: false,
                    hasCustomError: hasError,
                    prefixWidgetBuilder: (context, status) {
                      captured = status;
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

      expect(captured, PasswordFieldStatus.disabled);

      // Toggle hasCustomError on; disabled must still win.
      await tester.tap(find.text('Set Error'));
      await tester.pump();

      expect(captured, PasswordFieldStatus.disabled,
          reason: 'disabled outranks customError in the priority order');
    });
  });

  group('PasswordTextField keyboard integration', () {
    late _FakeImePlatform fake;
    late FlutterImePlatform original;

    setUp(() {
      original = FlutterImePlatform.instance;
      fake = _FakeImePlatform();
      FlutterImePlatform.instance = fake;
      debugSetPlatformSupport(const _ForceSupport());
    });

    tearDown(() {
      FlutterImePlatform.instance = original;
      debugSetPlatformSupport(null);
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('reports Caps Lock changes from the IME stream while focused',
        (tester) async {
      bool? capsState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              forceEnglishInput: false,
              onCapsLockStateChanged: (value) => capsState = value,
            ),
          ),
        ),
      );

      // Focus the field so Caps Lock updates are honored.
      await tester.tap(find.byType(TextField));
      await tester.pump();

      // The IME reports Caps Lock turned on.
      fake.capsController.add(true);
      await tester.pump();

      expect(capsState, isTrue);
    });

    testWidgets('toggles the Windows IME on focus and blur', (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const PasswordTextField(
                  labelText: 'Password',
                  forceEnglishInput: true,
                ),
                const TextField(key: Key('other')),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField).first);
      await tester.pump();
      expect(fake.calls, contains('disableIME'),
          reason: 'gaining focus on Windows must disable the IME');

      await tester.tap(find.byKey(const Key('other')));
      await tester.pump();
      expect(fake.calls, contains('enableIME'),
          reason: 'losing focus on Windows must re-enable the IME');

      // Reset before the test body ends; flutter_test asserts foundation debug
      // vars are unset at that point (before tearDown runs).
      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets(
        're-forces the English keyboard on macOS when the input source changes',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      debugSetPlatformSupport(const _ForceSupport(windows: false));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              forceEnglishInput: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(fake.calls, contains('setEnglishKeyboard'),
          reason: 'gaining focus on macOS must force the English keyboard');

      // The user switches to a non-English input source while focused.
      fake.calls.clear();
      fake.inputSourceController.add(false);
      await tester.pump();
      expect(fake.calls, contains('setEnglishKeyboard'),
          reason: 'a non-English switch while focused must be reverted');

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('cancels the Caps Lock subscription on dispose', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              forceEnglishInput: false,
            ),
          ),
        ),
      );
      await tester.pump();
      expect(fake.capsController.hasListener, isTrue,
          reason: 'the field subscribes to Caps Lock changes while mounted');

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      expect(fake.capsController.hasListener, isFalse,
          reason: 'the Caps Lock subscription must be cancelled on dispose');
    });

    testWidgets('picks up Caps Lock already on when focus is gained',
        (tester) async {
      fake.capsLockValue = true;
      bool? capsState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              forceEnglishInput: false,
              onCapsLockStateChanged: (value) => capsState = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pump(); // focus change
      await tester.pump(); // async isCapsLockOn() resolves

      expect(capsState, isTrue,
          reason: 'the on-focus check reports Caps Lock that was already on');
    });

    testWidgets('clears the Caps Lock warning and notifies false on blur',
        (tester) async {
      fake.capsLockValue = true;
      final states = <bool>[];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                PasswordTextField(
                  labelText: 'Password',
                  forceEnglishInput: false,
                  onCapsLockStateChanged: (value) => states.add(value),
                ),
                const TextField(key: Key('other')),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField).first);
      await tester.pump();
      await tester.pump();
      expect(states, contains(true), reason: 'Caps Lock is picked up on focus');

      await tester.tap(find.byKey(const Key('other')));
      await tester.pump();
      expect(states.last, isFalse,
          reason: 'losing focus clears Caps Lock and notifies false');
    });

    testWidgets('cancels the macOS input-source subscription on blur',
        (tester) async {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      debugSetPlatformSupport(const _ForceSupport(windows: false));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const PasswordTextField(
                  labelText: 'Password',
                  forceEnglishInput: true,
                ),
                const TextField(key: Key('other')),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField).first);
      await tester.pump();
      expect(fake.inputSourceController.hasListener, isTrue,
          reason: 'focus subscribes to input-source changes on macOS');

      await tester.tap(find.byKey(const Key('other')));
      await tester.pump();
      expect(fake.inputSourceController.hasListener, isFalse,
          reason: 'blur cancels the macOS input-source subscription');

      debugDefaultTargetPlatformOverride = null;
    });

    testWidgets('autofocus requests focus after the first frame',
        (tester) async {
      bool focused = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              forceEnglishInput: false,
              autofocus: true,
              onFocus: () => focused = true,
            ),
          ),
        ),
      );

      await tester.pump(); // post-frame callback requests focus
      await tester.pump();

      expect(focused, isTrue,
          reason: 'autofocus focuses the field after the first frame');
    });

    testWidgets('rewires focus when the external focusNode is replaced',
        (tester) async {
      final nodeA = FocusNode();
      final nodeB = FocusNode();
      addTearDown(nodeA.dispose);
      addTearDown(nodeB.dispose);
      FocusNode current = nodeA;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  PasswordTextField(
                    labelText: 'Password',
                    forceEnglishInput: false,
                    focusNode: current,
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => current = nodeB),
                    child: const Text('Swap'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Replace the external focusNode at runtime.
      await tester.tap(find.text('Swap'));
      await tester.pump();

      // The field now follows the new node.
      nodeB.requestFocus();
      await tester.pump();
      await tester.pump();
      expect(nodeB.hasFocus, isTrue,
          reason: 'the field tracks the replacement focusNode');
    });

    testWidgets('hides the paste warning when the user types', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              forceEnglishInput: false,
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

      await tester.enterText(find.byType(TextField), 'x');
      await tester.pump();
      expect(find.text('Paste is disabled'), findsNothing,
          reason: 'typing hides the paste warning');
    });

    testWidgets('re-resolves status when isChecked and enabled change at runtime',
        (tester) async {
      PasswordFieldStatus? captured;
      bool enabled = true;
      bool? checked;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  PasswordTextField(
                    labelText: 'Password',
                    forceEnglishInput: false,
                    enabled: enabled,
                    isChecked: checked,
                    prefixWidgetBuilder: (context, status) {
                      captured = status;
                      return const Icon(Icons.person);
                    },
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => checked = true),
                    child: const Text('Check'),
                  ),
                  ElevatedButton(
                    onPressed: () => setState(() => enabled = false),
                    child: const Text('Disable'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(captured, PasswordFieldStatus.none);

      // isChecked null -> true resolves to checked.
      await tester.tap(find.text('Check'));
      await tester.pump();
      expect(captured, PasswordFieldStatus.checked);

      // enabled true -> false resolves to disabled (higher priority).
      await tester.tap(find.text('Disable'));
      await tester.pump();
      expect(captured, PasswordFieldStatus.disabled);
    });
  });

  group('PasswordTextField tooltip controller lifecycle', () {
    testWidgets('disposes tooltip controllers when removed from the tree',
        (tester) async {
      final lifecycle = _TooltipControllerLifecycle()..start();
      addTearDown(lifecycle.stop);

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

      expect(lifecycle.created, greaterThan(0),
          reason: 'tooltip mode should create JustTooltipController(s)');

      // Remove the field from the tree, triggering State.dispose().
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      expect(lifecycle.alive, 0,
          reason: 'every tooltip controller must be disposed on unmount');
    });

    testWidgets('disposes tooltip controllers when switching to message mode',
        (tester) async {
      final lifecycle = _TooltipControllerLifecycle()..start();
      addTearDown(lifecycle.stop);

      var mode = WarningDisplayMode.tooltip;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) => MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  PasswordTextField(
                    labelText: 'Password',
                    warningDisplayMode: mode,
                  ),
                  ElevatedButton(
                    onPressed: () =>
                        setState(() => mode = WarningDisplayMode.message),
                    child: const Text('To Message'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final createdInTooltipMode = lifecycle.created;
      expect(createdInTooltipMode, greaterThan(0));

      // Switch to message mode; the widget stays mounted.
      await tester.tap(find.text('To Message'));
      await tester.pump();

      expect(lifecycle.disposed, createdInTooltipMode,
          reason: 'controllers dropped by the mode switch must be disposed, '
              'not just nulled');
    });

    testWidgets('does not leak the paste controller when the warning re-fires',
        (tester) async {
      final lifecycle = _TooltipControllerLifecycle()..start();
      addTearDown(lifecycle.stop);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PasswordTextField(
              labelText: 'Password',
              disablePaste: true,
              warningDisplayMode: WarningDisplayMode.tooltip,
            ),
          ),
        ),
      );

      final element = tester.element(find.byType(TextField));

      // First blocked paste shows the warning.
      Actions.invoke(
          element, const PasteTextIntent(SelectionChangedCause.keyboard));
      await tester.pump();

      // Release the paste key so a second attempt is honored (not swallowed
      // by the held-key guard).
      await simulateKeyDownEvent(LogicalKeyboardKey.keyV);
      await simulateKeyUpEvent(LogicalKeyboardKey.keyV);

      // Second blocked paste while the warning is still showing swaps in a
      // fresh paste tooltip controller.
      Actions.invoke(
          element, const PasteTextIntent(SelectionChangedCause.keyboard));
      await tester.pump();

      expect(lifecycle.created, greaterThan(2),
          reason: 're-triggering in tooltip mode should replace the paste '
              'controller (proves the leak-prone path ran)');

      // Unmount; the replaced controller must have been disposed too.
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );

      expect(lifecycle.alive, 0,
          reason: 'the controller replaced mid-warning must not be orphaned');
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
