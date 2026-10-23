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
- The monitor holds no copy of `forceEnglishInput`; the widget passes the
  current value on each focus change, so a runtime change applies on the next
  focus (monitor dartdoc).

## Code
- `lib/src/keyboard_input_monitor.dart — KeyboardInputMonitor.handleFocusGained`, `handleFocusLost`, `dispose`
- `lib/src/password_text_field.dart — _PasswordTextFieldState._onFocusChange`
- Tests: `toggles the Windows IME on focus and blur`, `cancels the macOS input-source subscription on blur`

## Reference behaviour
- `flutter_ime` 3.0.0 `lib/flutter_ime.dart — disableIME`, `enableIME`, `setEnglishKeyboard`, `onInputSourceChanged`. 3.0.0 classifies Dvorak/Colemak/British etc. as English on macOS, where 2.x saw only ABC/US (CHANGELOG 0.7.0, upstream).

## Cross-cutting invariants
**None.**

## Blast radius
- [password-field](password-field.md) — enforcement is keyed to focus transitions; a missed blur leaves the IME disabled system-wide on Windows.
- [keyboard-integration](keyboard-integration.md) — platform branching is tested only via `debugSetPlatformSupport` + `debugDefaultTargetPlatformOverride`.

## Known holes / open
- `forceEnglishInput` flipped from true to false **while focused** skips the restore in `handleFocusLost` (it returns early on the new value), leaving the Windows IME disabled / macOS subscription live until dispose. From reading; untested.
- Two fields: blur of A restores IME after focus of B disabled it? Order depends on focus listener ordering. Not investigated.
