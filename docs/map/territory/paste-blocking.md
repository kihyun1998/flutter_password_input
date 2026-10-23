# paste-blocking

## What it is
With `disablePaste`, intercepts paste, calls `onPasteBlocked`, and shows a
timed "paste is disabled" warning.

## Governing decisions
**None.** Introduced in 7a09196; key-repeat suppression in 724f148.

## Design model
From reading the source.

- Interception: an `Actions` widget overriding `PasteTextIntent` wraps the
  `TextField` (`_buildTextField`).
- **Key repeat is collapsed to one block:** `_pasteKeyHeld` is set on the first
  block and cleared only by a `KeyUpEvent` for `V` seen by a global
  `HardwareKeyboard` handler (`_onHardwareKey`) (724f148).
- The warning lasts `pasteWarningDuration` (default 3 s) via `_pasteWarningTimer`,
  and is cleared early by typing (`onChanged → _hidePasteWarning`) or blur.
- In tooltip mode, a re-block while showing bumps `_pasteTooltipKey`, passed as
  `pasteGeneration`, so the tooltip replays its animation.

## Code
- `lib/src/password_text_field.dart — _PasswordTextFieldState._onPasteBlocked`, `_hidePasteWarning`, `_onHardwareKey`, `_buildTextField` (`Actions`), `_onFocusChange` (blur clears)
- Tests: group `PasswordTextField` — `calls onPasteBlocked…`, `shows default/custom paste warning…`, `hides paste warning after the specified duration`, `does not show paste warning when showPasteWarning is false`, `hides the paste warning when the user types`; `a blocked paste does not override an active customError`

## Reference behaviour
- Flutter 3.41.9 `widgets/editable_text.dart — contextMenuButtonItems`: the toolbar's paste button calls `pasteText(SelectionChangedCause.toolbar)` directly, not through `PasteTextIntent`.

## Cross-cutting invariants
**None.**

## Blast radius
- [field-status](field-status.md) — `_showPasteWarning` feeds `pasteBlocked`.
- [warning-tooltip-mode](warning-tooltip-mode.md) — `pasteGeneration` is the replay contract.
- [warning-message-mode](warning-message-mode.md) — reads `_showPasteWarning` directly.
- [password-field](password-field.md) — the `Actions` wrapper must stay an ancestor of the `TextField`.

## Known holes / open
- **Context-menu paste is probably not blocked**, though `PasswordTextField.disablePaste`'s dartdoc says it is: per the reference above the toolbar bypasses `PasteTextIntent`. From reading Flutter 3.41.9; not run. Tests only invoke the intent.
- `_pasteKeyHeld` clears only on a `V` key-up; a paste triggered by a non-V shortcut (or the key-up lost to another window) leaves it set, swallowing the next warning. From reading.
