# english-input-enforcement

## What it is
With `forceEnglishInput` (default true), keeps the keyboard in English while the
field is focused and restores it on blur.

## Governing decisions
**None.** Part of the [keyboard-integration](keyboard-integration.md) seam
(6622807, #3). Introduced in bb07bab.

## Design model
From reading the source.

- **Windows:** `ime.disableIME()` on focus, `ime.enableIME()` on blur.
- **macOS:** `ime.setEnglishKeyboard()` on focus, plus an `onInputSourceChanged`
  subscription that re-forces English whenever the user switches away; it is
  cancelled on blur and in `dispose`.
- **Other platforms:** no-op.
- **Enforcement is tracked, restore undoes it.** The monitor keeps whether it
  is enforcing (`_enforcing`); `enforceEnglishInput` and `restoreInput` are
  no-ops when already in that state. Focus gained enforces when
  `forceEnglishInput` is set; focus lost always calls `restoreInput`, so it
  undoes what was enforced, not what the flag now says.
- **`forceEnglishInput` is a live switch while focused:** `didUpdateWidget`
  enforces or restores immediately (#18).

## Code
- `lib/src/keyboard_input_monitor.dart — KeyboardInputMonitor.enforceEnglishInput`, `restoreInput`, `dispose`
- `lib/src/password_text_field.dart — _PasswordTextFieldState._onFocusChange`, `didUpdateWidget`
- Tests: `toggles the Windows IME on focus and blur`, `re-forces the English keyboard on macOS…`, `turning forceEnglishInput off/on while focused…` (Windows ×2, macOS)

## Reference behaviour
- `flutter_ime` 3.0.0 `lib/flutter_ime.dart — disableIME`, `enableIME`, `setEnglishKeyboard`, `onInputSourceChanged`. 3.0.0 classifies Dvorak/Colemak/British etc. as English on macOS, where 2.x saw only ABC/US (CHANGELOG 0.7.0, upstream).

## Cross-cutting invariants
**None.**

## Blast radius
- [password-field](password-field.md) — enforcement is keyed to focus transitions; a missed blur leaves the IME disabled system-wide on Windows.
- [keyboard-integration](keyboard-integration.md) — platform branching is tested only via `debugSetPlatformSupport` + `debugDefaultTargetPlatformOverride`.

## Known holes / open
- Two fields: blur of A restores IME after focus of B disabled it? Order depends on focus listener ordering. Not investigated.
