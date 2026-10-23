# warning-message-mode

## What it is
`WarningDisplayMode.message` (the default): caps-lock and paste warnings as
inline text above or below the field.

## Governing decisions
**None.** Extracted into its own widget in d734978 (#4).

## Design model
From reading the source.

- The layout is told *which* warnings to show (a nullable `WarningMessage` each);
  the field decides, the layout only places.
- Top-aligned warnings go above, others below; within a side, caps-lock comes
  before paste. Both can show at once.
- Horizontal placement: `_toAlignment`; `*StartTargetCenter` / `*EndTargetCenter`
  collapse to left/right here (there is no target arrow in text).

## Code
- `lib/src/warning_message_layout.dart — WarningMessage`, `WarningMessageLayout.isTopAlignment`, `_toAlignment`, `build`
- `lib/src/password_text_field.dart — _PasswordTextFieldState._buildMessageMode`, `build` (`showCapsLockWarning`)
- Tests: group `WarningMessageLayout`

## Reference behaviour
**None.**

## Cross-cutting invariants
- [warning-alignment-meaning](../invariant/warning-alignment-meaning.md) — `_toAlignment` is one of its two sites.

## Blast radius
- [warning-tooltip-mode](warning-tooltip-mode.md) — it borrows `isTopAlignment` for direction; changing the top/bottom split moves tooltips too.
- [public-surface](public-surface.md) — `WarningAlignment` is public; a new value must be handled here.

## Known holes / open
- Visibility comes from raw flags, not `_activeStatus` — the mode divergence recorded in [field-status](field-status.md).
