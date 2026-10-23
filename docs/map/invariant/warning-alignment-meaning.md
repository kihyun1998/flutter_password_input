# warning-alignment-meaning

## The fact
A `WarningAlignment` value places its warning on the same side and at the same
horizontal position in message mode and tooltip mode.

## Why it is cross-cutting
Vertical side shares one primitive (`WarningMessageLayout.isTopAlignment`, used
by both). Horizontal position does not: it is mapped twice, independently —

- `WarningMessageLayout._toAlignment` (→ Flutter `Alignment`), and
- `_WarningTooltipLayoutState._mapAlignment` (→ `just_tooltip` `TooltipAlignment`).

Dart's exhaustive switches force both to handle a new value, but nothing forces
them to agree. Changing one mapping alone makes the same option mean two places
depending on display mode (maintainer confirmed the draft, 2026-10-23).

## Territories it holds in
- [warning-message-mode](../territory/warning-message-mode.md) — `_toAlignment`.
- [warning-tooltip-mode](../territory/warning-tooltip-mode.md) — `_mapAlignment`.
- [public-surface](../territory/public-surface.md) — the enum itself.

## What a violation looks like
A caller switching `warningDisplayMode` sees the warning jump sides. Note the
existing, accepted asymmetry: `*StartTargetCenter` / `*EndTargetCenter` mean
"arrow at target centre" in tooltips and collapse to left/right in text.

## Discovery history
- Reading at ef67dc5 (grill-map, 2026-10-23). The target-centre values arrived together in 7b697ef (just_tooltip 0.2.5).

## Where it will recur
Adding a `WarningAlignment` value, or a `TooltipAlignment` change upstream:
edit both mappings and both tests (`maps each alignment to its horizontal placement`,
`maps warning alignment to tooltip direction and alignment`) in one change.
