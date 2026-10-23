# warning-tooltip-mode

## What it is
`WarningDisplayMode.tooltip`: caps-lock and paste warnings as two `just_tooltip`
tooltips anchored to the field, styled by `WarningTooltipTheme`.

## Governing decisions
**None.** Extracted in d734978 (#4); migrated across two breaking `just_tooltip`
releases, 0.3.0 (e143183, #8/#9) and 0.4.0 (74637ef, #10), then 0.4.2 (8375aa0, #11).

## Design model
From reading the source and `just_tooltip` 0.4.4.

- Two nested tooltips: caps-lock outside, paste inside; visibility is driven only
  from `activeStatus` (`capsLock` / `pasteBlocked`) through controllers, in a
  post-frame callback.
- `enableTap: false`, `enableHover: false`, `interactive: false` — the tooltip
  is display-only. `interactive` is fixed rather than read from the theme
  because 0.4.4's body `MouseRegion` is attached regardless of `enableHover`:
  with `interactive: true` a pointer entering the body cancels the
  `showDuration` auto-hide and `onTooltipExit` never restarts it (#19).
  `WarningTooltipTheme.interactive` stays for compatibility and is unread.
- A `pasteGeneration` change gets a new paste controller and a new `ValueKey`, so
  the tooltip rebuilds and replays.
- Controllers are not disposed: since `just_tooltip` 0.3.0, `JustTooltipController`
  holds only a target reference and a pending flag (0.4.4 `just_tooltip_controller.dart`).
  The leak fixed in 9f21d51 (#1/#5) was a 0.2.x `ChangeNotifier`.
- `WarningTooltipTheme` maps field-for-field onto `JustTooltip` /
  `JustTooltipTheme`; `tt.direction` / `tt.alignment`, when set, override the
  per-warning `WarningAlignment` mapping for **both** tooltips.
- `waitDuration` has no effect: 0.4.4 reads it only in `TooltipVisibilityScheduler.onChildEnter`, a hover event.

## Code
- `lib/src/warning_tooltip_layout.dart — WarningTooltipLayout`, `_WarningTooltipLayoutState.didUpdateWidget`, `_updateVisibility`, `_mapAlignment`, `_buildTooltipTheme`, `_buildTooltip`, `build`
- `lib/src/password_text_field_theme.dart — WarningTooltipTheme` (fields, `defaults`, `merge`, `copyWith`)
- `lib/src/password_text_field.dart — _PasswordTextFieldState._buildTooltipMode`
- Tests: `test/warning_tooltip_layout_test.dart` (nesting, no hover, replay, scroll tracking, hide when scrolled out); `test/flutter_password_input_test.dart` groups `WarningTooltipLayout`, `WarningTooltipTheme`, `warning tooltip auto-hide` (in `PasswordTextField keyboard integration`; mouse on the tooltip vs `showDuration`)

## Reference behaviour
- `just_tooltip` 0.4.4 `lib/src/tooltip_visibility_scheduler.dart` — `onChildEnter` (`waitDuration`), `startAutoHide` (`showDuration`, also started on a controller show via `just_tooltip.dart — showTooltip`), `onTooltipEnter` / `onTooltipExit` (`interactive`).
- `just_tooltip` 0.4.4 `lib/src/just_tooltip.dart — _buildOverlayEntry`: the tooltip body's `MouseRegion` is attached regardless of `enableHover`.

## Cross-cutting invariants
- [theme-defaults-cover-unwraps](../invariant/theme-defaults-cover-unwraps.md) — `_buildTooltip` / `_buildTooltipTheme` force-unwrap fields `WarningTooltipTheme.defaults` must fill.
- [warning-alignment-meaning](../invariant/warning-alignment-meaning.md) — `_mapAlignment` is one of its two sites.

## Blast radius
- [field-status](field-status.md) — the only visibility input; a status reorder changes which tooltip shows.
- [paste-blocking](paste-blocking.md) — owns `pasteGeneration`'s bumping.
- [field-theme](field-theme.md) — `PasswordTextFieldTheme.merge` nests `tooltipTheme.merge`.
- [release](release.md) — a `just_tooltip` bump has broken this twice; read the new source before raising the constraint.
- [public-surface](public-surface.md) — `TooltipDirection` / `TooltipAlignment` / `TooltipAnimation` are re-exported for this theme.

## Known holes / open
- A tooltip-placement test must first assert the tooltip **is showing**, or a coordinate assertion passes against an absent tooltip (theflow.md Step 4, maintainer, 2026-07-13).
