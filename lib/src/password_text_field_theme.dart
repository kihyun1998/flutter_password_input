import 'package:flutter/material.dart';

/// A theme class that defines the visual styling for [PasswordTextField].
///
/// This class encapsulates all style-related properties, allowing for
/// easy reuse and consistent styling across multiple password fields.
///
/// Example usage:
/// ```dart
/// const myTheme = PasswordTextFieldTheme(
///   width: 300,
///   height: 56,
///   borderRadius: 12,
///   focusBorderColor: Colors.blue,
///   backgroundColor: Colors.grey,
/// );
///
/// PasswordTextField(
///   theme: myTheme,
///   labelText: 'Password',
/// )
/// ```
class PasswordTextFieldTheme {
  const PasswordTextFieldTheme({
    this.width,
    this.height,
    this.borderWidth,
    this.borderRadius,
    this.contentPadding,
    this.backgroundColor,
    this.borderColor,
    this.focusBorderColor,
    this.errorBorderColor,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.floatingLabelStyle,
    this.capsLockWarningStyle,
    this.visibilityIconColor,
    this.visibilityIconSize,
  });

  /// The width of the text field.
  ///
  /// Defaults to 250 if not specified.
  final double? width;

  /// The height of the text field.
  ///
  /// Defaults to 48 if not specified.
  final double? height;

  /// The width of the border around the text field.
  ///
  /// Set to 0 to remove the border entirely.
  /// Defaults to 1 if not specified.
  final double? borderWidth;

  /// The border radius of the text field corners.
  ///
  /// Defaults to 8 if not specified.
  final double? borderRadius;

  /// The padding inside the text field around the input area.
  ///
  /// Defaults to EdgeInsets.symmetric(horizontal: 12, vertical: 14).
  final EdgeInsetsGeometry? contentPadding;

  /// The background fill color of the text field.
  ///
  /// If null, the text field will have a transparent background.
  final Color? backgroundColor;

  /// The border color when the text field is not focused.
  ///
  /// If null, uses the theme's divider color.
  final Color? borderColor;

  /// The border color when the text field is focused.
  ///
  /// If null, uses the theme's primary color.
  final Color? focusBorderColor;

  /// The border color when Caps Lock is enabled (error state).
  ///
  /// Also used for the Caps Lock warning message text color.
  /// Defaults to Colors.orange if not specified.
  final Color? errorBorderColor;

  /// The text style for the input text.
  ///
  /// If null, uses the theme's bodyMedium text style.
  final TextStyle? textStyle;

  /// The text style for the label text.
  final TextStyle? labelStyle;

  /// The text style for the hint text.
  final TextStyle? hintStyle;

  /// The text style for the floating label when focused.
  ///
  /// If null, uses [focusBorderColor] or [errorBorderColor] based on state.
  final TextStyle? floatingLabelStyle;

  /// The text style for the Caps Lock warning message.
  ///
  /// If null, uses [errorBorderColor] with font size 12.
  final TextStyle? capsLockWarningStyle;

  /// The color of the visibility toggle icon.
  ///
  /// If null, uses the theme's hint color.
  final Color? visibilityIconColor;

  /// The size of the visibility toggle icon.
  ///
  /// Defaults to 20 if not specified.
  final double? visibilityIconSize;

  /// The default theme values used when properties are not specified.
  ///
  /// Contains the following defaults:
  /// - width: 250
  /// - height: 48
  /// - borderWidth: 1
  /// - borderRadius: 8
  /// - contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14)
  /// - visibilityIconSize: 20
  static const PasswordTextFieldTheme defaults = PasswordTextFieldTheme(
    width: 250,
    height: 48,
    borderWidth: 1,
    borderRadius: 8,
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    visibilityIconSize: 20,
  );

  /// Merges this theme with another theme, with this theme's values taking priority.
  ///
  /// For each property, if this theme has a non-null value, it is used.
  /// Otherwise, the value from [other] is used.
  ///
  /// Returns this theme unchanged if [other] is null.
  PasswordTextFieldTheme merge(PasswordTextFieldTheme? other) {
    if (other == null) return this;
    return PasswordTextFieldTheme(
      width: width ?? other.width,
      height: height ?? other.height,
      borderWidth: borderWidth ?? other.borderWidth,
      borderRadius: borderRadius ?? other.borderRadius,
      contentPadding: contentPadding ?? other.contentPadding,
      backgroundColor: backgroundColor ?? other.backgroundColor,
      borderColor: borderColor ?? other.borderColor,
      focusBorderColor: focusBorderColor ?? other.focusBorderColor,
      errorBorderColor: errorBorderColor ?? other.errorBorderColor,
      textStyle: textStyle ?? other.textStyle,
      labelStyle: labelStyle ?? other.labelStyle,
      hintStyle: hintStyle ?? other.hintStyle,
      floatingLabelStyle: floatingLabelStyle ?? other.floatingLabelStyle,
      capsLockWarningStyle: capsLockWarningStyle ?? other.capsLockWarningStyle,
      visibilityIconColor: visibilityIconColor ?? other.visibilityIconColor,
      visibilityIconSize: visibilityIconSize ?? other.visibilityIconSize,
    );
  }

  /// Creates a copy of this theme with the given properties overridden.
  ///
  /// Any property that is not explicitly provided will retain its current value.
  PasswordTextFieldTheme copyWith({
    double? width,
    double? height,
    double? borderWidth,
    double? borderRadius,
    EdgeInsetsGeometry? contentPadding,
    Color? backgroundColor,
    Color? borderColor,
    Color? focusBorderColor,
    Color? errorBorderColor,
    TextStyle? textStyle,
    TextStyle? labelStyle,
    TextStyle? hintStyle,
    TextStyle? floatingLabelStyle,
    TextStyle? capsLockWarningStyle,
    Color? visibilityIconColor,
    double? visibilityIconSize,
  }) {
    return PasswordTextFieldTheme(
      width: width ?? this.width,
      height: height ?? this.height,
      borderWidth: borderWidth ?? this.borderWidth,
      borderRadius: borderRadius ?? this.borderRadius,
      contentPadding: contentPadding ?? this.contentPadding,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderColor: borderColor ?? this.borderColor,
      focusBorderColor: focusBorderColor ?? this.focusBorderColor,
      errorBorderColor: errorBorderColor ?? this.errorBorderColor,
      textStyle: textStyle ?? this.textStyle,
      labelStyle: labelStyle ?? this.labelStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      floatingLabelStyle: floatingLabelStyle ?? this.floatingLabelStyle,
      capsLockWarningStyle: capsLockWarningStyle ?? this.capsLockWarningStyle,
      visibilityIconColor: visibilityIconColor ?? this.visibilityIconColor,
      visibilityIconSize: visibilityIconSize ?? this.visibilityIconSize,
    );
  }
}
