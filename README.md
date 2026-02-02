# flutter_password_input

A password text field with Caps Lock detection and visibility toggle.

## Features

- Caps Lock warning when focused
- Password visibility toggle
- Force English input mode (disables IME on Windows, switches to English keyboard on macOS)
- Prefix/suffix widget support
- Theming via `PasswordTextFieldTheme`

## Install

```yaml
dependencies:
  flutter_password_input: ^0.1.1
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

### With Prefix/Suffix

```dart
PasswordTextField(
  labelText: 'Password',
  prefixWidget: Icon(Icons.lock),
  suffixWidget: IconButton(
    icon: Icon(Icons.info),
    onPressed: () {},
  ),
)
```

## License

MIT
