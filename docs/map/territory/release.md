# release

## What it is
Shipping to pub.dev: the version, SDK and dependency floors, the CHANGELOG and
README, what goes in the archive, and the dependency upgrades that drive most
releases.

## Governing decisions
**None.**

## Design model
- **Archive contents:** a present `.pubignore` disables pub's git-based listing,
  so `.gitignore` stops applying. `coverage/lcov.info` shipped for that reason
  until 305e7d3; any directory CI or a local run creates must be listed in
  `.pubignore` itself. `build/` is listed because `.gitignore` excludes only the
  root `/build/`, not `example/build/`.
- **Floors:** Dart `>=3.4.0` because `flutter_ime` 3.0.0 needs
  `NativeCallable.keepIsolateAlive` on macOS (a27fa38); Flutter `>=3.13.0` because
  `just_tooltip` 0.4.2+ walks `RenderObject.parent` and calls
  `describeApproximatePaintClip` (0.4.4 `just_tooltip.dart`), which `AbstractNode?`
  lacked before 3.13 (8375aa0). README "Requirements" gives the same reasons to
  consumers. Raising a floor is breaking for consumers.
- **Dependency upgrades:** read the new version's real source, not its
  CHANGELOG — `just_tooltip` 0.3.0 and 0.4.0 were consecutive breaking
  migrations (e143183, 74637ef). See [`docs/agents/thegraph.md`](../../agents/thegraph.md) References.
- **Release bar:** before a release, run `pub-ready`. An unpublished tag may
  move (theflow.md Step 7, maintainer, 2026-07-13).

## Code
- `pubspec.yaml`, `.pubignore`, `CHANGELOG.md`, `README.md`, `LICENSE`

## Reference behaviour
- `just_tooltip` 0.4.4 `lib/src/just_tooltip.dart` — the ancestor clip walk behind the Flutter floor.
- `flutter_ime` 3.0.0 — CHANGELOG 0.7.0 records its API as unchanged from 2.x.

## Cross-cutting invariants
**None.**

## Blast radius
- [warning-tooltip-mode](warning-tooltip-mode.md) — the `just_tooltip` surface breaks first on a bump.
- [keyboard-integration](keyboard-integration.md) — tests import `flutter_ime`'s `src/`, which a bump can move.
- [example-app](example-app.md) — its committed lockfile must follow a bump.
- [public-surface](public-surface.md) — re-exported `just_tooltip` enums make an upstream enum change ours.

## Known holes / open
**None.**
