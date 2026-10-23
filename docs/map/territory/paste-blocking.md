# paste-blocking

## What it is
With `disablePaste`, intercepts paste, calls `onPasteBlocked`, and shows a
timed "paste is disabled" warning.

## Governing decisions
**None.** Introduced in 7a09196; key-repeat suppression in 724f148.

## Design model
From reading the source.

- Two interception routes, one handler (`_onPasteBlocked`):
  - **keyboard:** an `Actions` widget overriding `PasteTextIntent` wraps the
    `TextField` (`_buildTextField`) and calls `_onKeyboardPasteBlocked`;
  - **context menu:** `_buildPasteBlockedContextMenu` rebuilds the
    `AdaptiveTextSelectionToolbar` from `contextMenuButtonItems` with the Paste
    item's `onPressed` replaced (#17). Used only with `disablePaste`; otherwise
    `TextField`'s own default builder (`_defaultContextMenuBuilder`).
- **The menu is always Flutter-rendered under `disablePaste`**, iOS included:
  the native `SystemContextMenu` Paste is performed by the platform and never
  reaches the field (maintainer, 2026-10-23, over keeping the native menu, which
  needs `SystemContextMenu` and a Flutter floor of 3.24).
- **Key repeat is collapsed to one block, on the keyboard route only:**
  `_pasteKeyHeld` is set when a block arrives while `V` is in
  `HardwareKeyboard.logicalKeysPressed`, and cleared by a `KeyUpEvent` for `V`
  seen by a global `HardwareKeyboard` handler (`_onHardwareKey`) (724f148). A
  block with no `V` held (macOS Edit-menu `paste:`, a stale flag after a lost
  key-up) is always reported. The context-menu route neither reads nor sets it.
- The warning lasts `pasteWarningDuration` (default 3 s) via `_pasteWarningTimer`,
  and is cleared early by typing (`onChanged → _hidePasteWarning`) or blur.
- In tooltip mode, a re-block while showing bumps `_pasteTooltipKey`, passed as
  `pasteGeneration`, so the tooltip replays its animation.

## Code
- `lib/src/password_text_field.dart — _PasswordTextFieldState._onPasteBlocked`, `_onKeyboardPasteBlocked`, `_buildPasteBlockedContextMenu`, `_defaultContextMenuBuilder`, `_hidePasteWarning`, `_onHardwareKey`, `_buildTextField` (`Actions`, `contextMenuBuilder`), `_onFocusChange` (blur clears)
- Tests: group `PasswordTextField` — `calls onPasteBlocked…`, `shows default/custom paste warning…`, `hides paste warning after the specified duration`, `does not show paste warning when showPasteWarning is false`, `hides the paste warning when the user types`; `a blocked paste does not override an active customError`; group `PasswordTextField keyboard paste repeat`; group `PasswordTextField context-menu paste` (clipboard mocked on `SystemChannels.platform`, long-press, tap "Paste")

## Reference behaviour
- Flutter 3.41.9 `widgets/editable_text.dart — contextMenuButtonItems`: the toolbar's paste button calls `pasteText(SelectionChangedCause.toolbar)` directly, not through `PasteTextIntent`. Same in 3.47.1 (`_pasteTextWithReporting`).
- Flutter 3.47.1 `material/text_field.dart — _defaultContextMenuBuilder`: shows `SystemContextMenu` when `SystemContextMenu.isSupportedByField` (iOS with `MediaQuery.supportsShowingSystemContextMenu`), since 3.38 (f16f6d7f994). `SystemContextMenu` itself is 3.24+.
- Flutter 3.47.1 `widgets/editable_text.dart — _semanticsOnPaste`: the accessibility paste action also calls `_pasteTextWithReporting` directly.

## Cross-cutting invariants
**None.**

## Blast radius
- [field-status](field-status.md) — `_showPasteWarning` feeds `pasteBlocked`.
- [warning-tooltip-mode](warning-tooltip-mode.md) — `pasteGeneration` is the replay contract.
- [warning-message-mode](warning-message-mode.md) — reads `_showPasteWarning` directly.
- [password-field](password-field.md) — the `Actions` wrapper must stay an ancestor of the `TextField`.

## Known holes / open
- **Accessibility paste is not blocked** (#20): `_semanticsOnPaste` bypasses both routes (reference above). Reproduced in a widget test on 3.47.1: `SemanticsAction.paste` on the field's node pasted the clipboard, `onPasteBlocked` 0. `pasteText` gates only on `_allowPaste` (`!readOnly` and a valid selection), so there is no hook. Maintainer's call (2026-10-23): document it and take it upstream, over `enableInteractiveSelection: false` under `disablePaste`, which removes the action but measured at: tap no longer moves the cursor, Select all gone (menu and Ctrl+A), and the semantics actions drop from `tap, moveCursorBackwardByCharacter, setSelection, paste, moveCursorBackwardByWord, setText, focus` to `tap, setText, focus`.
