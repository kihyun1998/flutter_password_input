# CLAUDE.md

## Comments

A comment says what the code is. Why it is this way, what it deliberately leaves
out, the trap and the measured value go to the territory note under `docs/map/`.
Where none seems to hold it, search the folder and the code symbol first; only
then start a new note, named for what the system does there, not for the file.
History goes to the commit message. Comments written before this rule still carry
the rest: never delete one whose content the map does not yet hold — move it
first (`decant`).

## Territory map

[`docs/map/README.md`](docs/map/README.md) is the hub. Before designing a
change, open the territories it touches and follow their `## Blast radius` and
invariant links. After it lands, update the notes it made false. When a fix
reveals a fact, ask whether it holds at every site that shares the same
assumption; if yes, the fix lands with an invariant note.

## Identity & invariants (the boundary)

`flutter_password_input` is a **password text field** with a caps-lock / status
warning surfaced two ways — a `just_tooltip` **tooltip** (`warning_tooltip_layout`)
and an inline **message** (`warning_message_layout`) — over keyboard/IME state.

- **The widget owns** the field, its status/caps-lock warning, and the
  tooltip/message layout. **The caller owns** the `TextEditingController` and the
  entered value.
- **`flutter_ime` is isolated behind `KeyboardInputMonitor`** (a deliberate test
  seam, not an accident) — IME/caps-lock reads stay behind it so the widget is
  testable without the plugin.
- **Two external dependencies with wide surfaces:** `just_tooltip` (`^0.4.4`; the
  barrel re-exports it) and `flutter_ime` (`^2.1.4`). Their **real source** is the
  source of truth, not pub docs — `just_tooltip` alone broke twice in a row across
  0.3→0.4. The warning tooltip is non-interactive display: `interactive` and
  `waitDuration` have **no effect** here.
- **Names are contracts.** `PasswordFieldWarning` → `PasswordFieldStatus` was a
  `feat!`; a public rename is grilled before code.

## Agent skills

### Issue tracker
Issues are tracked as GitHub issues in `kihyun1998/flutter_password_input`,
managed via the `gh` CLI. External PRs are not a triage surface. See
`docs/agents/issue-tracker.md`.

### Triage labels
Canonical triage roles map 1:1 to identically-named labels (`needs-triage`,
`needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`). See
`docs/agents/triage-labels.md`.

### Domain docs
Single-context layout — one `GLOSSARY.md` + `docs/adr/` at the repo root. See
`docs/agents/domain.md`.

**아직 둘 다 없다.** 용어가 실제로 충돌하거나 결정이 실제로 내려질 때 lazily 만든다 —
미리 채우지 않는다. 후보 용어: *Status* vs *Warning*, *active warning*, *checked*,
*caps-lock monitor*.
