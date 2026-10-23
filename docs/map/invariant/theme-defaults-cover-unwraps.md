# theme-defaults-cover-unwraps

## The fact
Every theme field a consumer reads with `!` after merging over `defaults` has a
non-null value in that `defaults`.

## Why it is cross-cutting
The unwraps and the defaults sit in different files and never reference each
other; the only link is `merge(defaults)` at the call site. Two independent pairs:

- `PasswordTextFieldTheme.defaults` (`borderWidth`, `borderRadius`) ↔
  `_PasswordTextFieldState._buildOutlineBorder` (`theme.borderWidth!`, `theme.borderRadius!`).
- `WarningTooltipTheme.defaults` (`backgroundColor`, `borderRadius`, `padding`,
  `elevation`, `borderWidth`, `showArrow`, `arrowBaseWidth`, `arrowLength`,
  `arrowPositionRatio`, `interactive`, `offset`, `crossAxisOffset`, `screenMargin`,
  `animationDuration`, `animation`, `fadeBegin`, `scaleBegin`, `slideOffset`,
  `rotationBegin`) ↔ `_WarningTooltipLayoutState._buildTooltipTheme`, `_buildTooltip`.

Dropping a default, or unwrapping a field that has none, compiles and crashes at
first build for any caller who did not set it.

## Territories it holds in
- [field-theme](../territory/field-theme.md) — both `defaults`.
- [password-field](../territory/password-field.md) — `_buildOutlineBorder`.
- [warning-tooltip-mode](../territory/warning-tooltip-mode.md) — `_buildTooltipTheme`, `_buildTooltip`.

## What a violation looks like
`Null check operator used on a null value` on the first frame of a field whose
theme leaves that property unset; tests that always pass a full theme miss it.

## Discovery history
- Reading at ef67dc5 (grill-map, 2026-10-23): unwrapped set compared with `defaults` by hand — they match today.

## Where it will recur
Any new theme field passed to a non-nullable parameter (`just_tooltip`'s or
Flutter's): it needs an entry in its class's `defaults` in the same change.
Check: every `tt.<x>!` / `theme.<x>!` in `lib/src/` names a field set in the
matching `defaults`.
