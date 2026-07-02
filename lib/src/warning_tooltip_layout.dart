import 'package:flutter/material.dart';
import 'package:just_tooltip/just_tooltip.dart' as jt;

import 'password_text_field.dart' show PasswordFieldStatus, WarningAlignment;
import 'password_text_field_theme.dart';
import 'warning_message_layout.dart' show WarningMessageLayout;

/// Renders the `WarningDisplayMode.tooltip` presentation: the text field
/// wrapped in caps-lock and paste [jt.JustTooltip]s.
///
/// This widget owns the two [jt.JustTooltipController]s end-to-end — it
/// creates them, drives their visibility from [activeStatus], recreates the
/// paste controller when [pasteGeneration] changes (so a repeated paste
/// re-triggers the tooltip animation). Keeping that lifecycle here is why the
/// field widget no longer references `just_tooltip` at all.
///
/// (As of just_tooltip 0.3.0 the controllers are not `ChangeNotifier`s and
/// need no disposal.)
class WarningTooltipLayout extends StatefulWidget {
  const WarningTooltipLayout({
    super.key,
    required this.child,
    required this.activeStatus,
    required this.margin,
    required this.width,
    required this.tooltipTheme,
    required this.capsLockMessage,
    required this.capsLockTextStyle,
    required this.capsLockAlignment,
    required this.pasteMessage,
    required this.pasteTextStyle,
    required this.pasteAlignment,
    required this.pasteGeneration,
  });

  /// The text field the tooltips are anchored to.
  final Widget child;

  /// The field's resolved status; drives which tooltip is shown.
  final PasswordFieldStatus activeStatus;

  final EdgeInsetsGeometry? margin;
  final double? width;

  /// The tooltip theme, already merged with [WarningTooltipTheme.defaults].
  final WarningTooltipTheme tooltipTheme;

  final String capsLockMessage;

  /// Fallback text style used when [tooltipTheme] has no `textStyle`.
  final TextStyle capsLockTextStyle;
  final WarningAlignment capsLockAlignment;

  final String pasteMessage;

  /// Fallback text style used when [tooltipTheme] has no `textStyle`.
  final TextStyle pasteTextStyle;
  final WarningAlignment pasteAlignment;

  /// Bumped by the owner each time a paste warning re-fires while already
  /// showing; a change recreates the paste controller to replay the animation.
  final int pasteGeneration;

  @override
  State<WarningTooltipLayout> createState() => _WarningTooltipLayoutState();
}

class _WarningTooltipLayoutState extends State<WarningTooltipLayout> {
  late jt.JustTooltipController _capsLockController;
  late jt.JustTooltipController _pasteController;
  int _pasteKey = 0;

  @override
  void initState() {
    super.initState();
    _capsLockController = jt.JustTooltipController();
    _pasteController = jt.JustTooltipController();
  }

  @override
  void didUpdateWidget(covariant WarningTooltipLayout oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pasteGeneration != widget.pasteGeneration) {
      _pasteKey++;
      // JustTooltipController (0.3.0+) holds no resources; just replace it.
      _pasteController = jt.JustTooltipController();
    }
  }

  void _updateVisibility(jt.JustTooltipController controller, bool shouldShow) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (shouldShow) {
        controller.show();
      } else {
        controller.hide();
      }
    });
  }

  ({jt.TooltipDirection direction, jt.TooltipAlignment alignment})
      _mapAlignment(WarningAlignment warningAlignment) {
    final direction = WarningMessageLayout.isTopAlignment(warningAlignment)
        ? jt.TooltipDirection.top
        : jt.TooltipDirection.bottom;
    final alignment = switch (warningAlignment) {
      WarningAlignment.topLeft ||
      WarningAlignment.bottomLeft =>
        jt.TooltipAlignment.start,
      WarningAlignment.topCenter ||
      WarningAlignment.bottomCenter =>
        jt.TooltipAlignment.center,
      WarningAlignment.topRight ||
      WarningAlignment.bottomRight =>
        jt.TooltipAlignment.end,
      WarningAlignment.topStartTargetCenter ||
      WarningAlignment.bottomStartTargetCenter =>
        jt.TooltipAlignment.startTargetCenter,
      WarningAlignment.topEndTargetCenter ||
      WarningAlignment.bottomEndTargetCenter =>
        jt.TooltipAlignment.endTargetCenter,
    };
    return (direction: direction, alignment: alignment);
  }

  jt.JustTooltipTheme _buildTooltipTheme(TextStyle textStyle) {
    final tt = widget.tooltipTheme;
    return jt.JustTooltipTheme(
      backgroundColor: tt.backgroundColor!,
      borderRadius: tt.borderRadius!,
      padding: tt.padding!,
      elevation: tt.elevation!,
      boxShadow: tt.boxShadow,
      borderColor: tt.borderColor,
      borderWidth: tt.borderWidth!,
      textStyle: textStyle,
      showArrow: tt.showArrow!,
      arrowBaseWidth: tt.arrowBaseWidth!,
      arrowLength: tt.arrowLength!,
      arrowPositionRatio: tt.arrowPositionRatio!,
    );
  }

  jt.JustTooltip _buildTooltip({
    Key? key,
    required jt.JustTooltipController controller,
    required jt.TooltipDirection direction,
    required jt.TooltipAlignment alignment,
    required TextStyle textStyle,
    required String message,
    required Widget child,
  }) {
    final tt = widget.tooltipTheme;
    return jt.JustTooltip(
      key: key,
      controller: controller,
      enableTap: false,
      enableHover: false,
      interactive: tt.interactive!,
      direction: direction,
      alignment: alignment,
      offset: tt.offset!,
      crossAxisOffset: tt.crossAxisOffset!,
      screenMargin: tt.screenMargin!,
      waitDuration: tt.waitDuration,
      showDuration: tt.showDuration,
      animationDuration: tt.animationDuration!,
      animation: tt.animation!,
      animationCurve: tt.animationCurve,
      fadeBegin: tt.fadeBegin!,
      scaleBegin: tt.scaleBegin!,
      slideOffset: tt.slideOffset!,
      rotationBegin: tt.rotationBegin!,
      theme: _buildTooltipTheme(textStyle),
      message: message,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    _updateVisibility(_capsLockController,
        widget.activeStatus == PasswordFieldStatus.capsLock);
    _updateVisibility(_pasteController,
        widget.activeStatus == PasswordFieldStatus.pasteBlocked);

    final tt = widget.tooltipTheme;
    final capsLockMapping = _mapAlignment(widget.capsLockAlignment);
    final pasteMapping = _mapAlignment(widget.pasteAlignment);

    Widget child = widget.child;

    child = _buildTooltip(
      key: ValueKey(_pasteKey),
      controller: _pasteController,
      direction: tt.direction ?? pasteMapping.direction,
      alignment: tt.alignment ?? pasteMapping.alignment,
      textStyle: tt.textStyle ?? widget.pasteTextStyle,
      message: widget.pasteMessage,
      child: child,
    );

    child = _buildTooltip(
      controller: _capsLockController,
      direction: tt.direction ?? capsLockMapping.direction,
      alignment: tt.alignment ?? capsLockMapping.alignment,
      textStyle: tt.textStyle ?? widget.capsLockTextStyle,
      message: widget.capsLockMessage,
      child: child,
    );

    return Container(
      margin: widget.margin,
      width: widget.width,
      child: child,
    );
  }
}
