import 'package:flutter/material.dart';
import 'package:flutter_password_input/src/password_text_field.dart'
    show PasswordFieldStatus, WarningAlignment;
import 'package:flutter_password_input/src/password_text_field_theme.dart';
import 'package:flutter_password_input/src/warning_tooltip_layout.dart';
import 'package:flutter_test/flutter_test.dart';

/// `WarningTooltipLayout` nests two `JustTooltip`s — caps-lock wraps paste
/// wraps the field — and drives both from controllers, with hover and tap
/// disabled.
///
/// `just_tooltip` 0.4.0 makes a nested tooltip suppress its ancestors, but
/// gates that on hover: a programmatic `controller.show()` is never suppressed.
/// The outer (caps-lock) tooltip is the one that would disappear if that ever
/// stopped being true, and nothing else here would notice.
void main() {
  const capsLock = 'CAPS LOCK ON';
  const paste = 'PASTE BLOCKED';

  Widget layoutWith(PasswordFieldStatus status) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: WarningTooltipLayout(
            activeStatus: status,
            margin: null,
            width: 250,
            tooltipTheme: WarningTooltipTheme.defaults,
            capsLockMessage: capsLock,
            capsLockTextStyle: const TextStyle(fontSize: 12),
            capsLockAlignment: WarningAlignment.topLeft,
            pasteMessage: paste,
            pasteTextStyle: const TextStyle(fontSize: 12),
            pasteAlignment: WarningAlignment.bottomLeft,
            pasteGeneration: 0,
            child: const SizedBox(key: Key('field'), width: 200, height: 40),
          ),
        ),
      ),
    );
  }

  group('WarningTooltipLayout', () {
    testWidgets('the caps-lock status shows the outer tooltip', (tester) async {
      await tester.pumpWidget(layoutWith(PasswordFieldStatus.capsLock));
      await tester.pumpAndSettle();

      expect(find.text(capsLock), findsOneWidget,
          reason: 'the outer tooltip of the nested pair is controller-driven '
              'and must not be suppressed by the inner one');
      expect(find.text(paste), findsNothing);
    });

    testWidgets('the paste-blocked status shows the inner tooltip',
        (tester) async {
      await tester.pumpWidget(layoutWith(PasswordFieldStatus.pasteBlocked));
      await tester.pumpAndSettle();

      expect(find.text(paste), findsOneWidget);
      expect(find.text(capsLock), findsNothing);
    });

    testWidgets('no active status shows neither tooltip', (tester) async {
      await tester.pumpWidget(layoutWith(PasswordFieldStatus.none));
      await tester.pumpAndSettle();

      expect(find.text(capsLock), findsNothing);
      expect(find.text(paste), findsNothing);
    });

    testWidgets('switching status swaps which tooltip is shown',
        (tester) async {
      await tester.pumpWidget(layoutWith(PasswordFieldStatus.pasteBlocked));
      await tester.pumpAndSettle();
      expect(find.text(paste), findsOneWidget);

      await tester.pumpWidget(layoutWith(PasswordFieldStatus.capsLock));
      await tester.pumpAndSettle();
      expect(find.text(capsLock), findsOneWidget);
      expect(find.text(paste), findsNothing,
          reason: 'exactly one warning is ever active');
    });
  });
}
