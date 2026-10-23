# public-surface

## What it is
What a consumer can import: the barrel's exports, including three re-exported
`just_tooltip` enums. Names here are contracts.

## Governing decisions
**None.** "Names are contracts" is stated in `CLAUDE.md`; the precedent is
de934a5 (`PasswordFieldWarning` → `PasswordFieldStatus`, `feat!`).

## Design model
- The barrel exports `password_text_field.dart` and `password_text_field_theme.dart`
  whole, and `just_tooltip`'s `TooltipAlignment`, `TooltipAnimation`,
  `TooltipDirection` only (`lib/flutter_password_input.dart`) — these three, not the package.
- Hence public: `PasswordTextField`, `WarningAlignment`, `PasswordFieldStatus`,
  `PasswordFieldWidgetBuilder`, `WarningDisplayMode`, `PasswordTextFieldTheme`,
  `WarningTooltipTheme`. `KeyboardInputMonitor`, `WarningMessageLayout`,
  `WarningTooltipLayout` are under `src/` and not exported (tests import them by path).
- Because `just_tooltip` enums are re-exported, a rename or value change upstream
  is a breaking change **of this package**.
- A public rename or meaning change is grilled before code (`CLAUDE.md`).

## Code
- `lib/flutter_password_input.dart`
- the exported declarations listed above

## Reference behaviour
- `just_tooltip` 0.4.4 `lib/src/enums.dart` — the re-exported enums.

## Cross-cutting invariants
- [warning-alignment-meaning](../invariant/warning-alignment-meaning.md) — `WarningAlignment`'s values are its subject.

## Blast radius
- [release](release.md) — any change here decides the version bump and a CHANGELOG entry.
- [example-app](example-app.md) — uses the public API; a rename breaks it.
- [warning-tooltip-mode](warning-tooltip-mode.md), [warning-message-mode](warning-message-mode.md) — a new `WarningAlignment` value needs both mappings.
- [field-status](field-status.md) — a new `PasswordFieldStatus` value needs a priority slot and a colour.

## Known holes / open
**None.**
