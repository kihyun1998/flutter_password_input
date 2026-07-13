# CLAUDE.md

## Working discipline — theflow

Substantive changes (bug fix / feature / behavior change) follow the **`theflow`**
skill — run `/theflow` at the start. This repo's bindings (module map, reference
routing, boundary rule, proof methods, surfaces, gate matrix) live in
**`docs/agents/theflow.md`**; the per-incident evidence in
**`docs/agents/lessons.md`**. Read both before starting; add new war-stories to
lessons.

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
Single-context layout — one `CONTEXT.md` + `docs/adr/` at the repo root. See
`docs/agents/domain.md`.

**아직 둘 다 없다.** 용어가 실제로 충돌하거나 결정이 실제로 내려질 때 lazily 만든다 —
미리 채우지 않는다. 후보 용어: *Status* vs *Warning*, *active warning*, *checked*,
*caps-lock monitor* (`docs/agents/theflow.md` Step 6 참조).
