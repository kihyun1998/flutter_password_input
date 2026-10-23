# CLAUDE.md

## Working discipline

Substantive changes follow `thegraph`; its build is `docs/agents/thegraph.md`.

- Commit to `main` directly; stage the touched paths by name, never `git add -A`.
  End the message with `Fixes #n`. Push only when asked.
- `flutter pub publish` is run by the maintainer, never by the agent; `--dry-run`
  must show 0 warnings on a clean tree.

## Comments

A comment says what the code is. Why it is this way, what it deliberately leaves
out, the trap and the measured value go to the territory note under `docs/map/`.
History goes to the commit message. Comments written before this rule still carry
the rest: move a comment's content into the map first (`decant`), then delete it.

## Territory map

Before designing a change, open [`docs/map/README.md`](docs/map/README.md) and
the territories it touches; follow their `## Blast radius` and invariant links.
After it lands, update the notes it made false. When a comment's why has no note,
or a fix reveals a fact, read the hub's `## Adding a note`.

## Identity & invariants (the boundary)

What the package is: [`docs/agents/thegraph.md`](docs/agents/thegraph.md).

- **The widget owns** the field, its status/caps-lock warning, and the
  tooltip/message layout. **The caller owns** the `TextEditingController` and the
  entered value.
- **In `lib/`, only `KeyboardInputMonitor` imports `flutter_ime`.** It isolates the import;
  tests reach the plugin through `FlutterImePlatform.instance`.
- **`just_tooltip` and `flutter_ime` are read from their real source** at the
  resolved version, not from pub docs. Before writing against either, read
  [`docs/agents/thegraph.md`](docs/agents/thegraph.md).
- **Names are contracts.** A public rename or meaning change is grilled before code.

## Agent skills

### Issue tracker
Issues are tracked as GitHub issues in `kihyun1998/flutter_password_input`,
managed via the `gh` CLI. External PRs are not a triage surface. See
`docs/agents/issue-tracker.md`.

### Triage labels
Canonical triage roles map 1:1 to identically-named labels. See
`docs/agents/triage-labels.md`.

### Domain docs
Single-context layout — one `GLOSSARY.md` + `docs/adr/` at the repo root. See
`docs/agents/domain.md` (candidate terms there).
