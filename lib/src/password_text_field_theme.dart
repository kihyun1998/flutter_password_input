import 'package:flutter/material.dart';
import 'package:just_tooltip/just_tooltip.dart'
    show TooltipAlignment, TooltipAnimation, TooltipDirection;

/// A theme class that defines the visual styling for warning tooltips.
///
/// Used when [WarningDisplayMode.tooltip] is active. All properties
/// map directly to [JustTooltip] widget parameters.
///
/// Example usage:
/// ```dart
/// const tooltipTheme = WarningTooltipTheme(
///   backgroundColor: Colors.black87,
///   borderRadius: BorderRadius.all(Radius.circular(8)),
///   textStyle: TextStyle(color: Colors.white, fontSize: 13),
/// );
/// ```
class WarningTooltipTheme {
  const WarningTooltipTheme({
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.elevation,
    this.boxShadow,
    this.borderColor,
    this.borderWidth,
    this.textStyle,
    this.direction,
    this.alignment,
    this.offset,
    this.crossAxisOffset,
    this.screenMargin,
    this.animationDuration,
    this.showArrow,
    this.arrowBaseWidth,
    this.arrowLength,
    this.arrowPositionRatio,
    this.interactive,
    this.waitDuration,
    this.showDuration,
    this.animation,
    this.animationCurve,
    this.fadeBegin,
    this.scaleBegin,
    this.slideOffset,
    this.rotationBegin,
  });

  /// The background color of the tooltip.
  ///
  /// If null, defaults to Color(0xFF616161).
  final Color? backgroundColor;

  /// The border radius of the tooltip.
  ///
  /// If null, defaults to BorderRadius.circular(6).
  final BorderRadius? borderRadius;

  /// The padding inside the tooltip.
  ///
  /// If null, defaults to EdgeInsets.symmetric(horizontal: 12, vertical: 8).
  final EdgeInsets? padding;

  /// The shadow elevation of the tooltip.
  ///
  /// If null, defaults to 4.0.
  final double? elevation;

  /// Custom box shadows for the tooltip.
  ///
  /// When provided, overrides the default elevation-based shadow.
  final List<BoxShadow>? boxShadow;

  /// The border color drawn along the tooltip outline.
  ///
  /// When [showArrow] is true, the border follows the unified shape
  /// including the arrow. If null or [borderWidth] is 0, no border is drawn.
  final Color? borderColor;

  /// The border stroke width.
  ///
  /// If null, defaults to 0.0 (no border).
  final double? borderWidth;

  /// The default text style for tooltip content.
  ///
  /// If null, individual warning styles
  /// ([capsLockWarningStyle], [pasteWarningStyle]) are used instead.
  final TextStyle? textStyle;

  /// Which side the tooltip appears on.
  ///
  /// When set, overrides the direction derived from
  /// [PasswordTextField.capsLockWarningAlignment] and
  /// [PasswordTextField.pasteWarningAlignment].
  /// If null, the per-warning alignment is used.
  final TooltipDirection? direction;

  /// The alignment of the tooltip along the cross-axis.
  ///
  /// When set, overrides the alignment derived from
  /// [PasswordTextField.capsLockWarningAlignment] and
  /// [PasswordTextField.pasteWarningAlignment].
  /// If null, the per-warning alignment is used.
  final TooltipAlignment? alignment;

  /// The gap between the tooltip and the target widget.
  ///
  /// If null, defaults to 8.0.
  final double? offset;

  /// The cross-axis offset of the tooltip.
  ///
  /// If null, defaults to 0.0.
  final double? crossAxisOffset;

  /// Minimum distance between the tooltip and the viewport edges.
  ///
  /// If null, defaults to 8.0.
  final double? screenMargin;

  /// The duration of the tooltip fade animation.
  ///
  /// If null, defaults to 150ms.
  final Duration? animationDuration;

  /// Whether to show an arrow pointing from the tooltip to the target widget.
  ///
  /// If null, defaults to false.
  final bool? showArrow;

  /// The base width of the tooltip arrow.
  ///
  /// Only used when [showArrow] is true.
  final double? arrowBaseWidth;

  /// The length of the tooltip arrow.
  ///
  /// Only used when [showArrow] is true.
  final double? arrowLength;

  /// The position ratio of the arrow along the tooltip edge.
  ///
  /// A value between 0.0 and 1.0. Only used when [showArrow] is true.
  final double? arrowPositionRatio;

  /// Whether the tooltip content is interactive.
  ///
  /// When true, hovering over the tooltip keeps it visible.
  /// If null, defaults to true.
  final bool? interactive;

  /// The delay before the tooltip appears.
  ///
  /// If null, the tooltip appears immediately.
  final Duration? waitDuration;

  /// The duration after which the tooltip auto-hides.
  ///
  /// If null, the tooltip stays visible until dismissed.
  final Duration? showDuration;

  /// The animation style for the tooltip.
  ///
  /// If null, defaults to [TooltipAnimation.fade].
  final TooltipAnimation? animation;

  /// Custom easing curve for the tooltip animation.
  ///
  /// If null, uses the default curve for the selected animation.
  final Curve? animationCurve;

  /// The starting opacity for fade animations.
  ///
  /// If null, defaults to 0.0.
  final double? fadeBegin;

  /// The starting scale for scale animations.
  ///
  /// If null, defaults to 0.0.
  final double? scaleBegin;

  /// The slide distance ratio for slide animations.
  ///
  /// If null, defaults to 0.3.
  final double? slideOffset;

  /// The starting rotation (in turns) for rotation animations.
  ///
  /// If null, defaults to -0.05.
  final double? rotationBegin;

  /// Merges this theme with another, with this theme's values taking priority.
  WarningTooltipTheme merge(WarningTooltipTheme? other) {
    if (other == null) return this;
    return WarningTooltipTheme(
      backgroundColor: backgroundColor ?? other.backgroundColor,
      borderRadius: borderRadius ?? other.borderRadius,
      padding: padding ?? other.padding,
      elevation: elevation ?? other.elevation,
      boxShadow: boxShadow ?? other.boxShadow,
      borderColor: borderColor ?? other.borderColor,
      borderWidth: borderWidth ?? other.borderWidth,
      textStyle: textStyle ?? other.textStyle,
      direction: direction ?? other.direction,
      alignment: alignment ?? other.alignment,
      offset: offset ?? other.offset,
      crossAxisOffset: crossAxisOffset ?? other.crossAxisOffset,
      screenMargin: screenMargin ?? other.screenMargin,
      animationDuration: animationDuration ?? other.animationDuration,
      showArrow: showArrow ?? other.showArrow,
      arrowBaseWidth: arrowBaseWidth ?? other.arrowBaseWidth,
      arrowLength: arrowLength ?? other.arrowLength,
      arrowPositionRatio: arrowPositionRatio ?? other.arrowPositionRatio,
      interactive: interactive ?? other.interactive,
      waitDuration: waitDuration ?? other.waitDuration,
      showDuration: showDuration ?? other.showDuration,
      animation: animation ?? other.animation,
      animationCurve: animationCurve ?? other.animationCurve,
      fadeBegin: fadeBegin ?? other.fadeBegin,
      scaleBegin: scaleBegin ?? other.scaleBegin,
      slideOffset: slideOffset ?? other.slideOffset,
      rotationBegin: rotationBegin ?? other.rotationBegin,
    );
  }

  /// Creates a copy with the given properties overridden.
  WarningTooltipTheme copyWith({
    Color? backgroundColor,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    double? elevation,
    List<BoxShadow>? boxShadow,
    Color? borderColor,
    double? borderWidth,
    TextStyle? textStyle,
    TooltipDirection? direction,
    TooltipAlignment? alignment,
    double? offset,
    double? crossAxisOffset,
    double? screenMargin,
    Duration? animationDuration,
    bool? showArrow,
    double? arrowBaseWidth,
    double? arrowLength,
    double? arrowPositionRatio,
    bool? interactive,
    Duration? waitDuration,
    Duration? showDuration,
    TooltipAnimation? animation,
    Curve? animationCurve,
    double? fadeBegin,
    double? scaleBegin,
    double? slideOffset,
    double? rotationBegin,
  }) {
    return WarningTooltipTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      elevation: elevation ?? this.elevation,
      boxShadow: boxShadow ?? this.boxShadow,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      textStyle: textStyle ?? this.textStyle,
      direction: direction ?? this.direction,
      alignment: alignment ?? this.alignment,
      offset: offset ?? this.offset,
      crossAxisOffset: crossAxisOffset ?? this.crossAxisOffset,
      screenMargin: screenMargin ?? this.screenMargin,
      animationDuration: animationDuration ?? this.animationDuration,
      showArrow: showArrow ?? this.showArrow,
      arrowBaseWidth: arrowBaseWidth ?? this.arrowBaseWidth,
      arrowLength: arrowLength ?? this.arrowLength,
      arrowPositionRatio: arrowPositionRatio ?? this.arrowPositionRatio,
      interactive: interactive ?? this.interactive,
      waitDuration: waitDuration ?? this.waitDuration,
      showDuration: showDuration ?? this.showDuration,
      animation: animation ?? this.animation,
      animationCurve: animationCurve ?? this.animationCurve,
      fadeBegin: fadeBegin ?? this.fadeBegin,
      scaleBegin: scaleBegin ?? this.scaleBegin,
      slideOffset: slideOffset ?? this.slideOffset,
      rotationBegin: rotationBegin ?? this.rotationBegin,
    );
  }
}

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
    this.pasteWarningBorderColor,
    this.customErrorBorderColor,
    this.checkedBorderColor,
    this.uncheckedBorderColor,
    this.disabledBorderColor,
    this.textStyle,
    this.disabledTextStyle,
    this.labelStyle,
    this.hintStyle,
    this.floatingLabelStyle,
    this.capsLockWarningStyle,
    this.pasteWarningStyle,
    this.visibilityIconColor,
    this.visibilityIconSize,
    this.tooltipTheme,
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

  /// The border color when a paste attempt is blocked.
  ///
  /// Also used as the default paste warning message text color
  /// when [pasteWarningStyle] is not specified.
  /// If null, falls back to [errorBorderColor].
  final Color? pasteWarningBorderColor;

  /// The border color when [PasswordTextField.hasCustomError] is true.
  ///
  /// If null, falls back to [errorBorderColor].
  final Color? customErrorBorderColor;

  /// The border color when [PasswordTextField.isChecked] is true.
  ///
  /// If null, defaults to Colors.green.
  final Color? checkedBorderColor;

  /// The border color when [PasswordTextField.isChecked] is false.
  ///
  /// If null, falls back to [errorBorderColor].
  final Color? uncheckedBorderColor;

  /// The border color when the text field is disabled.
  ///
  /// If null, falls back to [borderColor] with 50% opacity.
  final Color? disabledBorderColor;

  /// The text style for the input text.
  ///
  /// If null, uses the theme's bodyMedium text style.
  final TextStyle? textStyle;

  /// The text style for the input text when the field is disabled.
  ///
  /// If null, falls back to [textStyle] with the theme's disabled color.
  final TextStyle? disabledTextStyle;

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

  /// The text style for the paste warning message.
  ///
  /// If null, uses [errorBorderColor] with font size 12.
  final TextStyle? pasteWarningStyle;

  /// The color of the visibility toggle icon.
  ///
  /// If null, uses the theme's hint color.
  final Color? visibilityIconColor;

  /// The size of the visibility toggle icon.
  ///
  /// Defaults to 20 if not specified.
  final double? visibilityIconSize;

  /// The theme for warning tooltips.
  ///
  /// Only used when [WarningDisplayMode.tooltip] is active.
  /// See [WarningTooltipTheme] for available customization options.
  final WarningTooltipTheme? tooltipTheme;

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
      pasteWarningBorderColor:
          pasteWarningBorderColor ?? other.pasteWarningBorderColor,
      customErrorBorderColor:
          customErrorBorderColor ?? other.customErrorBorderColor,
      checkedBorderColor: checkedBorderColor ?? other.checkedBorderColor,
      uncheckedBorderColor: uncheckedBorderColor ?? other.uncheckedBorderColor,
      disabledBorderColor: disabledBorderColor ?? other.disabledBorderColor,
      textStyle: textStyle ?? other.textStyle,
      disabledTextStyle: disabledTextStyle ?? other.disabledTextStyle,
      labelStyle: labelStyle ?? other.labelStyle,
      hintStyle: hintStyle ?? other.hintStyle,
      floatingLabelStyle: floatingLabelStyle ?? other.floatingLabelStyle,
      capsLockWarningStyle: capsLockWarningStyle ?? other.capsLockWarningStyle,
      pasteWarningStyle: pasteWarningStyle ?? other.pasteWarningStyle,
      visibilityIconColor: visibilityIconColor ?? other.visibilityIconColor,
      visibilityIconSize: visibilityIconSize ?? other.visibilityIconSize,
      tooltipTheme:
          tooltipTheme?.merge(other.tooltipTheme) ?? other.tooltipTheme,
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
    Color? pasteWarningBorderColor,
    Color? customErrorBorderColor,
    Color? checkedBorderColor,
    Color? uncheckedBorderColor,
    Color? disabledBorderColor,
    TextStyle? textStyle,
    TextStyle? disabledTextStyle,
    TextStyle? labelStyle,
    TextStyle? hintStyle,
    TextStyle? floatingLabelStyle,
    TextStyle? capsLockWarningStyle,
    TextStyle? pasteWarningStyle,
    Color? visibilityIconColor,
    double? visibilityIconSize,
    WarningTooltipTheme? tooltipTheme,
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
      pasteWarningBorderColor:
          pasteWarningBorderColor ?? this.pasteWarningBorderColor,
      customErrorBorderColor:
          customErrorBorderColor ?? this.customErrorBorderColor,
      checkedBorderColor: checkedBorderColor ?? this.checkedBorderColor,
      uncheckedBorderColor: uncheckedBorderColor ?? this.uncheckedBorderColor,
      disabledBorderColor: disabledBorderColor ?? this.disabledBorderColor,
      textStyle: textStyle ?? this.textStyle,
      disabledTextStyle: disabledTextStyle ?? this.disabledTextStyle,
      labelStyle: labelStyle ?? this.labelStyle,
      hintStyle: hintStyle ?? this.hintStyle,
      floatingLabelStyle: floatingLabelStyle ?? this.floatingLabelStyle,
      capsLockWarningStyle: capsLockWarningStyle ?? this.capsLockWarningStyle,
      pasteWarningStyle: pasteWarningStyle ?? this.pasteWarningStyle,
      visibilityIconColor: visibilityIconColor ?? this.visibilityIconColor,
      visibilityIconSize: visibilityIconSize ?? this.visibilityIconSize,
      tooltipTheme: tooltipTheme ?? this.tooltipTheme,
    );
  }
}
