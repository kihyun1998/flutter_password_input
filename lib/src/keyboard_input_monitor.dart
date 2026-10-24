import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_ime/flutter_ime.dart' as ime;

/// Isolates all `flutter_ime` interaction — Caps Lock detection and
/// English-input (IME) enforcement — behind a narrow interface.
///
/// The monitor owns the Caps Lock and input-source stream subscriptions and
/// the per-platform branching. It tracks whether English input is currently
/// enforced, so [restoreInput] undoes exactly what [enforceEnglishInput] did.
///
/// Forwards every raw Caps Lock event through [onCapsLockChanged]; focus gating
/// is deliberately the caller's (docs/map/territory/caps-lock-detection.md).
class KeyboardInputMonitor {
  KeyboardInputMonitor({required ValueChanged<bool> onCapsLockChanged})
      : _onCapsLockChanged = onCapsLockChanged {
    _capsLockSubscription = ime.onCapsLockChanged().listen(_onCapsLockChanged);
  }

  final ValueChanged<bool> _onCapsLockChanged;

  StreamSubscription<bool>? _capsLockSubscription;
  StreamSubscription<bool>? _inputSourceSubscription;
  bool _enforcing = false;

  /// Reads the current Caps Lock state.
  Future<bool> isCapsLockOn() => ime.isCapsLockOn();

  /// Enforces English input. A no-op while already enforcing.
  ///
  /// - **Windows**: disables the IME entirely.
  /// - **macOS**: switches to the English keyboard and watches the input
  ///   source, re-forcing English if the user switches away.
  /// - **Other platforms**: no-op.
  void enforceEnglishInput() {
    if (_enforcing) return;
    _enforcing = true;

    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
        ime.disableIME();
        break;
      case TargetPlatform.macOS:
        ime.setEnglishKeyboard();
        _inputSourceSubscription =
            ime.onInputSourceChanged().listen((isEnglish) {
          if (!isEnglish) ime.setEnglishKeyboard();
        });
        break;
      default:
        break;
    }
  }

  /// Undoes [enforceEnglishInput]. A no-op while not enforcing.
  ///
  /// - **Windows**: re-enables the IME.
  /// - **macOS**: stops watching the input source.
  /// - **Other platforms**: no-op.
  void restoreInput() {
    if (!_enforcing) return;
    _enforcing = false;

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

  /// Restores input if still enforcing and cancels all subscriptions. Call
  /// this when the owner is disposed.
  void dispose() {
    restoreInput();
    _capsLockSubscription?.cancel();
    _inputSourceSubscription?.cancel();
  }
}
