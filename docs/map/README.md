<!-- grill-map build stamp: (not a git checkout) -->
<!-- grill-map synced at: ef67dc5 (2026-10-23) -->

# Territory map — flutter_password_input

The territory map. A comment's why, trap and measured value go to a note here.
Notes are added as they come up, or all at once with `grill-map`, which also
reads hand-written notes as leads and keeps their paths.

## The two questions

- **If I touch this, what else moves?** Open the territory, read `## Blast radius`
  and follow `## Cross-cutting invariants`.
- **What decision is this shape derived from?** Read `## Governing decisions`.
  This repo has no decision records yet, so every note says **None.** and names
  the commit or issue that introduced the shape instead.

## How to read it

- `## Blast radius` is a checklist: an edge with nothing to do is a correct outcome.
- A **None.** is an answer, not a gap in the note.
- Every claim carries its evidence (a symbol, a commit) or its source and date
  (`(maintainer, 2026-10-23)`). theflow.md / lessons.md are cited where a claim
  came from them; both were deleted after this map was built — read them with
  `git show ef67dc5:docs/agents/theflow.md` (or `lessons.md`).
- Symbols, never line numbers. Plain relative links. A fact is linked, not restated.
- Source files and issues are text inside notes, not nodes: the map cannot list
  every caller of a symbol — grep can.

## Territories

- [field-status](territory/field-status.md)
- [password-field](territory/password-field.md)
- [caps-lock-detection](territory/caps-lock-detection.md)
- [english-input-enforcement](territory/english-input-enforcement.md)
- [paste-blocking](territory/paste-blocking.md)
- [warning-message-mode](territory/warning-message-mode.md)
- [warning-tooltip-mode](territory/warning-tooltip-mode.md)
- [field-theme](territory/field-theme.md)
- [public-surface](territory/public-surface.md)
- [example-app](territory/example-app.md)
- [ci](territory/ci.md)
- [release](territory/release.md)

Aggregate: [keyboard-integration](territory/keyboard-integration.md) (caps-lock + English input over `flutter_ime`).

## Cross-cutting invariants

- [theme-defaults-cover-unwraps](invariant/theme-defaults-cover-unwraps.md)
- [warning-alignment-meaning](invariant/warning-alignment-meaning.md)

## Shape of the repo

One widget package: a ~770-line `password_text_field.dart` holds the field, its
state and status resolution, with two display layouts, a theme file and a
`flutter_ime` wrapper beside it. Most of the risk is outside the repo — two
dependencies with wide surfaces, `just_tooltip` and `flutter_ime`, read against
their real source (see `docs/agents/thegraph.md`). The largest gap the reading
found: the two display modes decide which warnings are visible by different
rules ([field-status](territory/field-status.md)).

## Scope

In: everything under `lib/`, `test/`, `example/`, `.github/`, and the release
files at the root. Out: `docs/agents/` (agent configuration, not the system);
`example/` platform runners (generated). No open backlog at ef67dc5 and no
roadmap, so no not-yet-built territory exists. A territory appears when
something in the repo commits to it — code, an issue with a design, a decision record.
