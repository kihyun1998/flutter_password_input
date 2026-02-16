import 'package:flutter/material.dart';
import 'package:flutter_password_input/flutter_password_input.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PasswordTextField Playground',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const PlaygroundPage(),
    );
  }
}

/// Interactive playground for testing PasswordTextField widget properties.
///
/// This page provides a live preview panel and controls panel to
/// experiment with all available theme and widget options.
class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  // Theme - Size options
  double _width = 300;
  double _height = 48;
  double _borderRadius = 8;
  double _borderWidth = 1;
  double _contentPaddingH = 12;
  double _contentPaddingV = 14;

  // Theme - Color options
  Color? _backgroundColor;
  Color? _borderColor;
  Color _focusBorderColor = Colors.deepPurple;
  Color _errorBorderColor = Colors.orange;
  Color? _pasteWarningBorderColor;
  Color? _visibilityIconColor;
  double _visibilityIconSize = 20;

  // Widget behavior options
  bool _showVisibilityToggle = true;
  bool _showCapsLockWarning = true;
  bool _useFloatingLabel = true;
  bool _enabled = true;
  bool _showPrefixWidget = false;
  bool _showSuffixWidget = false;
  bool _disablePaste = false;
  bool _showPasteWarning = true;
  WarningAlignment _capsLockWarningAlignment = WarningAlignment.bottomLeft;
  WarningAlignment _pasteWarningAlignment = WarningAlignment.bottomLeft;
  WarningDisplayMode _warningDisplayMode = WarningDisplayMode.message;

  // Tooltip theme options
  Color _tooltipBgColor = const Color(0xFF616161);
  double _tooltipBorderRadius = 6;
  double _tooltipPaddingH = 12;
  double _tooltipPaddingV = 8;
  double _tooltipElevation = 4;
  double _tooltipOffset = 8;
  double _tooltipCrossAxisOffset = 0;
  bool _tooltipShowArrow = false;
  double _tooltipArrowBaseWidth = 16;
  double _tooltipArrowLength = 8;
  double _tooltipArrowPositionRatio = 0.5;
  bool _tooltipInteractive = true;
  TooltipAnimation _tooltipAnimation = TooltipAnimation.fade;
  double _tooltipFadeBegin = 0.0;
  double _tooltipScaleBegin = 0.0;
  double _tooltipSlideOffset = 0.3;
  double _tooltipRotationBegin = -0.05;

  String _capsLockWarningText = 'Caps Lock is on!';
  String _pasteWarningText = 'Paste is disabled!';
  String _labelText = 'Password';
  String _hintText = 'Enter your password';

  // Current widget state
  bool _isCapsLockOn = false;
  bool _hasFocus = false;
  String _currentValue = '';

  PasswordTextFieldTheme get _theme => PasswordTextFieldTheme(
    width: _width,
    height: _height,
    borderRadius: _borderRadius,
    borderWidth: _borderWidth,
    contentPadding: EdgeInsets.symmetric(
      horizontal: _contentPaddingH,
      vertical: _contentPaddingV,
    ),
    backgroundColor: _backgroundColor,
    borderColor: _borderColor,
    focusBorderColor: _focusBorderColor,
    errorBorderColor: _errorBorderColor,
    pasteWarningBorderColor: _pasteWarningBorderColor,
    visibilityIconColor: _visibilityIconColor,
    visibilityIconSize: _visibilityIconSize,
    tooltipTheme: WarningTooltipTheme(
      backgroundColor: _tooltipBgColor,
      borderRadius: BorderRadius.circular(_tooltipBorderRadius),
      padding: EdgeInsets.symmetric(
        horizontal: _tooltipPaddingH,
        vertical: _tooltipPaddingV,
      ),
      elevation: _tooltipElevation,
      offset: _tooltipOffset,
      crossAxisOffset: _tooltipCrossAxisOffset,
      showArrow: _tooltipShowArrow,
      arrowBaseWidth: _tooltipArrowBaseWidth,
      arrowLength: _tooltipArrowLength,
      arrowPositionRatio: _tooltipArrowPositionRatio,
      interactive: _tooltipInteractive,
      animation: _tooltipAnimation,
      fadeBegin: _tooltipFadeBegin,
      scaleBegin: _tooltipScaleBegin,
      slideOffset: _tooltipSlideOffset,
      rotationBegin: _tooltipRotationBegin,
    ),
  );

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PasswordTextField Playground'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Row(
        children: [
          // Preview panel - displays the password text field with current settings
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.grey.shade100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Preview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // IP TextField for testing IME switching
                    SizedBox(
                      width: _width,
                      height: _height,
                      child: TextField(
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _passwordFocusNode.requestFocus(),
                        decoration: InputDecoration(
                          labelText: 'IP Address (non-English test)',
                          hintText: 'Type non-English here, then move below',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(_borderRadius),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    PasswordTextField(
                      controller: _passwordController,
                      focusNode: _passwordFocusNode,
                      theme: _theme,
                      labelText: _labelText,
                      hintText: _hintText,
                      showVisibilityToggle: _showVisibilityToggle,
                      showCapsLockWarning: _showCapsLockWarning,
                      useFloatingLabel: _useFloatingLabel,
                      enabled: _enabled,
                      capsLockWarningText: _capsLockWarningText,
                      capsLockWarningAlignment: _capsLockWarningAlignment,
                      prefixWidget: _showPrefixWidget
                          ? const Padding(
                              padding: EdgeInsets.only(left: 12),
                              child: Icon(Icons.lock_outline, size: 20),
                            )
                          : null,
                      suffixWidget: _showSuffixWidget
                          ? IconButton(
                              icon: const Icon(Icons.info_outline, size: 20),
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Suffix widget pressed!'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                            )
                          : null,
                      disablePaste: _disablePaste,
                      showPasteWarning: _showPasteWarning,
                      pasteWarningText: _pasteWarningText,
                      pasteWarningAlignment: _pasteWarningAlignment,
                      warningDisplayMode: _warningDisplayMode,
                      onCapsLockStateChanged: (isCapsLockOn) {
                        setState(() => _isCapsLockOn = isCapsLockOn);
                      },
                      onFocus: () => setState(() => _hasFocus = true),
                      onLostFocus: () => setState(() => _hasFocus = false),
                      onChange: (value) {
                        setState(() => _currentValue = value);
                      },
                    ),
                    const SizedBox(height: 32),
                    // Status indicators showing current widget state
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatusRow('Focus', _hasFocus),
                          const SizedBox(height: 8),
                          _buildStatusRow('Caps Lock', _isCapsLockOn),
                          const SizedBox(height: 8),
                          Text(
                            'Value: "${_currentValue.isEmpty ? "(empty)" : _currentValue}"',
                            style: const TextStyle(fontSize: 12),
                          ),
                          Text(
                            'Length: ${_currentValue.length}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Controls panel - provides sliders, switches, and color pickers
          Expanded(
            flex: 2,
            child: FocusTraversalGroup(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: Colors.grey.shade300)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Controls',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),

                      // Theme size controls
                      _buildSectionTitle('Theme - Size'),
                      _buildSlider('Width', _width, 150, 500, (v) {
                        setState(() => _width = v);
                      }),
                      _buildSlider('Height', _height, 36, 80, (v) {
                        setState(() => _height = v);
                      }),
                      _buildSlider('Border Radius', _borderRadius, 0, 24, (v) {
                        setState(() => _borderRadius = v);
                      }),
                      _buildSlider('Border Width', _borderWidth, 0, 4, (v) {
                        setState(() => _borderWidth = v);
                      }),
                      _buildSlider('Padding H', _contentPaddingH, 0, 24, (v) {
                        setState(() => _contentPaddingH = v);
                      }),
                      _buildSlider('Padding V', _contentPaddingV, 0, 24, (v) {
                        setState(() => _contentPaddingV = v);
                      }),

                      const SizedBox(height: 16),
                      // Theme color controls
                      _buildSectionTitle('Theme - Colors'),
                      _buildNullableColorPicker(
                        'Background',
                        _backgroundColor,
                        (c) {
                          setState(() => _backgroundColor = c);
                        },
                      ),
                      _buildNullableColorPicker('Border', _borderColor, (c) {
                        setState(() => _borderColor = c);
                      }),
                      _buildColorPicker('Focus Border', _focusBorderColor, (c) {
                        setState(() => _focusBorderColor = c);
                      }),
                      _buildColorPicker('Error Border', _errorBorderColor, (c) {
                        setState(() => _errorBorderColor = c);
                      }),
                      _buildNullableColorPicker(
                        'Paste Warning Border',
                        _pasteWarningBorderColor,
                        (c) {
                          setState(() => _pasteWarningBorderColor = c);
                        },
                      ),
                      _buildNullableColorPicker(
                        'Visibility Icon',
                        _visibilityIconColor,
                        (c) {
                          setState(() => _visibilityIconColor = c);
                        },
                      ),
                      _buildSlider(
                        'Visibility Icon Size',
                        _visibilityIconSize,
                        12,
                        32,
                        (v) {
                          setState(() => _visibilityIconSize = v);
                        },
                      ),

                      const SizedBox(height: 16),
                      // Widget text controls
                      _buildSectionTitle('Widget - Text'),
                      _buildTextField('Label', _labelText, (v) {
                        setState(() => _labelText = v);
                      }),
                      _buildTextField('Hint', _hintText, (v) {
                        setState(() => _hintText = v);
                      }),
                      _buildTextField(
                        'Caps Lock Warning',
                        _capsLockWarningText,
                        (v) {
                          setState(() => _capsLockWarningText = v);
                        },
                      ),
                      _buildTextField('Paste Warning', _pasteWarningText, (v) {
                        setState(() => _pasteWarningText = v);
                      }),
                      _buildWarningAlignmentPicker(
                        'Caps Lock Warning Alignment',
                        _capsLockWarningAlignment,
                        (v) => setState(() => _capsLockWarningAlignment = v),
                      ),
                      _buildWarningAlignmentPicker(
                        'Paste Warning Alignment',
                        _pasteWarningAlignment,
                        (v) => setState(() => _pasteWarningAlignment = v),
                      ),

                      const SizedBox(height: 16),
                      _buildSectionTitle('Warning Display Mode'),
                      _buildWarningDisplayModePicker(),
                      if (_warningDisplayMode == WarningDisplayMode.tooltip)
                        ..._buildTooltipThemeControls(),

                      const SizedBox(height: 16),
                      // Widget behavior toggles
                      _buildSectionTitle('Widget - Toggles'),
                      _buildSwitch(
                        'Show Visibility Toggle',
                        _showVisibilityToggle,
                        (v) {
                          setState(() => _showVisibilityToggle = v);
                        },
                      ),
                      _buildSwitch(
                        'Show Caps Lock Warning',
                        _showCapsLockWarning,
                        (v) {
                          setState(() => _showCapsLockWarning = v);
                        },
                      ),
                      _buildSwitch('Use Floating Label', _useFloatingLabel, (
                        v,
                      ) {
                        setState(() => _useFloatingLabel = v);
                      }),
                      _buildSwitch('Enabled', _enabled, (v) {
                        setState(() => _enabled = v);
                      }),
                      _buildSwitch('Disable Paste', _disablePaste, (v) {
                        setState(() => _disablePaste = v);
                      }),
                      _buildSwitch('Show Paste Warning', _showPasteWarning, (
                        v,
                      ) {
                        setState(() => _showPasteWarning = v);
                      }),

                      const SizedBox(height: 16),
                      // Prefix/suffix widget toggles
                      _buildSectionTitle('Widget - Prefix/Suffix'),
                      _buildSwitch('Show Prefix Widget', _showPrefixWidget, (
                        v,
                      ) {
                        setState(() => _showPrefixWidget = v);
                      }),
                      _buildSwitch('Show Suffix Widget', _showSuffixWidget, (
                        v,
                      ) {
                        setState(() => _showSuffixWidget = v);
                      }),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            _passwordController.clear();
                            setState(() => _currentValue = '');
                          },
                          child: const Text('Clear Password'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a status indicator row with a colored dot and label.
  Widget _buildStatusRow(String label, bool value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: value ? Colors.green : Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ${value ? "ON" : "OFF"}',
          style: TextStyle(
            fontSize: 12,
            color: value ? Colors.green : Colors.grey,
            fontWeight: value ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  /// Builds tooltip theme controls shown when tooltip mode is active.
  List<Widget> _buildTooltipThemeControls() {
    return [
      const SizedBox(height: 8),
      _buildSectionTitle('Tooltip Theme'),
      _buildColorPicker('Tooltip Background', _tooltipBgColor, (c) {
        setState(() => _tooltipBgColor = c);
      }),
      _buildSlider('Tooltip Border Radius', _tooltipBorderRadius, 0, 20, (v) {
        setState(() => _tooltipBorderRadius = v);
      }),
      _buildSlider('Tooltip Padding H', _tooltipPaddingH, 0, 24, (v) {
        setState(() => _tooltipPaddingH = v);
      }),
      _buildSlider('Tooltip Padding V', _tooltipPaddingV, 0, 24, (v) {
        setState(() => _tooltipPaddingV = v);
      }),
      _buildSlider('Tooltip Elevation', _tooltipElevation, 0, 16, (v) {
        setState(() => _tooltipElevation = v);
      }),
      _buildSlider('Tooltip Offset', _tooltipOffset, 0, 24, (v) {
        setState(() => _tooltipOffset = v);
      }),
      _buildSlider('Tooltip Cross Offset', _tooltipCrossAxisOffset, -20, 20, (
        v,
      ) {
        setState(() => _tooltipCrossAxisOffset = v);
      }),
      _buildSwitch('Interactive', _tooltipInteractive, (v) {
        setState(() => _tooltipInteractive = v);
      }),
      _buildTooltipAnimationPicker(),
      if (_tooltipAnimation == TooltipAnimation.fade ||
          _tooltipAnimation == TooltipAnimation.fadeScale ||
          _tooltipAnimation == TooltipAnimation.fadeSlide)
        _buildSlider('Fade Begin', _tooltipFadeBegin, 0, 1, (v) {
          setState(() => _tooltipFadeBegin = v);
        }),
      if (_tooltipAnimation == TooltipAnimation.scale ||
          _tooltipAnimation == TooltipAnimation.fadeScale)
        _buildSlider('Scale Begin', _tooltipScaleBegin, 0, 1, (v) {
          setState(() => _tooltipScaleBegin = v);
        }),
      if (_tooltipAnimation == TooltipAnimation.slide ||
          _tooltipAnimation == TooltipAnimation.fadeSlide)
        _buildSlider('Slide Offset', _tooltipSlideOffset, 0, 1, (v) {
          setState(() => _tooltipSlideOffset = v);
        }),
      if (_tooltipAnimation == TooltipAnimation.rotation)
        _buildSlider('Rotation Begin', _tooltipRotationBegin, -0.25, 0.25, (v) {
          setState(() => _tooltipRotationBegin = v);
        }),
      _buildSwitch('Show Arrow', _tooltipShowArrow, (v) {
        setState(() => _tooltipShowArrow = v);
      }),
      if (_tooltipShowArrow) ...[
        _buildSlider('Arrow Base Width', _tooltipArrowBaseWidth, 4, 32, (v) {
          setState(() => _tooltipArrowBaseWidth = v);
        }),
        _buildSlider('Arrow Length', _tooltipArrowLength, 2, 20, (v) {
          setState(() => _tooltipArrowLength = v);
        }),
        _buildSlider('Arrow Position Ratio', _tooltipArrowPositionRatio, 0, 1, (
          v,
        ) {
          setState(() => _tooltipArrowPositionRatio = v);
        }),
      ],
    ];
  }

  /// Builds a section title with consistent styling.
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.deepPurple,
        ),
      ),
    );
  }

  /// Builds a labeled slider control.
  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 12),
        ),
        Slider(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }

  /// Builds a labeled switch toggle.
  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile(
      title: Text(label, style: const TextStyle(fontSize: 13)),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }

  /// Builds a labeled text input field.
  Widget _buildTextField(
    String label,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: TextEditingController(text: value),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          border: const OutlineInputBorder(),
        ),
        style: const TextStyle(fontSize: 13),
        onChanged: onChanged,
      ),
    );
  }

  /// Builds a dropdown picker for [TooltipAnimation].
  Widget _buildTooltipAnimationPicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Text('Animation', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<TooltipAnimation>(
              value: _tooltipAnimation,
              isExpanded: true,
              isDense: true,
              style: const TextStyle(fontSize: 12, color: Colors.black),
              items: TooltipAnimation.values
                  .map((a) => DropdownMenuItem(value: a, child: Text(a.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _tooltipAnimation = v);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a toggle for [WarningDisplayMode].
  Widget _buildWarningDisplayModePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: WarningDisplayMode.values.map((mode) {
          final isSelected = _warningDisplayMode == mode;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: ChoiceChip(
                label: Text(mode.name),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _warningDisplayMode = mode);
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds a dropdown picker for [WarningAlignment].
  Widget _buildWarningAlignmentPicker(
    String label,
    WarningAlignment value,
    ValueChanged<WarningAlignment> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<WarningAlignment>(
              value: value,
              isExpanded: true,
              isDense: true,
              style: const TextStyle(fontSize: 12, color: Colors.black),
              items: WarningAlignment.values
                  .map((a) => DropdownMenuItem(value: a, child: Text(a.name)))
                  .toList(),
              onChanged: (v) {
                if (v != null) onChanged(v);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a color picker with predefined color options.
  Widget _buildColorPicker(
    String label,
    Color value,
    ValueChanged<Color> onChanged,
  ) {
    final colors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.red,
      Colors.pink,
      Colors.teal,
      Colors.grey,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          children: colors.map((color) {
            final isSelected = value == color;
            return GestureDetector(
              onTap: () => onChanged(color),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: isSelected
                      ? Border.all(color: Colors.black, width: 2)
                      : null,
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// Builds a nullable color picker that includes a "none" option.
  Widget _buildNullableColorPicker(
    String label,
    Color? value,
    ValueChanged<Color?> onChanged,
  ) {
    final colors = <Color?>[
      null,
      Colors.white,
      Colors.grey.shade200,
      Colors.grey.shade400,
      Colors.deepPurple.shade50,
      Colors.blue.shade50,
      Colors.orange.shade50,
      Colors.red.shade50,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${value == null ? "None" : "Custom"}',
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          children: colors.map((color) {
            final isSelected = value == color;
            return GestureDetector(
              onTap: () => onChanged(color),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color ?? Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: color == null
                    ? Icon(Icons.block, color: Colors.grey.shade400, size: 16)
                    : isSelected
                    ? const Icon(Icons.check, color: Colors.black, size: 16)
                    : null,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
