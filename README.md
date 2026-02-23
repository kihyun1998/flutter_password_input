# flutter_password_input

A password text field with Caps Lock detection and visibility toggle.

## Features

- Caps Lock warning when focused
- Password visibility toggle
- Force English input mode (disables IME on Windows, switches to English keyboard on macOS)
- Custom error state for external validation
- Disable paste option
- Prefix/suffix widget support
- Theming via `PasswordTextFieldTheme`

## Install

```yaml
dependencies:
  flutter_password_input: ^0.3.2
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

Builders receive the current `PasswordFieldWarning` state, so icons can
change color when Caps Lock is on, paste is blocked, or a custom error is active.

```dart
PasswordTextField(
  labelText: 'Password',
  prefixWidgetBuilder: (context, warning) => Icon(
    Icons.lock,
    color: warning == PasswordFieldWarning.none ? Colors.grey : Colors.orange,
  ),
  suffixWidgetBuilder: (context, warning) => IconButton(
    icon: Icon(
      Icons.info,
      color: warning == PasswordFieldWarning.none ? Colors.grey : Colors.orange,
    ),
    onPressed: () {},
  ),
)
```

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
| `prefixWidgetBuilder` | `PasswordFieldWidgetBuilder?` | `null` | Builder for widget before the input area (receives warning state) |
| `prefixIconConstraints` | `BoxConstraints?` | `null` | Size constraints for prefix icon |
| `suffixWidgetBuilder` | `PasswordFieldWidgetBuilder?` | `null` | Builder for widget after the input area (receives warning state) |
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
| `textStyle` | `TextStyle?` | `null` | Input text style |
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
| `alignment` | `TooltipAlignment?` | `null` | Tooltip alignment override (`start`, `center`, `end`) |
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
| `interactive` | `bool?` | `true` | Keep tooltip visible on hover |
| `waitDuration` | `Duration?` | `null` | Delay before tooltip appears |
| `showDuration` | `Duration?` | `null` | Auto-hide after this duration |

## License

MIT
