## 0.1.7

**feat**
- Add tooltip animation parameters to `WarningTooltipTheme`:
  - `animation`: Animation style (`none`, `fade`, `scale`, `slide`, `fadeScale`, `fadeSlide`, `rotation`)
  - `animationCurve`: Custom easing curve
  - `fadeBegin`: Starting opacity for fade animations
  - `scaleBegin`: Starting scale for scale animations
  - `slideOffset`: Slide distance ratio for slide animations
  - `rotationBegin`: Starting rotation for rotation animations
- Re-export `TooltipAnimation` enum for direct use

**deps**
- Upgrade `just_tooltip` from `^0.2.0` to `^0.2.1`

---

## 0.1.6

**feat**
- Add `interactive` option to `WarningTooltipTheme` to control whether tooltip stays visible on hover (default: true)

**deps**
- Upgrade `just_tooltip` from `^0.1.7` to `^0.2.0`
- Migrate tooltip styling parameters to new `JustTooltipTheme` API (breaking change in just_tooltip 0.2.0)

---

## 0.1.5

**feat**
- Add `WarningDisplayMode` enum (`message`, `tooltip`) to switch warning display between inline text and tooltip
- Add `warningDisplayMode` to `PasswordTextField` (default: `message`)
- Tooltip mode uses `just_tooltip` package with per-warning independent positioning via `capsLockWarningAlignment` and `pasteWarningAlignment`
- Add `WarningTooltipTheme` class for full tooltip styling customization:
  - `backgroundColor`, `borderRadius`, `padding`, `elevation`, `boxShadow`
  - `borderColor`, `borderWidth`
  - `textStyle`, `offset`, `crossAxisOffset`, `screenMargin`
  - `animationDuration`
  - `showArrow`, `arrowBaseWidth`, `arrowLength`, `arrowPositionRatio`
- Add `tooltipTheme` to `PasswordTextFieldTheme`
- Paste warning now hides when focus is lost (consistent with Caps Lock warning behavior)

**deps**
- Add `just_tooltip: ^0.1.7`

---

## 0.1.4

**feat**
- Add `WarningAlignment` enum with 6 positions (`topLeft`, `topCenter`, `topRight`, `bottomLeft`, `bottomCenter`, `bottomRight`)
- Add `capsLockWarningAlignment` and `pasteWarningAlignment` to `PasswordTextField` (default: `bottomLeft`)
- Add `pasteWarningBorderColor` to `PasswordTextFieldTheme` for independent paste warning border/text color (falls back to `errorBorderColor`)
- Paste warning now changes border color and floating label color

---

## 0.1.3

**feat**
- Add paste warning message when paste is blocked (`disablePaste: true`)
  - `showPasteWarning`: Whether to show warning (default: true)
  - `pasteWarningText`: Custom warning message (default: 'Paste is disabled')
  - `pasteWarningDuration`: Auto-hide duration (default: 3 seconds)
  - `onPasteBlocked`: Callback when paste attempt is blocked
  - Warning auto-hides when user starts typing
- Add `pasteWarningStyle` to `PasswordTextFieldTheme`

---

## 0.1.2

**feat**
- Add `disablePaste` option to block paste functionality (default: false)
  - Blocks both keyboard shortcuts (Ctrl+V/Cmd+V) and context menu paste

---

## 0.1.1

**feat**
- Add `forceEnglishInput` option to force English keyboard input when focused (default: true)
  - Windows: Disables IME when focused, re-enables when unfocused
  - macOS: Switches to English keyboard and maintains it while focused
- Add `ExcludeFocus` wrapper to visibility toggle button to prevent focus stealing

**chore**
- Add macOS platform support to example app
- Update `flutter_ime` dependency version

---

## 0.1.0

**feat**
- Add `PasswordTextField` widget with obscured text input
- Add Caps Lock detection using `flutter_ime` package (Windows, macOS supported)
- Add password visibility toggle button
- Add `prefixWidget` and `suffixWidget` support
- Add `PasswordTextFieldTheme` for comprehensive styling customization
- Add `merge()` and `copyWith()` methods for theme manipulation
- Add interactive playground example app

**docs**
- Add detailed English documentation for all public APIs
