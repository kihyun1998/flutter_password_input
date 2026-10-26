# warning-tooltip-mode

## What it is
`WarningDisplayMode.tooltip`: caps-lock and paste warnings as two `just_tooltip`
tooltips anchored to the field, styled by `WarningTooltipTheme`.

## Governing decisions
**None.** Extracted in d734978 (#4); migrated across two breaking `just_tooltip`
releases, 0.3.0 (e143183, #8/#9) and 0.4.0 (74637ef, #10), then 0.4.2 (8375aa0, #11)
and 0.5.1 (`deps/just-tooltip-0.5.1`; maintainer, 2026-10-26, for the semantics
and floor calls below).

## Design model
From reading the source and `just_tooltip` 0.5.1.

- Two nested tooltips: caps-lock outside, paste inside; visibility is driven only
  from `activeStatus` (`capsLock` / `pasteBlocked`) through controllers, in a
  post-frame callback.
- `just_tooltip` 0.4.0 lets a nested tooltip suppress its ancestors, but only a
  tooltip with `enableHover` (or, since 0.5.1, `enableFocus`) claims its
  ancestors, and only a claimed ancestor is suppressed. Both tooltips here leave
  both off, so the inner one never claims and the suppression path is
  unreachable; suppression gates only the trigger path, so a programmatic
  `controller.show()` on the outer one always wins. The tests guard the nesting order and `enableHover: false`
  for this reason (`test/warning_tooltip_layout_test.dart` header).
- Both warnings are shown through a controller with hover disabled, so they inherit
  `just_tooltip`'s visible-part anchoring and re-aiming (Reference behaviour) wholesale.
- No `tap` (null with `enableTap` unset is `TooltipTap.none`; `enableTap` is
  deprecated since 0.5.0 and its info fails `flutter analyze`),
  `enableHover: false`, `interactive: false` — the tooltip is display-only.
  `interactive` is fixed rather than read from the theme because the body
  `MouseRegion` is attached regardless of `enableHover`, under an
  `IgnorePointer` only when `interactive` is false: with `interactive: true` a
  pointer entering the body cancels the `showDuration` auto-hide and
  `onTooltipExit` never restarts it without `enableHover` (#19).
  `WarningTooltipTheme.interactive` stays for compatibility and is unread.
- `excludeFromSemantics: true` on both. 0.5.1 puts a tooltip's text on its
  child's semantics node whether or not it is shown, the innermost heard one
  winning; both messages are always non-empty, so the field would be read as
  the paste warning at all times (measured: with status `none`, a node carrying
  `tooltip: "PASTE BLOCKED"`). The accepted cost is the show-time
  `SemanticsService.tooltip` announcement, which `_show` makes only for a heard
  tooltip (maintainer, 2026-10-26). The bubble's own text is on the semantics
  tree while it is shown.
- Escape closes the most recently shown tooltip (0.5.1, `_handleKey`). Focus is
  in the field, inside both tooltips' child, so the press is left to
  `_DismissTooltipAction`, which consumes it: an enclosing `DismissIntent`
  action (a dialog) runs only on the next press. `_dismissed` gates only the
  trigger path, and `_updateVisibility` calls `controller.show()` on every
  `build`, so the warning comes back on the next rebuild of
  `WarningTooltipLayout` once the hide animation has finished; a rebuild during
  it does not (`_show` returns while `_isShowing`). With no rebuild it stays
  hidden while the status holds. Measured in widget tests on this branch
  (paste via `PasteTextIntent`, `pasteWarningDuration` 30 s): hidden after
  Escape and still 10 s later; shown again after a parent `setState`; shown
  again by a new blocked paste. Not acted on (maintainer, 2026-10-26).
- A `pasteGeneration` change gets a new paste controller and a new `ValueKey`, so
  the tooltip rebuilds and replays.
- Controllers are not disposed: since `just_tooltip` 0.3.0, `JustTooltipController`
  holds only a target reference and a pending flag (0.5.1 `just_tooltip_controller.dart`).
  The leak fixed in 9f21d51 (#1/#5) was a 0.2.x `ChangeNotifier`.
- `WarningTooltipLayout` keeps the controller lifecycle, so the field widget
  (`password_text_field.dart`) does not reference `just_tooltip` at all.
- `WarningTooltipTheme` maps field-for-field onto `JustTooltip` /
  `JustTooltipTheme`, except `interactive` (above); `tt.direction` /
  `tt.alignment`, when set, override the per-warning `WarningAlignment` mapping
  for **both** tooltips.
- `waitDuration` has no effect: 0.5.1 reads it only in `TooltipVisibilityScheduler.onChildEnter`, reached from a hover or keyboard-focus trigger, neither enabled here.

## Code
- `lib/src/warning_tooltip_layout.dart — WarningTooltipLayout`, `_WarningTooltipLayoutState.didUpdateWidget`, `_updateVisibility`, `_mapAlignment`, `_buildTooltipTheme`, `_buildTooltip`, `build`
- `lib/src/password_text_field_theme.dart — WarningTooltipTheme` (fields, `defaults`, `merge`, `copyWith`)
- `lib/src/password_text_field.dart — _PasswordTextFieldState._buildTooltipMode`
- Tests: `test/warning_tooltip_layout_test.dart` (nesting, no hover or tap, not on the semantics tree, replay, scroll tracking, hide when scrolled out); `test/flutter_password_input_test.dart` groups `WarningTooltipLayout`, `WarningTooltipTheme`, `warning tooltip auto-hide` (in `PasswordTextField keyboard integration`; mouse on the tooltip vs `showDuration`)

## Reference behaviour
- `just_tooltip` 0.5.1 `lib/src/tooltip_visibility_scheduler.dart` — `onChildEnter` (`waitDuration`), `startAutoHide` (`showDuration`, also started on a controller show via `just_tooltip.dart — showTooltip`), `onTooltipEnter` / `onTooltipExit` (`interactive`).
- `just_tooltip` 0.5.1 `lib/src/just_tooltip.dart — _buildOverlayChild`: the tooltip body's `MouseRegion` is attached regardless of `enableHover`, inside `IgnorePointer(ignoring: !interactive)`.
- `just_tooltip` 0.5.1 `lib/src/just_tooltip.dart — _syncSuppression`: claims ancestors only while `_pointerInside` (set only by the child `MouseRegion` built under `enableHover`) or under `enableFocus` with keyboard focus inside.
- `just_tooltip` 0.5.1 `lib/src/just_tooltip.dart — _semanticText`, `_SemanticTooltip`, `_show`: the child's semantics tooltip and the show-time announcement, both off under `excludeFromSemantics`.
- `just_tooltip` 0.5.1 `lib/src/just_tooltip.dart — _handleKey`, `_dismissByUser`, `_DismissTooltipAction`: Escape.
- `just_tooltip` 0.5.1 `lib/src/just_tooltip.dart` — the target a tooltip is positioned against is the visible part of its child (since 0.4.2), positioned during layout so it follows the child in the same frame (since 0.5.0).

## Cross-cutting invariants
- [theme-defaults-cover-unwraps](../invariant/theme-defaults-cover-unwraps.md) — `_buildTooltip` / `_buildTooltipTheme` force-unwrap fields `WarningTooltipTheme.defaults` must fill.
- [warning-alignment-meaning](../invariant/warning-alignment-meaning.md) — `_mapAlignment` is one of its two sites.

## Blast radius
- [field-status](field-status.md) — the only visibility input; a status reorder changes which tooltip shows.
- [paste-blocking](paste-blocking.md) — owns `pasteGeneration`'s bumping.
- [field-theme](field-theme.md) — `PasswordTextFieldTheme.merge` nests `tooltipTheme.merge`.
- [release](release.md) — a `just_tooltip` bump has broken this three times (0.3.0, 0.4.0, 0.5.0's deprecation and floor); read the new source before raising the constraint.
- [public-surface](public-surface.md) — `TooltipDirection` / `TooltipAlignment` / `TooltipAnimation` are re-exported for this theme.

## Known holes / open
- A tooltip-placement test must first assert the tooltip **is showing**, or a coordinate assertion passes against an absent tooltip (theflow.md Step 4, maintainer, 2026-07-13).
