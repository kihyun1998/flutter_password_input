# field-status

## What it is
Folds the field's inputs — `enabled`, `hasCustomError`, caps-lock-on-while-focused,
a blocked paste, `isChecked` — into the one `PasswordFieldStatus` the rest of the
widget reads, and maps that status to border and label colours. The status is
handed to the caller's prefix/suffix builders and to the tooltip layout.

## Governing decisions
**None.** No decision record exists. The single-writer shape was introduced by
7c03f38 (#2, "Centralize field-status resolution into a single source of truth");
the enum's name is a public contract renamed from `PasswordFieldWarning` in
de934a5 (`feat!`) — see [public-surface](public-surface.md).

## Design model
From reading the source; no record states it.

- `_resolveActiveWarning` is the **only** assignment to `_activeStatus`. Event
  handlers set their own primitive (`_isCapsLockOn`, `_showPasteWarning`) and
  call it; its dartdoc says so (`password_text_field.dart — _resolveActiveWarning`).
- Priority, first match wins: `disabled > customError > capsLock > pasteBlocked >
  checked > unchecked > none`. `capsLock` additionally needs `_hasFocus` and
  `showCapsLockWarning`.
- Colours: `_statusColor` maps status → focused-border / floating-label colour;
  the **enabled** (unfocused) border only takes `customError`, `checked`,
  `unchecked` colours — caps-lock and paste colour the border only while focused.
  Fallbacks (`Colors.orange` for error, `Colors.green` for checked) are in `build`.
- `isChecked` and `hasCustomError` are documented as not meant to be combined
  (`PasswordTextField.isChecked` dartdoc); priority makes `customError` win.

## Code
- `lib/src/password_text_field.dart — PasswordFieldStatus`, `PasswordFieldWidgetBuilder`
- `lib/src/password_text_field.dart — _PasswordTextFieldState._resolveActiveWarning`, `_statusColor`, `_StatusColors`, `build` (colour record), `_buildTextField` (`enabledBorderColor`)
- `lib/src/password_text_field.dart — _PasswordTextFieldState.didUpdateWidget` (re-resolves on `enabled`, `hasCustomError`, `isChecked`)
- Tests: `test/flutter_password_input_test.dart` groups `PasswordTextField checked state`, `PasswordTextField status priority`

## Reference behaviour
**None.**

## Cross-cutting invariants
**None.**

## Blast radius
- [warning-tooltip-mode](warning-tooltip-mode.md) — it shows a tooltip only for `capsLock` / `pasteBlocked`; a reordered priority or a new status changes which tooltip appears.
- [warning-message-mode](warning-message-mode.md) — message mode does **not** read the status; a priority change here silently diverges the two modes further (see holes).
- [password-field](password-field.md) — prefix/suffix builders receive the status; a new enum value breaks callers' exhaustive switches.
- [public-surface](public-surface.md) — `PasswordFieldStatus` is exported; adding or renaming a value is a public change.
- [caps-lock-detection](caps-lock-detection.md), [paste-blocking](paste-blocking.md) — they feed primitives in; each must call `_resolveActiveWarning` after changing one, or the status goes stale.

## Known holes / open
- **The two display modes decide visibility differently** (maintainer: bug or undecided, 2026-10-23). Tooltip mode follows `_activeStatus`, so under `customError` the caps-lock tooltip hides and caps-lock and paste never show together. Message mode reads raw flags in `build` (`showCapsLockWarning && _isCapsLockOn && _hasFocus`, `_showPasteWarning`), so it shows caps-lock text during `customError` and both warnings at once.
- `didUpdateWidget` does not re-resolve when `showCapsLockWarning` changes: turning it off while caps lock is on and focused leaves `_activeStatus == capsLock` (border colour, tooltip) until the next event. From reading; no test covers it.
