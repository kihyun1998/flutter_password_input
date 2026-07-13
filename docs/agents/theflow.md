# theflow bindings (flutter_password_input)

Project-specific data for the `theflow` skill. The skill holds the portable
*method*; this file holds this package's *bindings*. Per-incident evidence lives
in [`lessons.md`](lessons.md).

`CONTEXT.md` / `docs/adr/` do **not** exist yet — created lazily when a term
actually collides or a decision is actually made. Identity lives in `CLAUDE.md`.

## Crate / module map

Single Flutter package. The barrel `lib/flutter_password_input.dart`
**re-exports `just_tooltip`**. Public surface: `PasswordTextField` +
`PasswordTextFieldTheme`.

| Module (`lib/src/`) | Role |
|---|---|
| `password_text_field.dart` | the widget — the password field, its status/caps-lock warning, the controller wiring |
| `password_text_field_theme.dart` | theme (`copyWith`, equality) |
| `keyboard_input_monitor.dart` | **`KeyboardInputMonitor`** — isolates `flutter_ime` (caps-lock / IME state) behind a seam so the widget is testable without the plugin |
| `warning_message_layout.dart` | the inline warning message |
| `warning_tooltip_layout.dart` | the warning **tooltip** (the `just_tooltip` surface) |

**Two external dependencies with wide surfaces:** `just_tooltip` (`^0.4.4`) and
`flutter_ime` (`^2.1.4`). Their *real source* is the source of truth, not pub docs.

## Step 1 — reference routing table

| Change type | Real source to read |
|---|---|
| **`just_tooltip` / `flutter_ime` behavior** | the packages' **real source** (`~/AppData/Local/Pub/Cache/hosted/pub.dev/<pkg>-<ver>/`), `grep`/`sed` — not pub docs or CHANGELOG. `just_tooltip` 0.3.0 → 0.4.0 was **two consecutive breaking migrations** (e143183, 74637ef); verify the API surface at every bump |
| **Published state** | `curl -s https://pub.dev/api/packages/flutter_password_input` |
| **Build-mode-dependent behavior** | verify in the mode that matters — `assert`-only throws do not fire in release, and `flutter test`/debug disables `const` normalization (`identical(const SizedBox(), const SizedBox())` is **false in test, true in release**). Do not freeze a build-mode-dependent proposition in a test |

## Step 2 — boundary rule

- **The widget owns** the field, its status/caps-lock warning state, and the
  tooltip/message layout. **The caller owns** the `TextEditingController` and what
  to do with the entered value.
- **`flutter_ime` is isolated behind `KeyboardInputMonitor` (6622807)** — this was
  a **contract decision** (where to draw the test seam), not a pure refactor, so
  the widget's logic is testable without the plugin. Keep IME/caps-lock reads
  behind that seam.
- **The warning tooltip is a `just_tooltip` surface** (`warning_tooltip_layout`).
  On `^0.4.4`; `interactive` and `waitDuration` have **no effect** here (bb73b06)
  — the tooltip is non-interactive display, so do not expose or rely on them.
- Naming is a contract: `PasswordFieldWarning` was renamed to
  `PasswordFieldStatus` (de934a5). A `feat!:` commit changes a public name or
  meaning — grill it before code (Step 3).

## Step 4 — proof method per layer

- **Throwaway probe** (`test/_probe_test.dart`, delete after) for real rect /
  coords / call order / **notifier lifetime** via `debugPrint`; keep the numbers
  in the issue/PR.
- **Observe at the public seam** — read the *observable fact* a widget produces,
  not its internal fields. Asserting `find.byType(X).…widget as X` field values
  makes the suite break in bulk on a refactor that changed no behavior.
- **`dispose` / leaks are not caught by widget tests — assert them explicitly.**
  A `JustTooltipController` was left undisposed and leaked a `ChangeNotifier`
  (9f21d51, #5); every passing widget test missed it. Code that creates a
  controller / notifier / listener ships a lifetime test.
- **A tooltip-placement test asserts the tooltip actually *shows* first** — else
  the coordinate assertion passes vacuously against an absent tooltip.
- **Equality tests build values at runtime and assert `identical(a, b)` is false
  *first*** — Dart normalizes same-arg `const` to one instance, so `const a ==
  const b` passes on identity even with no `operator ==`.

## Step 6 — behavior-describing surfaces

- **`CHANGELOG.md`** — pub.dev snapshots at publish; open a new version, never
  edit a published one.
- **`README.md`** — a `feat!` with an empty README diff means one of the two is
  wrong.
- **`pubspec.yaml` constraints** — `just_tooltip` broke twice in a row; when you
  raise a floor, check that the code actually needs the newer API and that
  `example/pubspec.lock` points at the same version.
- **`.pubignore`** — a present `.pubignore` disables git-based file listing
  (`.gitignore` goes dead). `coverage/lcov.info` shipped in the archive because
  `.pubignore` listed only `docs/`/`CLAUDE.md`/`build/` (305e7d3) — **any dir CI
  or a local run creates must be added to `.pubignore` explicitly.** The pub.dev
  archive cannot be un-published.
- **Glossary candidates (when `CONTEXT.md` is opened)**: *Status* vs *Warning*
  (renamed, de934a5), *active warning*, *checked*, *caps-lock monitor*. Open
  `CONTEXT.md` the moment a change touches one of their meanings.
- **Reclaim now-false rationale** across sequential work.

## Step 7 — gate matrix

`.github/workflows/ci.yml` runs on push(main) and PR, Flutter **pinned 3.41.9**:

```
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

- **Format runs after `pub get`** — `dart format` reads the language version from
  `package_config`; without it it reformats the whole repo. This failure **never
  reproduces locally** (`.dart_tool` is always present).
- **No coverage gate** (`flutter test` runs without `--coverage`, no floor) — CI
  does not do Step 5's job; a coverage regression is caught by a human. (If added,
  the floor is 100 — slack permits exactly that much regression.)
- **`analyze` has no `--fatal-infos --fatal-warnings`** — an `info`/`warning` does
  not redden CI. Do not leave a new one; nobody else catches it.
- Release: `flutter pub publish --dry-run` **0 warnings, on a clean tree**, with no
  `build/`/`coverage/`/`docs/`/`.github/` in the archive.
- **Commit `lib` + `test` paths explicitly** (never `git add -A` — a stray dep
  bump or `example/pubspec.lock` regen rides along). `Fixes #<n>` + Co-Authored-By.
  Default is direct-to-`main`; push on request (so `Fixes #n` closes at push time).
- **A tag is an immutable pointer to a commit** — tag after the docs are in; an
  *unpublished* tag is free to move (don't flee to the next version, leaving a hole).
- `flutter pub publish` is irreversible (retract only) — **the agent does not run
  it; the user does.**

## War-story index

Per-incident evidence lives in [`lessons.md`](lessons.md), indexed by step.
