import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_ime/flutter_ime.dart';
import 'package:just_tooltip/just_tooltip.dart' as jt;

import 'password_text_field_theme.dart';

/// Alignment options for warning messages displayed around the text field.
enum WarningAlignment {
  topLeft,
  topCenter,
  topRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

/// Represents the current status of the password field.
///
/// Used by [PasswordFieldWidgetBuilder] to let prefix/suffix builders
/// react to the current field status.
enum PasswordFieldStatus {
  none,
  capsLock,
  pasteBlocked,
  customError,
  checked,
  unchecked,
  disabled,
}

/// Builder typedef for prefix/suffix widgets that receive the current field status.
typedef PasswordFieldWidgetBuilder = Widget Function(
  BuildContext context,
  PasswordFieldStatus status,
);

/// Controls how warning messages (Caps Lock, paste) are displayed.
enum WarningDisplayMode {
  /// Warnings appear as inline text messages above or below the text field.
  message,

  /// Warnings appear inside a tooltip anchored to the text field.
  tooltip,
}

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
    this.capsLockWarningAlignment = WarningAlignment.bottomLeft,
    this.showCapsLockWarning = true,
    this.showVisibilityToggle = true,
    this.visibilityOnIcon,
    this.visibilityOffIcon,
    this.prefixWidgetBuilder,
    this.prefixIconConstraints,
    this.suffixWidgetBuilder,
    this.suffixIconConstraints,
    this.onFocus,
    this.onLostFocus,
    this.onChange,
    this.onSubmitted,
    this.onCapsLockStateChanged,
    this.forceEnglishInput = true,
    this.disablePaste = false,
    this.showPasteWarning = true,
    this.pasteWarningText,
    this.pasteWarningDuration = const Duration(seconds: 3),
    this.pasteWarningAlignment = WarningAlignment.bottomLeft,
    this.onPasteBlocked,
    this.warningDisplayMode = WarningDisplayMode.message,
    this.hasCustomError = false,
    this.isChecked,
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

  /// The alignment of the Caps Lock warning message.
  ///
  /// Defaults to [WarningAlignment.bottomLeft].
  final WarningAlignment capsLockWarningAlignment;

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

  /// Builder for a widget to display before the text input area.
  ///
  /// Receives the current [PasswordFieldStatus], allowing the widget
  /// to react to status changes (e.g., change icon color on caps lock or checked state).
  final PasswordFieldWidgetBuilder? prefixWidgetBuilder;

  /// The constraints for the prefix icon.
  ///
  /// If null, uses Flutter's default [BoxConstraints(minWidth: 48, minHeight: 48)].
  final BoxConstraints? prefixIconConstraints;

  /// Builder for a widget to display after the text input area but before the visibility toggle.
  ///
  /// Receives the current [PasswordFieldStatus], allowing the widget
  /// to react to status changes. When both [suffixWidgetBuilder] and
  /// [showVisibilityToggle] are provided, they are displayed in a row
  /// with the suffix widget first.
  final PasswordFieldWidgetBuilder? suffixWidgetBuilder;

  /// The constraints for the suffix icon.
  ///
  /// If null, uses Flutter's default [BoxConstraints(minWidth: 48, minHeight: 48)].
  final BoxConstraints? suffixIconConstraints;

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

  /// Whether to force English keyboard input when focused.
  ///
  /// When true:
  /// - On Windows: Disables IME when focused, re-enables when unfocused.
  /// - On macOS: Switches to English keyboard when focused and automatically
  ///   switches back to English if the user changes the input source.
  ///
  /// Defaults to true.
  final bool forceEnglishInput;

  /// Whether to disable paste functionality in the text field.
  ///
  /// When true, both keyboard shortcuts (Ctrl+V/Cmd+V) and context menu
  /// paste operations will be blocked.
  /// Defaults to false.
  final bool disablePaste;

  /// Whether to show a warning message when a paste attempt is blocked.
  ///
  /// Only effective when [disablePaste] is true.
  /// Defaults to true.
  final bool showPasteWarning;

  /// The warning message to display when a paste attempt is blocked.
  ///
  /// If null, defaults to 'Paste is disabled'.
  final String? pasteWarningText;

  /// The duration to display the paste warning message before auto-hiding.
  ///
  /// Defaults to 3 seconds.
  final Duration pasteWarningDuration;

  /// The alignment of the paste warning message.
  ///
  /// Defaults to [WarningAlignment.bottomLeft].
  final WarningAlignment pasteWarningAlignment;

  /// Called when a paste attempt is blocked.
  ///
  /// Only called when [disablePaste] is true.
  final VoidCallback? onPasteBlocked;

  /// Controls how warnings are displayed.
  ///
  /// When [WarningDisplayMode.message], warnings appear as text above/below
  /// the text field (original behavior).
  /// When [WarningDisplayMode.tooltip], warnings appear in a tooltip
  /// anchored to the text field, and inline messages are hidden.
  /// Each warning uses its own alignment ([capsLockWarningAlignment],
  /// [pasteWarningAlignment]) for tooltip positioning.
  /// Defaults to [WarningDisplayMode.message].
  final WarningDisplayMode warningDisplayMode;

  /// Whether the text field is in a custom error state.
  ///
  /// When true, the border color changes to [PasswordTextFieldTheme.customErrorBorderColor]
  /// (or [PasswordTextFieldTheme.errorBorderColor] if not specified).
  /// This is useful for external validation such as password mismatch.
  /// Defaults to false.
  final bool hasCustomError;

  /// The checked state of the text field.
  ///
  /// When true, the border color changes to [PasswordTextFieldTheme.checkedBorderColor].
  /// When false, the border color changes to [PasswordTextFieldTheme.uncheckedBorderColor].
  /// When null, no checked/unchecked styling is applied.
  /// Not intended to be used together with [hasCustomError].
  final bool? isChecked;

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  late FocusNode _focusNode;
  bool _isObscured = true;
  bool _isCapsLockOn = false;
  bool _hasFocus = false;
  bool _showPasteWarning = false;
  PasswordFieldStatus _activeStatus = PasswordFieldStatus.none;
  Timer? _pasteWarningTimer;
  bool _pasteKeyHeld = false;
  StreamSubscription<bool>? _capsLockSubscription;
  StreamSubscription<bool>? _inputSourceSubscription;
  jt.JustTooltipController? _capsLockTooltipController;
  jt.JustTooltipController? _pasteTooltipController;
  int _pasteTooltipKey = 0;

  PasswordTextFieldTheme get _theme =>
      (widget.theme ?? const PasswordTextFieldTheme())
          .merge(PasswordTextFieldTheme.defaults);

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);

    if (widget.enabled == false) {
      _activeStatus = PasswordFieldStatus.disabled;
    }

    // Subscribe to Caps Lock state changes using flutter_ime
    _capsLockSubscription = onCapsLockChanged().listen(_onCapsLockChanged);
    HardwareKeyboard.instance.addHandler(_onHardwareKey);

    if (widget.warningDisplayMode == WarningDisplayMode.tooltip) {
      _capsLockTooltipController = jt.JustTooltipController();
      _pasteTooltipController = jt.JustTooltipController();
    }

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
    if (oldWidget.warningDisplayMode != widget.warningDisplayMode) {
      if (widget.warningDisplayMode == WarningDisplayMode.tooltip) {
        _capsLockTooltipController ??= jt.JustTooltipController();
        _pasteTooltipController ??= jt.JustTooltipController();
      } else {
        _capsLockTooltipController?.hide();
        _capsLockTooltipController = null;
        _pasteTooltipController?.hide();
        _pasteTooltipController = null;
      }
    }
    if (oldWidget.enabled != widget.enabled) {
      _resolveActiveWarning();
    }
    if (oldWidget.hasCustomError != widget.hasCustomError) {
      if (widget.hasCustomError) {
        _activeStatus = PasswordFieldStatus.customError;
      } else {
        _resolveActiveWarning();
      }
    }
    if (oldWidget.isChecked != widget.isChecked) {
      _resolveActiveWarning();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _pasteWarningTimer?.cancel();
    _capsLockSubscription?.cancel();
    _inputSourceSubscription?.cancel();
    HardwareKeyboard.instance.removeHandler(_onHardwareKey);
    _capsLockTooltipController = null;
    _pasteTooltipController = null;
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
        // Handle English input enforcement
        _handleEnglishInputOnFocus();
        widget.onFocus?.call();
      } else {
        // Hide Caps Lock warning when focus is lost
        if (_isCapsLockOn) {
          setState(() {
            _isCapsLockOn = false;
          });
          widget.onCapsLockStateChanged?.call(false);
        }
        // Hide paste warning when focus is lost
        _pasteWarningTimer?.cancel();
        setState(() {
          _showPasteWarning = false;
          _resolveActiveWarning();
        });
        // Restore IME on focus lost
        _handleEnglishInputOnUnfocus();
        widget.onLostFocus?.call();
      }
    }
  }

  /// Handles English input enforcement when focus is gained.
  void _handleEnglishInputOnFocus() {
    if (!widget.forceEnglishInput) return;

    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        disableIME();
        break;
      case TargetPlatform.macOS:
        setEnglishKeyboard();
        _inputSourceSubscription = onInputSourceChanged().listen((isEnglish) {
          if (!isEnglish && _hasFocus) {
            setEnglishKeyboard();
          }
        });
        break;
      default:
        break;
    }
  }

  /// Restores IME when focus is lost.
  void _handleEnglishInputOnUnfocus() {
    if (!widget.forceEnglishInput) return;

    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        enableIME();
        break;
      case TargetPlatform.macOS:
        _inputSourceSubscription?.cancel();
        _inputSourceSubscription = null;
        break;
      default:
        break;
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
        if (capsLockOn && widget.showCapsLockWarning) {
          _activeStatus = PasswordFieldStatus.capsLock;
        } else {
          _resolveActiveWarning();
        }
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
        if (isOn && widget.showCapsLockWarning) {
          _activeStatus = PasswordFieldStatus.capsLock;
        } else {
          _resolveActiveWarning();
        }
      });
      widget.onCapsLockStateChanged?.call(isOn);
    }
  }

  void _toggleObscure() {
    setState(() {
      _isObscured = !_isObscured;
    });
  }

  bool _onHardwareKey(KeyEvent event) {
    if (event is KeyUpEvent && event.logicalKey == LogicalKeyboardKey.keyV) {
      _pasteKeyHeld = false;
    }
    return false;
  }

  void _onPasteBlocked() {
    if (_pasteKeyHeld) return;
    _pasteKeyHeld = true;

    widget.onPasteBlocked?.call();

    if (!widget.showPasteWarning) return;

    _pasteWarningTimer?.cancel();
    if (_showPasteWarning &&
        widget.warningDisplayMode == WarningDisplayMode.tooltip) {
      _pasteTooltipKey++;
      _pasteTooltipController = jt.JustTooltipController();
    }
    setState(() {
      _showPasteWarning = true;
      _activeStatus = PasswordFieldStatus.pasteBlocked;
    });
    _pasteWarningTimer = Timer(widget.pasteWarningDuration, () {
      if (!mounted) return;
      setState(() {
        _showPasteWarning = false;
        _resolveActiveWarning();
      });
    });
  }

  void _hidePasteWarning() {
    if (!_showPasteWarning) return;
    _pasteWarningTimer?.cancel();
    setState(() {
      _showPasteWarning = false;
      _resolveActiveWarning();
    });
  }

  /// Resolves the active status based on current state.
  /// Priority: disabled > customError > capsLock > pasteBlocked > checked/unchecked > none.
  void _resolveActiveWarning() {
    if (widget.enabled == false) {
      _activeStatus = PasswordFieldStatus.disabled;
    } else if (widget.hasCustomError) {
      _activeStatus = PasswordFieldStatus.customError;
    } else if (_isCapsLockOn && _hasFocus && widget.showCapsLockWarning) {
      _activeStatus = PasswordFieldStatus.capsLock;
    } else if (_showPasteWarning) {
      _activeStatus = PasswordFieldStatus.pasteBlocked;
    } else if (widget.isChecked == true) {
      _activeStatus = PasswordFieldStatus.checked;
    } else if (widget.isChecked == false) {
      _activeStatus = PasswordFieldStatus.unchecked;
    } else {
      _activeStatus = PasswordFieldStatus.none;
    }
  }

  /// Returns the appropriate color based on the current active status.
  Color _statusColor(
      Color errorColor,
      Color pasteWarningColor,
      Color customErrorColor,
      Color checkedColor,
      Color uncheckedColor,
      Color focusColor) {
    return switch (_activeStatus) {
      PasswordFieldStatus.disabled => focusColor,
      PasswordFieldStatus.customError => customErrorColor,
      PasswordFieldStatus.capsLock => errorColor,
      PasswordFieldStatus.pasteBlocked => pasteWarningColor,
      PasswordFieldStatus.checked => checkedColor,
      PasswordFieldStatus.unchecked => uncheckedColor,
      PasswordFieldStatus.none => focusColor,
    };
  }

  bool _isTopAlignment(WarningAlignment alignment) {
    return alignment == WarningAlignment.topLeft ||
        alignment == WarningAlignment.topCenter ||
        alignment == WarningAlignment.topRight;
  }

  Alignment _toAlignment(WarningAlignment alignment) {
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
    }
  }

  Widget _buildWarning(
      String text, TextStyle style, WarningAlignment alignment) {
    final isTop = _isTopAlignment(alignment);
    return Padding(
      padding: EdgeInsets.only(
        top: isTop ? 0 : 4,
        bottom: isTop ? 4 : 0,
      ),
      child: Align(
        alignment: _toAlignment(alignment),
        child: Text(text, style: style),
      ),
    );
  }

  ({jt.TooltipDirection direction, jt.TooltipAlignment alignment})
      _mapWarningAlignmentToTooltip(WarningAlignment warningAlignment) {
    switch (warningAlignment) {
      case WarningAlignment.topLeft:
        return (
          direction: jt.TooltipDirection.top,
          alignment: jt.TooltipAlignment.start
        );
      case WarningAlignment.topCenter:
        return (
          direction: jt.TooltipDirection.top,
          alignment: jt.TooltipAlignment.center
        );
      case WarningAlignment.topRight:
        return (
          direction: jt.TooltipDirection.top,
          alignment: jt.TooltipAlignment.end
        );
      case WarningAlignment.bottomLeft:
        return (
          direction: jt.TooltipDirection.bottom,
          alignment: jt.TooltipAlignment.start
        );
      case WarningAlignment.bottomCenter:
        return (
          direction: jt.TooltipDirection.bottom,
          alignment: jt.TooltipAlignment.center
        );
      case WarningAlignment.bottomRight:
        return (
          direction: jt.TooltipDirection.bottom,
          alignment: jt.TooltipAlignment.end
        );
    }
  }

  void _updateTooltipVisibility(
      jt.JustTooltipController? controller, bool shouldShow) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (shouldShow) {
        controller?.show();
      } else {
        controller?.hide();
      }
    });
  }

  Widget? _buildSuffixIcon(ThemeData appTheme) {
    final theme = _theme;
    final hasVisibilityToggle = widget.showVisibilityToggle;
    final hasSuffixBuilder = widget.suffixWidgetBuilder != null;

    if (!hasVisibilityToggle && !hasSuffixBuilder) {
      return null;
    }

    final visibilityButton = hasVisibilityToggle
        ? ExcludeFocus(
            child: IconButton(
              onPressed: widget.enabled == false ? null : _toggleObscure,
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
            ),
          )
        : null;

    final suffixWidget = hasSuffixBuilder
        ? widget.suffixWidgetBuilder!(context, _activeStatus)
        : null;

    if (hasSuffixBuilder && hasVisibilityToggle) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          suffixWidget!,
          visibilityButton!,
        ],
      );
    }

    return hasSuffixBuilder ? suffixWidget : visibilityButton;
  }

  Widget _buildTextField(
      ThemeData appTheme,
      PasswordTextFieldTheme theme,
      Color errorColor,
      Color pasteWarningColor,
      Color customErrorColor,
      Color checkedColor,
      Color uncheckedColor,
      Color focusColor) {
    final activeColor = _statusColor(errorColor, pasteWarningColor,
        customErrorColor, checkedColor, uncheckedColor, focusColor);
    final enabledBorderColor = switch (_activeStatus) {
      PasswordFieldStatus.customError => customErrorColor,
      PasswordFieldStatus.checked => checkedColor,
      PasswordFieldStatus.unchecked => uncheckedColor,
      _ => theme.borderColor ?? appTheme.dividerColor,
    };

    final textField = SizedBox(
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
        style: widget.enabled == false
            ? (theme.disabledTextStyle ??
                theme.textStyle ??
                appTheme.textTheme.bodyMedium)
            : (theme.textStyle ?? appTheme.textTheme.bodyMedium),
        onChanged: (value) {
          _hidePasteWarning();
          widget.onChange?.call(value);
        },
        onSubmitted: widget.onSubmitted,
        decoration: InputDecoration(
          counterText: '',
          contentPadding: theme.contentPadding,
          labelText: widget.useFloatingLabel ? widget.labelText : null,
          labelStyle: theme.labelStyle,
          floatingLabelStyle:
              theme.floatingLabelStyle ?? TextStyle(color: activeColor),
          floatingLabelBehavior: widget.useFloatingLabel
              ? FloatingLabelBehavior.auto
              : FloatingLabelBehavior.never,
          hintText: widget.hintText ?? widget.labelText,
          hintStyle: theme.hintStyle,
          fillColor: theme.backgroundColor,
          filled: theme.backgroundColor != null,
          prefixIcon: widget.prefixWidgetBuilder?.call(context, _activeStatus),
          prefixIconConstraints: widget.prefixIconConstraints,
          suffixIcon: _buildSuffixIcon(appTheme),
          suffixIconConstraints: widget.suffixIconConstraints,
          focusedBorder: OutlineInputBorder(
            borderSide: theme.borderWidth == 0
                ? BorderSide.none
                : BorderSide(
                    color: activeColor,
                    width: theme.borderWidth!,
                  ),
            borderRadius: BorderRadius.circular(theme.borderRadius!),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: theme.borderWidth == 0
                ? BorderSide.none
                : BorderSide(
                    color: enabledBorderColor,
                    width: theme.borderWidth!,
                  ),
            borderRadius: BorderRadius.circular(theme.borderRadius!),
          ),
          disabledBorder: OutlineInputBorder(
            borderSide: theme.borderWidth == 0
                ? BorderSide.none
                : BorderSide(
                    color: theme.disabledBorderColor ??
                        (theme.borderColor ?? appTheme.dividerColor)
                            .withValues(alpha: 0.5),
                    width: theme.borderWidth!,
                  ),
            borderRadius: BorderRadius.circular(theme.borderRadius!),
          ),
        ),
      ),
    );

    if (widget.disablePaste) {
      return Actions(
        actions: {
          PasteTextIntent: CallbackAction<PasteTextIntent>(
            onInvoke: (intent) {
              _onPasteBlocked();
              return null;
            },
          ),
        },
        child: textField,
      );
    }

    return textField;
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);
    final theme = _theme;
    final showCapsLockWarning =
        widget.showCapsLockWarning && _isCapsLockOn && _hasFocus;

    final errorColor = theme.errorBorderColor ?? Colors.orange;
    final pasteWarningColor = theme.pasteWarningBorderColor ?? errorColor;
    final customErrorColor = theme.customErrorBorderColor ?? errorColor;
    final checkedColor = theme.checkedBorderColor ?? Colors.green;
    final uncheckedColor = theme.uncheckedBorderColor ?? errorColor;
    final focusColor = theme.focusBorderColor ?? appTheme.primaryColor;

    final textField = _buildTextField(
        appTheme,
        theme,
        errorColor,
        pasteWarningColor,
        customErrorColor,
        checkedColor,
        uncheckedColor,
        focusColor);

    // Tooltip mode
    if (widget.warningDisplayMode == WarningDisplayMode.tooltip) {
      _updateTooltipVisibility(_capsLockTooltipController,
          _activeStatus == PasswordFieldStatus.capsLock);
      _updateTooltipVisibility(_pasteTooltipController,
          _activeStatus == PasswordFieldStatus.pasteBlocked);

      final capsLockMapping =
          _mapWarningAlignmentToTooltip(widget.capsLockWarningAlignment);
      final pasteMapping =
          _mapWarningAlignmentToTooltip(widget.pasteWarningAlignment);

      final tt = theme.tooltipTheme;
      final tooltipOffset = tt?.offset ?? 8.0;
      final tooltipCrossAxisOffset = tt?.crossAxisOffset ?? 0.0;
      final tooltipAnimationDuration =
          tt?.animationDuration ?? const Duration(milliseconds: 150);
      final tooltipScreenMargin = tt?.screenMargin ?? 8.0;
      final tooltipInteractive = tt?.interactive ?? true;
      final tooltipWaitDuration = tt?.waitDuration;
      final tooltipShowDuration = tt?.showDuration;
      final tooltipAnimation = tt?.animation;
      final tooltipAnimationCurve = tt?.animationCurve;
      final tooltipFadeBegin = tt?.fadeBegin;
      final tooltipScaleBegin = tt?.scaleBegin;
      final tooltipSlideOffset = tt?.slideOffset;
      final tooltipRotationBegin = tt?.rotationBegin;

      jt.JustTooltipTheme buildTooltipTheme(TextStyle textStyle) {
        return jt.JustTooltipTheme(
          backgroundColor: tt?.backgroundColor ?? const Color(0xFF616161),
          borderRadius: tt?.borderRadius ?? BorderRadius.circular(6),
          padding: tt?.padding ??
              const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          elevation: tt?.elevation ?? 4.0,
          boxShadow: tt?.boxShadow,
          borderColor: tt?.borderColor,
          borderWidth: tt?.borderWidth ?? 0.0,
          textStyle: textStyle,
          showArrow: tt?.showArrow ?? false,
          arrowBaseWidth: tt?.arrowBaseWidth ?? 12.0,
          arrowLength: tt?.arrowLength ?? 6.0,
          arrowPositionRatio: tt?.arrowPositionRatio ?? 0.25,
        );
      }

      Widget child = textField;

      child = jt.JustTooltip(
        key: ValueKey(_pasteTooltipKey),
        controller: _pasteTooltipController,
        enableTap: false,
        enableHover: false,
        interactive: tooltipInteractive,
        direction: tt?.direction ?? pasteMapping.direction,
        alignment: tt?.alignment ?? pasteMapping.alignment,
        offset: tooltipOffset,
        crossAxisOffset: tooltipCrossAxisOffset,
        screenMargin: tooltipScreenMargin,
        waitDuration: tooltipWaitDuration,
        showDuration: tooltipShowDuration,
        animationDuration: tooltipAnimationDuration,
        animation: tooltipAnimation ?? jt.TooltipAnimation.fade,
        animationCurve: tooltipAnimationCurve,
        fadeBegin: tooltipFadeBegin ?? 0.0,
        scaleBegin: tooltipScaleBegin ?? 0.0,
        slideOffset: tooltipSlideOffset ?? 0.3,
        rotationBegin: tooltipRotationBegin ?? -0.05,
        theme: buildTooltipTheme(
          tt?.textStyle ??
              theme.pasteWarningStyle ??
              TextStyle(color: pasteWarningColor, fontSize: 12),
        ),
        message: widget.pasteWarningText ?? 'Paste is disabled',
        child: child,
      );

      child = jt.JustTooltip(
        controller: _capsLockTooltipController,
        enableTap: false,
        enableHover: false,
        interactive: tooltipInteractive,
        direction: tt?.direction ?? capsLockMapping.direction,
        alignment: tt?.alignment ?? capsLockMapping.alignment,
        offset: tooltipOffset,
        crossAxisOffset: tooltipCrossAxisOffset,
        screenMargin: tooltipScreenMargin,
        waitDuration: tooltipWaitDuration,
        showDuration: tooltipShowDuration,
        animationDuration: tooltipAnimationDuration,
        animation: tooltipAnimation ?? jt.TooltipAnimation.fade,
        animationCurve: tooltipAnimationCurve,
        fadeBegin: tooltipFadeBegin ?? 0.0,
        scaleBegin: tooltipScaleBegin ?? 0.0,
        slideOffset: tooltipSlideOffset ?? 0.3,
        rotationBegin: tooltipRotationBegin ?? -0.05,
        theme: buildTooltipTheme(
          tt?.textStyle ??
              theme.capsLockWarningStyle ??
              TextStyle(color: errorColor, fontSize: 12),
        ),
        message: widget.capsLockWarningText ?? 'Caps Lock is on',
        child: child,
      );

      return Container(
        margin: widget.margin,
        width: theme.width,
        child: child,
      );
    }

    // Message mode (original behavior)
    Widget? capsLockWarning;
    if (showCapsLockWarning) {
      capsLockWarning = _buildWarning(
        widget.capsLockWarningText ?? 'Caps Lock is on',
        theme.capsLockWarningStyle ??
            TextStyle(color: errorColor, fontSize: 12),
        widget.capsLockWarningAlignment,
      );
    }

    Widget? pasteWarning;
    if (_showPasteWarning) {
      pasteWarning = _buildWarning(
        widget.pasteWarningText ?? 'Paste is disabled',
        theme.pasteWarningStyle ??
            TextStyle(color: pasteWarningColor, fontSize: 12),
        widget.pasteWarningAlignment,
      );
    }

    return Container(
      margin: widget.margin,
      width: theme.width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top warnings
          if (capsLockWarning != null &&
              _isTopAlignment(widget.capsLockWarningAlignment))
            capsLockWarning,
          if (pasteWarning != null &&
              _isTopAlignment(widget.pasteWarningAlignment))
            pasteWarning,
          // TextField
          textField,
          // Bottom warnings
          if (capsLockWarning != null &&
              !_isTopAlignment(widget.capsLockWarningAlignment))
            capsLockWarning,
          if (pasteWarning != null &&
              !_isTopAlignment(widget.pasteWarningAlignment))
            pasteWarning,
        ],
      ),
    );
  }
}
