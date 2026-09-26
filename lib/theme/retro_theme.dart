import 'dart:math';
import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Retro palette shared by every screen.
///
/// The values follow the Sweetie 16 pixel-art palette by GrafxKid, which sits
/// close to the colors sampled from the background art and the mascot.
class RetroColors {
  RetroColors._();

  /// Outlines and hard shadows.
  static const Color ink = Color(0xFF1A1C2C);

  /// Translucent ink for panels drawn over the background image.
  static const Color tint = Color(0xCC1A1C2C);

  /// Secondary buttons. Matches the mascot's jacket.
  static const Color slate = Color(0xFF333C57);

  /// Middle hint checkpoints.
  static const Color steel = Color(0xFF566C86);

  /// Text and borders.
  static const Color paper = Color(0xFFF4F4F4);

  /// Muted text, such as unselected options.
  static const Color mist = Color(0xFF94B0C2);

  /// Primary buttons.
  static const Color coral = Color(0xFFEF7D57);

  /// Hint guide line.
  static const Color amber = Color(0xFFFFCD75);

  /// Hint start checkpoint.
  static const Color lime = Color(0xFFA7F070);

  /// Hint end checkpoint.
  static const Color crimson = Color(0xFFB13E53);

  /// Completed strokes.
  static const Color green = Color(0xFF38B764);

  /// The stroke being traced.
  static const Color sky = Color(0xFF41A6F6);

  /// The letter drawn behind the strokes.
  static const Color letter = Color(0xFFE0E0E0);

  /// Dark overlay that tones the background art down behind the UI.
  static const Color scrim = Color(0x66000000);
}

/// Snaps logical sizes to the device pixel grid.
///
/// Pixel art only looks crisp when each drawn pixel covers a whole number of
/// device pixels. On a 420 dpi phone one logical pixel is 2.625 device pixels,
/// so unsnapped sizes smear every edge across a device pixel.
class RetroGrid {
  RetroGrid._();

  static double get devicePixelRatio =>
      PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 1.0;

  /// The logical size closest to [logical] that is a whole number of device
  /// pixels, never less than one device pixel.
  static double snap(double logical) {
    final double dpr = devicePixelRatio;
    return max(1, (logical * dpr).round()) / dpr;
  }
}

/// Text styles for the pixel font.
class RetroText {
  RetroText._();

  /// Press Start 2P is drawn on an 8 by 8 grid, so one font pixel is
  /// [fontSize] / 8 logical pixels, snapped to whole device pixels.
  static double pixel(double fontSize) => RetroGrid.snap(fontSize / 8);

  /// The font size closest to [fontSize] whose font pixels are whole device
  /// pixels.
  static double snapSize(double fontSize) => pixel(fontSize) * 8;

  /// Pixel font, optionally with a hard shadow offset by exactly one font
  /// pixel so it looks drawn with the font.
  static TextStyle style(
    double fontSize, {
    Color color = RetroColors.paper,
    bool shadow = true,
  }) {
    final double offset = pixel(fontSize);
    return GoogleFonts.pressStart2p(
      textStyle: TextStyle(
        fontSize: offset * 8,
        color: color,
        shadows:
            shadow
                ? <Shadow>[
                  Shadow(
                    color: RetroColors.ink,
                    offset: Offset(offset, offset),
                    blurRadius: 0,
                  ),
                ]
                : null,
      ),
    );
  }
}

/// Measurements and decorations for boxes: outlines and hard shadows.
class RetroBox {
  RetroBox._();

  /// Outline width.
  static const double border = 3;

  /// Hard shadow offset. Buttons slide by this much when pressed.
  static const double shadow = 4;

  static const BoxShadow hardShadow = BoxShadow(
    color: RetroColors.ink,
    offset: Offset(shadow, shadow),
    blurRadius: 0,
  );

  /// A flat panel with an outline and a hard shadow.
  static BoxDecoration panel({
    Color color = RetroColors.ink,
    Color borderColor = RetroColors.paper,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      color: color,
      border: Border.all(color: borderColor, width: border),
      boxShadow: withShadow ? const <BoxShadow>[hardShadow] : null,
    );
  }

  /// Square-cornered outline for dialogs.
  static ShapeBorder get dialogShape => const RoundedRectangleBorder(
    borderRadius: BorderRadius.zero,
    side: BorderSide(color: RetroColors.paper, width: border),
  );
}

/// App-wide Material theme so stock widgets pick up the palette.
ThemeData retroThemeData() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: RetroColors.coral,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: RetroColors.ink,
    splashFactory: NoSplash.splashFactory,
  );
}

/// A boxed message in the retro style, with room reserved for its shadow.
class RetroMessage extends StatelessWidget {
  const RetroMessage(this.message, {super.key, this.fontSize = 14});

  final String message;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Leave room on the right and bottom for the hard shadow.
      padding: const EdgeInsets.only(
        right: RetroBox.shadow,
        bottom: RetroBox.shadow,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: RetroBox.panel(),
        child: Text(message, style: RetroText.style(fontSize)),
      ),
    );
  }
}

/// A floating message box in the retro style.
SnackBar retroSnackBar(String message) {
  return SnackBar(
    backgroundColor: Colors.transparent,
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.all(16),
    padding: EdgeInsets.zero,
    content: RetroMessage(message),
  );
}

/// A flat, outlined button with a hard shadow that it sinks into when pressed.
class RetroButton extends StatefulWidget {
  const RetroButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = true,
    this.minWidth = 150,
  });

  final String label;
  final VoidCallback onPressed;

  /// Coral when true, slate when false.
  final bool primary;
  final double minWidth;

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    const double shift = RetroBox.shadow;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: widget.onPressed,
        onHighlightChanged: (bool value) => setState(() => _pressed = value),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: Padding(
          // Keep the footprint fixed while the box slides into its shadow.
          padding: EdgeInsets.fromLTRB(
            _pressed ? shift : 0,
            _pressed ? shift : 0,
            _pressed ? 0 : shift,
            _pressed ? 0 : shift,
          ),
          child: Container(
            constraints: BoxConstraints(
              minWidth: widget.minWidth,
              minHeight: 50,
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: widget.primary ? RetroColors.coral : RetroColors.slate,
              border: Border.all(
                color: RetroColors.ink,
                width: RetroBox.border,
              ),
              boxShadow:
                  _pressed ? null : const <BoxShadow>[RetroBox.hardShadow],
            ),
            child: Text(
              widget.label,
              style: RetroText.style(16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
