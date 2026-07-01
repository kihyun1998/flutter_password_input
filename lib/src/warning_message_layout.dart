import 'package:flutter/material.dart';

import 'password_text_field.dart' show WarningAlignment;

/// The content and placement of a single inline warning message.
class WarningMessage {
  const WarningMessage({
    required this.text,
    required this.style,
    required this.alignment,
  });

  final String text;
  final TextStyle style;
  final WarningAlignment alignment;
}

/// Lays out a text field with optional inline caps-lock / paste warnings
/// positioned above or below it, according to each warning's
/// [WarningAlignment].
///
/// This is the `WarningDisplayMode.message` presentation, extracted so the
/// field widget only decides *which* warnings are active and delegates *how*
/// they are rendered here.
class WarningMessageLayout extends StatelessWidget {
  const WarningMessageLayout({
    super.key,
    required this.child,
    required this.margin,
    required this.width,
    this.capsLockWarning,
    this.pasteWarning,
  });

  /// The text field the warnings are arranged around.
  final Widget child;

  final EdgeInsetsGeometry? margin;
  final double? width;

  /// The caps-lock warning to show, or null to hide it.
  final WarningMessage? capsLockWarning;

  /// The paste warning to show, or null to hide it.
  final WarningMessage? pasteWarning;

  /// Whether [alignment] positions a warning above the field (vs below).
  static bool isTopAlignment(WarningAlignment alignment) {
    return alignment == WarningAlignment.topLeft ||
        alignment == WarningAlignment.topCenter ||
        alignment == WarningAlignment.topRight ||
        alignment == WarningAlignment.topStartTargetCenter ||
        alignment == WarningAlignment.topEndTargetCenter;
  }

  static Alignment _toAlignment(WarningAlignment alignment) {
    switch (alignment) {
      case WarningAlignment.topLeft:
      case WarningAlignment.bottomLeft:
        return Alignment.centerLeft;
      case WarningAlignment.topCenter:
      case WarningAlignment.bottomCenter:
        return Alignment.center;
      case WarningAlignment.topRight:
      case WarningAlignment.bottomRight:
        return Alignment.centerRight;
      case WarningAlignment.topStartTargetCenter:
      case WarningAlignment.bottomStartTargetCenter:
        return Alignment.centerLeft;
      case WarningAlignment.topEndTargetCenter:
      case WarningAlignment.bottomEndTargetCenter:
        return Alignment.centerRight;
    }
  }

  Widget _buildWarning(WarningMessage warning) {
    final isTop = isTopAlignment(warning.alignment);
    return Padding(
      padding: EdgeInsets.only(
        top: isTop ? 0 : 4,
        bottom: isTop ? 4 : 0,
      ),
      child: Align(
        alignment: _toAlignment(warning.alignment),
        child: Text(warning.text, style: warning.style),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final capsLock = capsLockWarning;
    final paste = pasteWarning;
    return Container(
      margin: margin,
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (capsLock != null && isTopAlignment(capsLock.alignment))
            _buildWarning(capsLock),
          if (paste != null && isTopAlignment(paste.alignment))
            _buildWarning(paste),
          child,
          if (capsLock != null && !isTopAlignment(capsLock.alignment))
            _buildWarning(capsLock),
          if (paste != null && !isTopAlignment(paste.alignment))
            _buildWarning(paste),
        ],
      ),
    );
  }
}
