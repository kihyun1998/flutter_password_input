# password-field

## What it is
The `TextField` itself: obscured entry with a visibility toggle, the caller's
prefix/suffix builders, disabled styling, label/hint, and ownership of the
`FocusNode` and `TextEditingController`.

## Governing decisions
**None.** The ownership split (caller owns the controller and the value) is
stated in `CLAUDE.md` "Identity & invariants", not in a record. The
builder-based prefix/suffix replaced widget slots in c886a00 (`feat!`).

## Design model
From reading the source.

- **Controller:** passed straight through as `TextField.controller`; when null,
  `TextField` creates its own. The widget never reads the value — only
  `onChange` / `onSubmitted` forward it.
- **FocusNode:** the widget creates one when `focusNode` is null and disposes
  only that one (`dispose` checks `widget.focusNode == null`). On a swap,
  `didUpdateWidget` moves the listener to the new node at once, then in a
  post-frame callback disposes the old node if the widget created it and runs
  `_onFocusChange` to reconcile, so caps-lock state and IME enforcement follow
  the new node (#18). Post-frame, because the `TextField` must have moved off
  the old node before it is disposed, and focus callbacks (`onLostFocus`,
  `onCapsLockStateChanged`) must not run during a build.
- **Visibility toggle** is wrapped in `ExcludeFocus` so tapping it does not steal
  focus (which would clear caps-lock and paste state, see
  [caps-lock-detection](caps-lock-detection.md)); it is inert when `enabled == false`.
- Suffix composition: builder widget first, then the toggle, in a `Row`.
- `autofocus` is also re-requested in a post-frame callback in `initState`.

## Code
- `lib/src/password_text_field.dart — PasswordTextField` (constructor, fields)
- `lib/src/password_text_field.dart — _PasswordTextFieldState.initState`, `didUpdateWidget`, `dispose`, `_toggleObscure`, `_buildSuffixIcon`, `_buildTextField`, `_buildOutlineBorder`
- Tests: `test/flutter_password_input_test.dart` group `PasswordTextField` (render, toggle, callbacks, builders); `rewires focus when the external focusNode is replaced`, group `focusNode ownership` (disposal observed via `FlutterMemoryAllocations`), `autofocus requests focus after the first frame`

## Reference behaviour
**None.**

## Cross-cutting invariants
- [theme-defaults-cover-unwraps](../invariant/theme-defaults-cover-unwraps.md) — `_buildOutlineBorder` force-unwraps `borderWidth` / `borderRadius`.

## Blast radius
- [field-status](field-status.md) — focus is an input to the status; a focus-handling change can leave `_hasFocus` out of step with the node.
- [caps-lock-detection](caps-lock-detection.md), [english-input-enforcement](english-input-enforcement.md) — both hang off `_onFocusChange`; anything that changes when focus is gained or lost changes when IME is disabled/restored.
- [paste-blocking](paste-blocking.md) — the `Actions` wrapper sits around this `TextField`; replacing the field's widget tree can drop it.
- [field-theme](field-theme.md) — every style here comes from the merged theme.

## Known holes / open
**None.**
