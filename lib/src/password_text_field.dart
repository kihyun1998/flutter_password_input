import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ime/flutter_ime.dart';

import 'password_text_field_theme.dart';

/// A password text field widget that detects Caps Lock state and displays
/// a customizable warning message when Caps Lock is enabled.
///
/// This widget provides:
/// - Obscured text input for password entry
/// - Caps Lock detection with warning message display
/// - Password visibility toggle button
/// - Customizable prefix and suffix widgets
/// - Comprehensive theming support via [PasswordTextFieldTheme]
///
/// Example usage:
/// ```dart
/// PasswordTextField(
///   labelText: 'Password',
///   capsLockWarningText: 'Caps Lock is on!',
///   theme: PasswordTextFieldTheme(
///     width: 300,
///     focusBorderColor: Colors.blue,
///   ),
///   onCapsLockStateChanged: (isCapsLockOn) {
///     print('Caps Lock: $isCapsLockOn');
///   },
/// )
/// ```
class PasswordTextField extends StatefulWidget {
  const PasswordTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.theme,
    this.labelText,
    this.hintText,
    this.maxLength,
    this.enabled,
    this.autofocus = false,
    this.useFloatingLabel = true,
    this.margin,
    this.inputFormatters,
    this.capsLockWarningText,
    this.showCapsLockWarning = true,
    this.showVisibilityToggle = true,
    this.visibilityOnIcon,
    this.visibilityOffIcon,
    this.prefixWidget,
    this.suffixWidget,
    this.onFocus,
    this.onLostFocus,
    this.onChange,
    this.onSubmitted,
    this.onCapsLockStateChanged,
  });

  /// Controls the text being edited.
  ///
  /// If null, this widget will create its own [TextEditingController].
  final TextEditingController? controller;

  /// Defines the keyboard focus for this widget.
  ///
  /// If null, this widget will create its own [FocusNode].
  final FocusNode? focusNode;

  /// The theme containing all style-related properties for this widget.
  ///
  /// If null, default theme values will be applied.
  /// See [PasswordTextFieldTheme] for available customization options.
  final PasswordTextFieldTheme? theme;

  /// The text to display as the label above the text field.
  ///
  /// When [useFloatingLabel] is true, this label floats above the field
  /// when focused or when the field contains text.
  final String? labelText;

  /// The text to display as a hint when the field is empty.
  ///
  /// If null, [labelText] will be used as the hint text.
  final String? hintText;

  /// The maximum number of characters allowed in the text field.
  ///
  /// If null, there is no limit to the number of characters.
  final int? maxLength;

  /// Whether the text field is enabled for user input.
  ///
  /// When false, the field will be displayed in a disabled state
  /// and will not accept user input.
  final bool? enabled;

  /// Whether this text field should be focused automatically when the widget is built.
  ///
  /// Defaults to false.
  final bool autofocus;

  /// Whether to use a floating label that animates above the field.
  ///
  /// When true, the label floats above the field when focused or filled.
  /// When false, the label is hidden and only hint text is shown.
  /// Defaults to true.
  final bool useFloatingLabel;

  /// The margin around the entire widget including the warning message.
  final EdgeInsetsGeometry? margin;

  /// A list of [TextInputFormatter] to apply to the text field.
  ///
  /// Useful for restricting input to specific characters or patterns.
  final List<TextInputFormatter>? inputFormatters;

  /// The warning message to display when Caps Lock is enabled.
  ///
  /// If null, defaults to 'Caps Lock is on'.
  final String? capsLockWarningText;

  /// Whether to show the Caps Lock warning message when Caps Lock is enabled.
  ///
  /// Defaults to true.
  final bool showCapsLockWarning;

  /// Whether to show the password visibility toggle button.
  ///
  /// When true, displays an eye icon that toggles between showing
  /// and hiding the password text.
  /// Defaults to true.
  final bool showVisibilityToggle;

  /// Custom icon widget to display when password is visible.
  ///
  /// If null, uses the default [Icons.visibility] icon.
  final Widget? visibilityOnIcon;

  /// Custom icon widget to display when password is hidden.
  ///
  /// If null, uses the default [Icons.visibility_off] icon.
  final Widget? visibilityOffIcon;

  /// A widget to display before the text input area.
  ///
  /// Commonly used for icons like a lock icon.
  final Widget? prefixWidget;

  /// A widget to display after the text input area but before the visibility toggle.
  ///
  /// When both [suffixWidget] and [showVisibilityToggle] are provided,
  /// they are displayed in a row with the suffix widget first.
  final Widget? suffixWidget;

  /// Called when the text field gains focus.
  final VoidCallback? onFocus;

  /// Called when the text field loses focus.
  final VoidCallback? onLostFocus;

  /// Called when the text in the field changes.
  final ValueChanged<String>? onChange;

  /// Called when the user submits the text (e.g., presses Enter).
  final ValueChanged<String>? onSubmitted;

  /// Called when the Caps Lock state changes while the field is focused.
  ///
  /// The callback receives true when Caps Lock is enabled,
  /// and false when it is disabled or when the field loses focus.
  final ValueChanged<bool>? onCapsLockStateChanged;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  late FocusNode _focusNode;
  bool _isObscured = true;
  bool _isCapsLockOn = false;
  bool _hasFocus = false;
  StreamSubscription<bool>? _capsLockSubscription;

  PasswordTextFieldTheme get _theme =>
      (widget.theme ?? const PasswordTextFieldTheme())
          .merge(PasswordTextFieldTheme.defaults);

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    // Subscribe to Caps Lock state changes using flutter_ime
    _capsLockSubscription = onCapsLockChanged().listen(_onCapsLockChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.autofocus) {
        _focusNode.requestFocus();
      }
    });
  }

  @override
  void didUpdateWidget(covariant PasswordTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_onFocusChange);
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _capsLockSubscription?.cancel();
    super.dispose();
  }

  void _onFocusChange() {
    final hasFocus = _focusNode.hasFocus;

    if (hasFocus != _hasFocus) {
      setState(() {
        _hasFocus = hasFocus;
      });

      if (hasFocus) {
        // Check Caps Lock state when focus is gained
        _checkCapsLockState();
        widget.onFocus?.call();
      } else {
        // Hide Caps Lock warning when focus is lost
        if (_isCapsLockOn) {
          setState(() {
            _isCapsLockOn = false;
          });
          widget.onCapsLockStateChanged?.call(false);
        }
        widget.onLostFocus?.call();
      }
    }
  }

  /// Checks the current Caps Lock state using flutter_ime.
  ///
  /// Updates the internal state and notifies listeners if the state has changed.
  Future<void> _checkCapsLockState() async {
    final capsLockOn = await isCapsLockOn();

    if (!mounted) return;

    if (capsLockOn != _isCapsLockOn) {
      setState(() {
        _isCapsLockOn = capsLockOn;
      });
      widget.onCapsLockStateChanged?.call(capsLockOn);
    }
  }

  /// Handles Caps Lock state changes from flutter_ime stream.
  ///
  /// Only updates state when the field has focus.
  void _onCapsLockChanged(bool isOn) {
    if (!mounted) return;

    if (_hasFocus && isOn != _isCapsLockOn) {
      setState(() {
        _isCapsLockOn = isOn;
      });
      widget.onCapsLockStateChanged?.call(isOn);
    }
  }

  void _toggleObscure() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  Widget? _buildSuffixIcon(ThemeData appTheme) {
    final theme = _theme;
    final hasVisibilityToggle = widget.showVisibilityToggle;
    final hasSuffixWidget = widget.suffixWidget != null;

    if (!hasVisibilityToggle && !hasSuffixWidget) {
      return null;
    }

    final visibilityButton = hasVisibilityToggle
        ? IconButton(
            onPressed: _toggleObscure,
            icon: _isObscured
                ? (widget.visibilityOffIcon ??
                    Icon(
                      Icons.visibility_off,
                      color: theme.visibilityIconColor ?? appTheme.hintColor,
                      size: theme.visibilityIconSize,
                    ))
                : (widget.visibilityOnIcon ??
                    Icon(
                      Icons.visibility,
                      color: theme.visibilityIconColor ?? appTheme.hintColor,
                      size: theme.visibilityIconSize,
                    )),
          )
        : null;

    if (hasSuffixWidget && hasVisibilityToggle) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.suffixWidget!,
          visibilityButton!,
        ],
      );
    }

    return hasSuffixWidget ? widget.suffixWidget : visibilityButton;
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);
    final theme = _theme;
    final showCapsLockWarning =
        widget.showCapsLockWarning && _isCapsLockOn && _hasFocus;

    final errorColor = theme.errorBorderColor ?? Colors.orange;
    final focusColor = theme.focusBorderColor ?? appTheme.primaryColor;

    return Container(
      margin: widget.margin,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: theme.width,
            height: theme.height,
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              obscureText: _isObscured,
              enabled: widget.enabled,
              maxLength: widget.maxLength,
              inputFormatters: widget.inputFormatters,
              style: theme.textStyle ?? appTheme.textTheme.bodyMedium,
              onChanged: widget.onChange,
              onSubmitted: widget.onSubmitted,
              decoration: InputDecoration(
                counterText: '',
                contentPadding: theme.contentPadding,
                labelText: widget.useFloatingLabel ? widget.labelText : null,
                labelStyle: theme.labelStyle,
                floatingLabelStyle: theme.floatingLabelStyle ??
                    TextStyle(
                      color: showCapsLockWarning ? errorColor : focusColor,
                    ),
                floatingLabelBehavior: widget.useFloatingLabel
                    ? FloatingLabelBehavior.auto
                    : FloatingLabelBehavior.never,
                hintText: widget.hintText ?? widget.labelText,
                hintStyle: theme.hintStyle,
                fillColor: theme.backgroundColor,
                filled: theme.backgroundColor != null,
                prefixIcon: widget.prefixWidget,
                suffixIcon: _buildSuffixIcon(appTheme),
                focusedBorder: OutlineInputBorder(
                  borderSide: theme.borderWidth == 0
                      ? BorderSide.none
                      : BorderSide(
                          color: showCapsLockWarning ? errorColor : focusColor,
                          width: theme.borderWidth!,
                        ),
                  borderRadius: BorderRadius.circular(theme.borderRadius!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: theme.borderWidth == 0
                      ? BorderSide.none
                      : BorderSide(
                          color: theme.borderColor ?? appTheme.dividerColor,
                          width: theme.borderWidth!,
                        ),
                  borderRadius: BorderRadius.circular(theme.borderRadius!),
                ),
                disabledBorder: OutlineInputBorder(
                  borderSide: theme.borderWidth == 0
                      ? BorderSide.none
                      : BorderSide(
                          color: (theme.borderColor ?? appTheme.dividerColor)
                              .withValues(alpha: 0.5),
                          width: theme.borderWidth!,
                        ),
                  borderRadius: BorderRadius.circular(theme.borderRadius!),
                ),
              ),
            ),
          ),
          // Caps Lock warning message
          if (showCapsLockWarning)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                widget.capsLockWarningText ?? 'Caps Lock is on',
                style: theme.capsLockWarningStyle ??
                    TextStyle(
                      color: errorColor,
                      fontSize: 12,
                    ),
              ),
            ),
        ],
      ),
    );
  }
}
