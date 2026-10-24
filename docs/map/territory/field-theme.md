# field-theme

## What it is
`PasswordTextFieldTheme`: every visual property of the field as a nullable
value, merged over `PasswordTextFieldTheme.defaults` at build time.

## Governing decisions
**None.** `WarningTooltipTheme.defaults` and the merge-over-defaults shape came
in 458ff66.

## Design model
From reading the source.

- `_theme` = `(widget.theme ?? const PasswordTextFieldTheme()).merge(defaults)`:
  the caller's non-null values win, field by field.
- `merge` nests: `tooltipTheme?.merge(other.tooltipTheme) ?? other.tooltipTheme`.
- Each field is listed four times — constructor, `merge`, `copyWith`, and (for
  some) `defaults` — with nothing generating them; a field missing from `merge`
  or `copyWith` is silently dropped. The same holds for `WarningTooltipTheme`.
- Neither theme defines `operator ==` / `hashCode` (grep, 2026-10-23).
- `copyWith(x: null)` cannot clear a field (`x ?? this.x`).
- Test design: a no-argument `copyWith()` that must equal the original covers
  every `?? this.x` right operand at once (lessons.md, 2026-07-13) — but with no
  `==`, that equality has to be field-by-field.
- `applies theme styles` finds the field's `SizedBox` with `.first`, because
  `IconButton` internally creates additional `SizedBox`es.

## Code
- `lib/src/password_text_field_theme.dart — PasswordTextFieldTheme` (fields, `defaults`, `merge`, `copyWith`)
- `lib/src/password_text_field.dart — _PasswordTextFieldState._theme`, `build` (colour fallbacks)
- Tests: groups `PasswordTextFieldTheme`, `WarningTooltipTheme`

## Reference behaviour
**None.**

## Cross-cutting invariants
- [theme-defaults-cover-unwraps](../invariant/theme-defaults-cover-unwraps.md)

## Blast radius
- [password-field](password-field.md) — consumes every field; a new field does nothing until wired there.
- [warning-tooltip-mode](warning-tooltip-mode.md) — the nested tooltip theme merge.
- [public-surface](public-surface.md) — both theme classes are exported; a removed or retyped field is breaking.

## Known holes / open
- theflow.md listed "equality" for this module; there is none. If `==` is added, the test must assert `identical(a, b)` is false first, because Dart canonicalises same-argument `const` (lessons.md, 2026-07-13) — and in debug/test `const` canonicalisation of widgets is disabled by creation tracking, so identity results differ from release (lessons.md).
