# caps-lock-detection

## What it is
Knows whether Caps Lock is on while the field is focused, drives the
`capsLock` status, and reports changes through `onCapsLockStateChanged`.

## Governing decisions
**None.** Part of the [keyboard-integration](keyboard-integration.md) seam
(6622807, #3).

## Design model
From reading the source and `flutter_ime` 3.0.0.

- On focus gained: one read through `KeyboardInputMonitor.isCapsLockOn`.
  Afterwards the stream from `ime.onCapsLockChanged()` updates it.
- **Focus gating is the widget's**, not the monitor's: the monitor forwards
  every event; `_onCapsLockChanged` drops events while unfocused
  (monitor dartdoc says so).
- On focus lost: `_isCapsLockOn` is forced false and `onCapsLockStateChanged(false)`
  fires, so the callback reads "warning shown", not "key state".
- The stream subscription is opened in the monitor's constructor — i.e. at
  `initState`, focused or not — and cancelled in `dispose`.
- **Input bound:** `flutter_ime` 3.0.0 polls caps-lock every 50 ms
  (`ffi_flutter_ime.dart — _pollInterval`) through one shared `ValuePoller`
  per process (`_capsLockPoller ??=`), so N fields cost one timer, running while
  any field is mounted.

## Code
- `lib/src/keyboard_input_monitor.dart — KeyboardInputMonitor` (constructor subscription), `isCapsLockOn`, `dispose`
- `lib/src/password_text_field.dart — _PasswordTextFieldState._onFocusChange`, `_checkCapsLockState`, `_onCapsLockChanged`, `_applyCapsLockState`
- Tests: `test/flutter_password_input_test.dart` group `PasswordTextField keyboard integration` — `reports Caps Lock changes…`, `picks up Caps Lock already on…`, `clears the Caps Lock warning and notifies false on blur`, `cancels the Caps Lock subscription on dispose`

## Reference behaviour
- `flutter_ime` 3.0.0 `lib/flutter_ime.dart — onCapsLockChanged`: emits only changes, not the starting state; empty stream on unsupported platforms; on macOS a language switch toggles the lock for ~12 ms and is reported (upstream dartdoc; also CHANGELOG 0.7.0).

## Cross-cutting invariants
**None.**

## Blast radius
- [field-status](field-status.md) — `_isCapsLockOn` is an input to the priority; changing it without `_resolveActiveWarning` leaves the status stale.
- [warning-message-mode](warning-message-mode.md) — message mode reads `_isCapsLockOn && _hasFocus` directly, not the status.
- [keyboard-integration](keyboard-integration.md) — tests reach this only through `FlutterImePlatform.instance`.

## Known holes / open
- macOS flicker on language switch is upstream behaviour this package does not filter (CHANGELOG 0.7.0: "no state that separates the two, only duration").
- `_checkCapsLockState` is async: a focus-lost before it resolves can apply a stale `true` after blur (it checks `mounted`, not `_hasFocus`). From reading; untested.
