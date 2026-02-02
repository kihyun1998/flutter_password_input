## 0.1.1

**feat**
- Add `forceEnglishInput` option to force English keyboard input when focused (default: true)
  - Windows: Disables IME when focused, re-enables when unfocused
  - macOS: Switches to English keyboard and maintains it while focused
- Add `ExcludeFocus` wrapper to visibility toggle button to prevent focus stealing

**chore**
- Add macOS platform support to example app
- Update `flutter_ime` dependency version

---

## 0.1.0

**feat**
- Add `PasswordTextField` widget with obscured text input
- Add Caps Lock detection using `flutter_ime` package (Windows, macOS supported)
- Add password visibility toggle button
- Add `prefixWidget` and `suffixWidget` support
- Add `PasswordTextFieldTheme` for comprehensive styling customization
- Add `merge()` and `copyWith()` methods for theme manipulation
- Add interactive playground example app

**docs**
- Add detailed English documentation for all public APIs
