# flutter_password_input

A password text field with Caps Lock detection and visibility toggle.

## Features

- Caps Lock warning when focused
- Password visibility toggle
- Force English input mode (disables IME on Windows, switches to English keyboard on macOS)
- Custom error state for external validation
- Disable paste option
- Warnings as inline text or as a tooltip (`WarningDisplayMode`)
- Prefix/suffix widget support
- Theming via `PasswordTextFieldTheme`

## Requirements

| | Minimum |
|---|---|
| Flutter | `3.13.0` |
| Dart | `3.4.0` |

Dart floor raised in `0.7.0`: `flutter_ime` 3.0.0 is a pure-Dart FFI package and its macOS observer needs `NativeCallable.keepIsolateAlive`, added in Dart 3.4. The Flutter floor is unchanged — it was raised in `0.6.1` because `just_tooltip` 0.4.2 walks `RenderObject.parent`, which was `AbstractNode?` (a type without `describeApproximatePaintClip`) before Flutter 3.13.

## Install

```yaml
dependencies:
  flutter_password_input: ^0.6.3
```

## Usage

```dart
import 'package:flutter_password_input/flutter_password_input.dart';

PasswordTextField(
  labelText: 'Password',
  capsLockWarningText: 'Caps Lock is on!',
)
```

### With Theme

```dart
PasswordTextField(
  theme: PasswordTextFieldTheme(
    width: 300,
    borderRadius: 12,
    focusBorderColor: Colors.blue,
  ),
  labelText: 'Password',
)
```

### With Prefix/Suffix Builders

Builders receive the current `PasswordFieldStatus`, so icons can
change color when Caps Lock is on, paste is blocked, a custom error is active, the field is checked/unchecked, or disabled.

```dart
PasswordTextField(
  labelText: 'Password',
  prefixWidgetBuilder: (context, status) => Icon(
    Icons.lock,
    color: status == PasswordFieldStatus.none ? Colors.grey : Colors.orange,
  ),
  suffixWidgetBuilder: (context, status) => IconButton(
    icon: Icon(
      Icons.info,
      color: status == PasswordFieldStatus.none ? Colors.grey : Colors.orange,
    ),
    onPressed: () {},
  ),
)
```

### With isChecked

Use `isChecked` for external validation state (e.g. password match). `null` applies no styling, `true` shows `checkedBorderColor`, `false` shows `uncheckedBorderColor`.

```dart
PasswordTextField(
  labelText: 'Confirm Password',
  isChecked: passwordsMatch ? true : false,
  theme: PasswordTextFieldTheme(
    checkedBorderColor: Colors.green,
    uncheckedBorderColor: Colors.red,
  ),
)
```

### Warning Display Modes

Caps Lock and paste warnings render as inline text above or below the field (`WarningDisplayMode.message`, the default) or as a tooltip anchored to the field (`WarningDisplayMode.tooltip`, styled via `WarningTooltipTheme`). Either way the side is chosen by `capsLockWarningAlignment` / `pasteWarningAlignment`.

```dart
PasswordTextField(
  labelText: 'Password',
  warningDisplayMode: WarningDisplayMode.tooltip,
  theme: PasswordTextFieldTheme(
    tooltipTheme: WarningTooltipTheme(showArrow: true),
  ),
)
```

A tooltip aims at the **visible** part of its field, so it re-aims whenever a surrounding view scrolls, resizes, or reflows — it does not move rigidly with the field, because it is still clamped by `screenMargin`. A field that scrolls entirely out of view hides its tooltip; showing it again is a fresh warning.

## Properties

### PasswordTextField

| Property | Type | Default | Description |
|---|---|---|---|
| `controller` | `TextEditingController?` | `null` | Controls the text being edited |
| `focusNode` | `FocusNode?` | `null` | Defines the keyboard focus |
| `theme` | `PasswordTextFieldTheme?` | `null` | Theme for styling |
| `labelText` | `String?` | `null` | Label text above the field |
| `hintText` | `String?` | `null` | Hint text when empty (falls back to `labelText`) |
| `maxLength` | `int?` | `null` | Maximum character count |
| `enabled` | `bool?` | `null` | Whether the field is enabled |
| `autofocus` | `bool` | `false` | Auto-focus on build |
| `useFloatingLabel` | `bool` | `true` | Floating label animation |
| `margin` | `EdgeInsetsGeometry?` | `null` | Margin around the widget |
| `inputFormatters` | `List<TextInputFormatter>?` | `null` | Input formatters |
| `forceEnglishInput` | `bool` | `true` | Force English keyboard input |
| `showVisibilityToggle` | `bool` | `true` | Show password visibility toggle |
| `visibilityOnIcon` | `Widget?` | `null` | Custom icon when password visible |
| `visibilityOffIcon` | `Widget?` | `null` | Custom icon when password hidden |
| `prefixWidgetBuilder` | `PasswordFieldWidgetBuilder?` | `null` | Builder for widget before the input area (receives `PasswordFieldStatus`) |
| `prefixIconConstraints` | `BoxConstraints?` | `null` | Size constraints for prefix icon |
| `suffixWidgetBuilder` | `PasswordFieldWidgetBuilder?` | `null` | Builder for widget after the input area (receives `PasswordFieldStatus`) |
| `suffixIconConstraints` | `BoxConstraints?` | `null` | Size constraints for suffix icon |
| `showCapsLockWarning` | `bool` | `true` | Show Caps Lock warning |
| `capsLockWarningText` | `String?` | `'Caps Lock is on'` | Caps Lock warning message |
| `capsLockWarningAlignment` | `WarningAlignment` | `bottomLeft` | Caps Lock warning position |
| `disablePaste` | `bool` | `false` | Block paste functionality |
| `showPasteWarning` | `bool` | `true` | Show paste blocked warning |
| `pasteWarningText` | `String?` | `'Paste is disabled'` | Paste warning message |
| `pasteWarningDuration` | `Duration` | `3 seconds` | Auto-hide duration for paste warning |
| `pasteWarningAlignment` | `WarningAlignment` | `bottomLeft` | Paste warning position |
| `warningDisplayMode` | `WarningDisplayMode` | `message` | `message` (inline text) or `tooltip` |
| `hasCustomError` | `bool` | `false` | External error state (changes border color) |
| `isChecked` | `bool?` | `null` | Validation state — `true` shows checked color, `false` shows unchecked color, `null` no effect |
| `onFocus` | `VoidCallback?` | `null` | Called on focus gained |
| `onLostFocus` | `VoidCallback?` | `null` | Called on focus lost |
| `onChange` | `ValueChanged<String>?` | `null` | Called on text change |
| `onSubmitted` | `ValueChanged<String>?` | `null` | Called on submit (Enter) |
| `onCapsLockStateChanged` | `ValueChanged<bool>?` | `null` | Called on Caps Lock state change |
| `onPasteBlocked` | `VoidCallback?` | `null` | Called when paste is blocked |

### PasswordTextFieldTheme

| Property | Type | Default | Description |
|---|---|---|---|
| `width` | `double?` | `250` | Field width |
| `height` | `double?` | `48` | Field height |
| `borderWidth` | `double?` | `1` | Border width (0 to remove) |
| `borderRadius` | `double?` | `8` | Corner radius |
| `contentPadding` | `EdgeInsetsGeometry?` | `h:12, v:14` | Internal padding |
| `backgroundColor` | `Color?` | `null` | Fill color |
| `borderColor` | `Color?` | `null` | Border color (unfocused) |
| `focusBorderColor` | `Color?` | `null` | Border color (focused) |
| `errorBorderColor` | `Color?` | `Colors.orange` | Border color (Caps Lock on) |
| `pasteWarningBorderColor` | `Color?` | `null` | Border color (paste blocked, falls back to `errorBorderColor`) |
| `customErrorBorderColor` | `Color?` | `null` | Border color (custom error, falls back to `errorBorderColor`) |
| `checkedBorderColor` | `Color?` | `Colors.green` | Border color when `isChecked` is `true` |
| `uncheckedBorderColor` | `Color?` | `null` | Border color when `isChecked` is `false` (falls back to `errorBorderColor`) |
| `disabledBorderColor` | `Color?` | `null` | Border color (disabled, falls back to `borderColor` with 50% opacity) |
| `textStyle` | `TextStyle?` | `null` | Input text style |
| `disabledTextStyle` | `TextStyle?` | `null` | Text style when disabled (falls back to `textStyle`) |
| `labelStyle` | `TextStyle?` | `null` | Label text style |
| `hintStyle` | `TextStyle?` | `null` | Hint text style |
| `floatingLabelStyle` | `TextStyle?` | `null` | Floating label style |
| `capsLockWarningStyle` | `TextStyle?` | `null` | Caps Lock warning style |
| `pasteWarningStyle` | `TextStyle?` | `null` | Paste warning style |
| `visibilityIconColor` | `Color?` | `null` | Visibility icon color |
| `visibilityIconSize` | `double?` | `20` | Visibility icon size |
| `tooltipTheme` | `WarningTooltipTheme?` | `null` | Tooltip styling (tooltip mode only) |

### WarningTooltipTheme

Used when `warningDisplayMode` is `WarningDisplayMode.tooltip`.

| Property | Type | Default | Description |
|---|---|---|---|
| `backgroundColor` | `Color?` | `Color(0xFF616161)` | Tooltip background color |
| `borderRadius` | `BorderRadius?` | `circular(6)` | Tooltip corner radius |
| `padding` | `EdgeInsets?` | `h:12, v:8` | Tooltip internal padding |
| `elevation` | `double?` | `4.0` | Shadow elevation |
| `boxShadow` | `List<BoxShadow>?` | `null` | Custom box shadows |
| `borderColor` | `Color?` | `null` | Tooltip border color |
| `borderWidth` | `double?` | `0.0` | Tooltip border width |
| `textStyle` | `TextStyle?` | `null` | Tooltip text style |
| `direction` | `TooltipDirection?` | `null` | Tooltip direction override (`top`, `bottom`, `left`, `right`) |
| `alignment` | `TooltipAlignment?` | `null` | Tooltip alignment override (`start`, `center`, `end`, `startTargetCenter`, `endTargetCenter`) |
| `offset` | `double?` | `8.0` | Gap between tooltip and target |
| `crossAxisOffset` | `double?` | `0.0` | Cross-axis offset |
| `screenMargin` | `double?` | `8.0` | Minimum distance from viewport edges |
| `animationDuration` | `Duration?` | `150ms` | Animation duration |
| `animation` | `TooltipAnimation?` | `fade` | Animation style (`none`, `fade`, `scale`, `slide`, `fadeScale`, `fadeSlide`, `rotation`) |
| `animationCurve` | `Curve?` | `null` | Custom easing curve |
| `fadeBegin` | `double?` | `0.0` | Starting opacity for fade animations |
| `scaleBegin` | `double?` | `0.0` | Starting scale for scale animations |
| `slideOffset` | `double?` | `0.3` | Slide distance ratio for slide animations |
| `rotationBegin` | `double?` | `-0.05` | Starting rotation (turns) for rotation animations |
| `showArrow` | `bool?` | `false` | Show arrow pointer |
| `arrowBaseWidth` | `double?` | `12.0` | Arrow base width |
| `arrowLength` | `double?` | `6.0` | Arrow length |
| `arrowPositionRatio` | `double?` | `0.25` | Arrow position (0.0-1.0) |
| `interactive` | `bool?` | `true` | **No effect** — see below |
| `waitDuration` | `Duration?` | `null` | **No effect** — see below |
| `showDuration` | `Duration?` | `null` | Auto-hide after this duration |

`interactive` and `waitDuration` are inert. Both are read by `just_tooltip` only along its hover path, and these warning tooltips are built with `enableHover: false` — they are driven entirely by a controller, so no pointer ever enters or leaves them. They are still accepted so the theme stays a superset of `just_tooltip`'s options, but setting them changes nothing. `showDuration` does work: a programmatic show starts the auto-hide countdown explicitly.

## License

MIT
