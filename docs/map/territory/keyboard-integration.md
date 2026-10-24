# Aggregate — keyboard integration

**This note owns no detail.** Two concepts that share one module and one
external plugin, `flutter_ime`.

| Concept | Note |
|---|---|
| Caps Lock on/off while focused → `capsLock` status | [caps-lock-detection](caps-lock-detection.md) |
| Keep the keyboard English while focused | [english-input-enforcement](english-input-enforcement.md) |

## Why they sit together
Both live in `KeyboardInputMonitor`, the only file that imports `flutter_ime`
(`grep -rl flutter_ime lib/` → `keyboard_input_monitor.dart`), and both are
driven from the same `_onFocusChange`. Neither reads the other's state.

## The seam is the plugin's platform interface, not the monitor
`KeyboardInputMonitor` isolates the **import**: the widget never names
`flutter_ime` (6622807, #3). It is not an injection point —
`_PasswordTextFieldState.initState` constructs it directly
(maintainer, 2026-10-23: "monitor is import isolation, the seam is the platform
interface").

Tests drive both concepts by replacing `FlutterImePlatform.instance` with
`_FakeImePlatform`, forcing platform policy through `debugSetPlatformSupport`
with a `_ForceSupport` subclass of `PlatformSupport`, and setting
`debugDefaultTargetPlatformOverride` for the Windows/macOS branches
(`test/flutter_password_input_test.dart`). The override is reset before the test
body ends: flutter_test asserts foundation debug vars are unset at that point,
before `tearDown` runs. `PlatformSupport` is imported from
`package:flutter_ime/src/platform_support.dart` under
`// ignore: implementation_imports` — a private path a `flutter_ime` release may
move without a major bump. CHANGELOG 0.7.0 says these tests passed unchanged
across 2.x → 3.0.0 through this seam.
