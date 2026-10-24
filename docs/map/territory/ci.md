# ci

## What it is
The checks that run on every push to `main` and every PR, and Dependabot's
upgrade PRs.

## Governing decisions
**None.** Added in f25f709; Dependabot in ef67dc5 (#13).

## Design model
From `.github/workflows/ci.yml` and `.github/dependabot.yml`.

- Flutter pinned (`FLUTTER_VERSION`) so CI does not drift with the runner's
  default Flutter; steps: `flutter pub get` → `dart format
  --set-exit-if-changed .` → `flutter analyze` → `flutter test`.
- **The pin matches the local toolchain** (3.47.1 at 1348584): a newer Flutter
  rewrites `analysis_options.yaml` (`analyzer.exclude` for build and platform
  directories) and `example/pubspec.lock` (SDK-pinned packages) on every
  `pub get`, so a CI on another version would not produce the committed files
  (commit 1348584, 2026-10-23). Moving the local Flutter moves the pin with it.
- **Format runs after `pub get`** because `dart format` reads the language
  version from `package_config`; without it the whole repo reformats. This never
  reproduces locally, where `.dart_tool` exists (theflow.md Step 7, maintainer, 2026-07-13).
- No coverage gate (`flutter test` without `--coverage`) and no
  `--fatal-infos/--fatal-warnings`: a new info/warning or coverage drop does not
  redden CI.
- Dependabot: weekly pub constraint bumps (`increase-if-necessary`) at the root,
  monthly grouped actions bumps.

## Code
- `.github/workflows/ci.yml`
- `.github/dependabot.yml`
- `analysis_options.yaml` (`flutter_lints`, `analyzer.exclude`)

## Reference behaviour
**None.**

## Cross-cutting invariants
**None.**

## Blast radius
- [example-app](example-app.md) — moving the Flutter pin regenerates `example/pubspec.lock`; commit them together.
- [release](release.md) — a Dependabot `just_tooltip` / `flutter_ime` PR is a dependency upgrade and needs that note's checks; green CI does not cover them.

## Known holes / open
- Infos/warnings and coverage regressions are caught only by a person.
