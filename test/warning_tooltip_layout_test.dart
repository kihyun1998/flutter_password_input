import 'package:flutter/gestures.dart' show PointerDeviceKind;
import 'package:flutter/material.dart';
import 'package:flutter_password_input/src/password_text_field.dart'
    show PasswordFieldStatus, WarningAlignment;
import 'package:flutter_password_input/src/password_text_field_theme.dart';
import 'package:flutter_password_input/src/warning_tooltip_layout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_tooltip/just_tooltip.dart' as jt;

/// `WarningTooltipLayout` nests two `JustTooltip`s — caps-lock wraps paste
/// wraps the field — and drives both from controllers, with hover and tap
/// disabled.
///
/// `just_tooltip` 0.4.0 lets a nested tooltip suppress its ancestors, but only
/// a tooltip with `enableHover` claims its ancestors, and only a claimed
/// ancestor is suppressed. Both tooltips here disable hover, so the inner one
/// never claims and the suppression path is unreachable — a programmatic
/// `controller.show()` on the outer one always wins.
///
/// The tests below therefore guard the two facts that keep it unreachable —
/// the nesting order and `enableHover: false` — alongside which tooltip each
/// status shows. Asserting only the latter would still pass if the inner
/// tooltip started claiming.
void main() {
  const capsLock = 'CAPS LOCK ON';
  const paste = 'PASTE BLOCKED';

  Widget layoutWith(PasswordFieldStatus status, {int pasteGeneration = 0}) {
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
            pasteGeneration: pasteGeneration,
            child: const SizedBox(key: Key('field'), width: 200, height: 40),
          ),
        ),
      ),
    );
  }

  Finder tooltipWith(String message) => find.byWidgetPredicate(
        (w) => w is jt.JustTooltip && w.message == message,
      );

  group('WarningTooltipLayout', () {
    testWidgets('the caps-lock status shows the outer tooltip', (tester) async {
      await tester.pumpWidget(layoutWith(PasswordFieldStatus.capsLock));
      await tester.pumpAndSettle();

      expect(find.text(capsLock), findsOneWidget,
          reason: 'the outer tooltip of the nested pair is controller-driven '
              'and must not be suppressed by the inner one');
      expect(find.text(paste), findsNothing);
    });

    testWidgets('the caps-lock tooltip encloses the paste tooltip',
        (tester) async {
      await tester.pumpWidget(layoutWith(PasswordFieldStatus.none));

      expect(
        find.ancestor(
          of: tooltipWith(paste),
          matching: tooltipWith(capsLock),
        ),
        findsOneWidget,
        reason: 'suppression runs inner-to-outer, so which tooltip is the '
            'ancestor decides which one could be suppressed',
      );
    });

    testWidgets('neither tooltip reacts to hover', (tester) async {
      await tester.pumpWidget(layoutWith(PasswordFieldStatus.none));

      for (final message in [capsLock, paste]) {
        final tooltip = tester.widget<jt.JustTooltip>(tooltipWith(message));
        expect(tooltip.enableHover, isFalse,
            reason: 'a tooltip with hover claims its ancestors, which is the '
                'only way the caps-lock tooltip could ever be suppressed');
        expect(tooltip.enableTap, isFalse);
      }

      final pointer = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await pointer.addPointer(location: Offset.zero);
      addTearDown(pointer.removePointer);
      await pointer.moveTo(tester.getCenter(find.byKey(const Key('field'))));
      await tester.pumpAndSettle();

      expect(find.text(capsLock), findsNothing);
      expect(find.text(paste), findsNothing);
    });

    testWidgets('bumping pasteGeneration replays the paste tooltip',
        (tester) async {
      await tester.pumpWidget(layoutWith(PasswordFieldStatus.pasteBlocked));
      await tester.pumpAndSettle();
      expect(find.text(paste), findsOneWidget);

      await tester.pumpWidget(
        layoutWith(PasswordFieldStatus.pasteBlocked, pasteGeneration: 1),
      );
      await tester.pumpAndSettle();

      expect(find.text(paste), findsOneWidget,
          reason: 'a repeated paste swaps in a fresh controller to replay the '
              'animation; the tooltip must end up shown again, not lost');
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

  /// `just_tooltip` 0.4.2 anchors a tooltip to the *visible* part of its child
  /// and re-aims it whenever the child moves. Both warnings are shown through a
  /// controller with hover disabled, so they inherit that tracking wholesale.
  group('WarningTooltipLayout tracks a scrolling field', () {
    Widget scrollableLayout(ScrollController scroll) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 300,
            child: SingleChildScrollView(
              controller: scroll,
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  WarningTooltipLayout(
                    activeStatus: PasswordFieldStatus.capsLock,
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
                    child: const SizedBox(
                        key: Key('field'), width: 200, height: 40),
                  ),
                  const SizedBox(width: 600),
                ],
              ),
            ),
          ),
        ),
      );
    }

    double warningCentre(WidgetTester tester) =>
        tester.getRect(find.text(capsLock)).center.dx;

    testWidgets('the warning re-aims when the field scrolls', (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);

      await tester.pumpWidget(scrollableLayout(scroll));
      await tester.pumpAndSettle();

      final before = warningCentre(tester);
      scroll.jumpTo(60);
      await tester.pumpAndSettle();

      expect(find.text(capsLock), findsOneWidget,
          reason: 'part of the field still shows');
      expect(warningCentre(tester), isNot(before),
          reason: 'it must not stay where the field used to be');
    });

    testWidgets('the warning hides once the field is scrolled out of sight',
        (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);

      await tester.pumpWidget(scrollableLayout(scroll));
      await tester.pumpAndSettle();
      expect(find.text(capsLock), findsOneWidget);

      // The field spans 40..240; scrolling by 330 puts it wholly left of the
      // 400px viewport.
      scroll.jumpTo(330);
      await tester.pumpAndSettle();

      expect(find.text(capsLock), findsNothing,
          reason: 'no visible target, no warning');
    });
  });
}
