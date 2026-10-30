# CLAUDE.md

## Working discipline

Substantive changes follow `thegraph`. Before designing one, or writing against
`just_tooltip` / `flutter_ime`, read its build
[`docs/agents/thegraph.md`](docs/agents/thegraph.md).

- Commit to `main` directly; stage the touched paths by name, never `git add -A`.
  End the message with `Fixes #n`. Push only when asked.
- Before a release, run `pub-ready`, and read
  [`docs/map/territory/release.md`](docs/map/territory/release.md).

## Comments

A comment says what the code is. Why it is this way, what it deliberately leaves
out, the trap and the measured value go to the territory note under `docs/map/`.
Where none seems to hold it, search the folder and the code symbol first; only
then start a new note, named for what the system does there, not for the file.
History goes to the commit message. Comments written before this rule still
carry the rest: never delete one whose content the map does not yet hold — move
it there first (`decant`).

## Territory map

Before designing a change, open [`docs/map/README.md`](docs/map/README.md) and
the territories it touches; follow their `## Blast radius` and invariant links.
After it lands, update the notes it made false. When a comment's why has no note,
or a fix reveals a fact, read the hub's `## Adding a note`.

## Identity & invariants (the boundary)

- **The widget owns** the field, its status/caps-lock warning, and the
  tooltip/message layout. **The caller owns** the `TextEditingController` and the
  entered value.
- **In `lib/`, only `KeyboardInputMonitor` imports `flutter_ime`.**
- **`just_tooltip` and `flutter_ime` are read from their real source** at the
  resolved version, not from pub docs.
- **Names are contracts.** A public rename or meaning change is grilled before code.

## Agent skills

### Issue tracker
GitHub issues in this repo. See `docs/agents/issue-tracker.md`.

### Triage labels
Canonical triage roles map 1:1 to identically-named labels. See
`docs/agents/triage-labels.md`.

### Domain docs
Single-context layout. See `docs/agents/domain.md`.
