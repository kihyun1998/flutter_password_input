import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_ime/flutter_ime.dart' as ime;

/// Isolates all `flutter_ime` interaction — Caps Lock detection and
/// English-input (IME) enforcement — behind a narrow interface, so the widget
/// that uses it never references the plugin directly.
///
/// The monitor owns the Caps Lock and input-source stream subscriptions and
/// the per-platform branching. It is intentionally stateless about
/// `forceEnglishInput`: callers pass the current value on each focus change so
/// a runtime change is reflected on the next focus, matching the field's
/// original behavior.
///
/// Focus gating for Caps Lock is deliberately left to the caller: this monitor
/// forwards every raw stream event through [onCapsLockChanged], and the caller
/// decides whether to act on it (e.g. only while focused).
class KeyboardInputMonitor {
  KeyboardInputMonitor({required ValueChanged<bool> onCapsLockChanged})
      : _onCapsLockChanged = onCapsLockChanged {
    _capsLockSubscription = ime.onCapsLockChanged().listen(_onCapsLockChanged);
  }

  final ValueChanged<bool> _onCapsLockChanged;

  StreamSubscription<bool>? _capsLockSubscription;
  StreamSubscription<bool>? _inputSourceSubscription;

  /// Reads the current Caps Lock state.
  Future<bool> isCapsLockOn() => ime.isCapsLockOn();

  /// Enforces English input when the field gains focus.
  ///
  /// - **Windows**: disables the IME entirely.
  /// - **macOS**: switches to the English keyboard and watches the input
  ///   source, re-forcing English if the user switches away while focused.
  /// - **Other platforms**: no-op.
  void handleFocusGained({required bool forceEnglishInput}) {
    if (!forceEnglishInput) return;

    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        ime.disableIME();
        break;
      case TargetPlatform.macOS:
        ime.setEnglishKeyboard();
        _inputSourceSubscription =
            ime.onInputSourceChanged().listen((isEnglish) {
          // The subscription only exists while focused, so no focus check is
          // needed here.
          if (!isEnglish) ime.setEnglishKeyboard();
        });
        break;
      default:
        break;
    }
  }

  /// Restores normal input when the field loses focus.
  ///
  /// - **Windows**: re-enables the IME.
  /// - **macOS**: stops watching the input source.
  /// - **Other platforms**: no-op.
  void handleFocusLost({required bool forceEnglishInput}) {
    if (!forceEnglishInput) return;

    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        ime.enableIME();
        break;
      case TargetPlatform.macOS:
        _inputSourceSubscription?.cancel();
        _inputSourceSubscription = null;
        break;
      default:
        break;
    }
  }

  /// Cancels all subscriptions. Call this when the owner is disposed.
  void dispose() {
    _capsLockSubscription?.cancel();
    _inputSourceSubscription?.cancel();
  }
}
