import 'package:flutter/material.dart';
import 'package:letterchamp/theme/retro_theme.dart';

/// A monochrome bitmap glyph, one string per row: '#' is a pixel, '.' a gap.
class PixelGlyph {
  const PixelGlyph(this.rows);

  final List<String> rows;

  int get width => rows.first.length;
  int get height => rows.length;

  static const PixelGlyph arrowLeft = PixelGlyph(<String>[
    '...#....',
    '..##....',
    '.#######',
    '########',
    '.#######',
    '..##....',
    '...#....',
  ]);

  static const PixelGlyph question = PixelGlyph(<String>[
    '.#####.',
    '##...##',
    '##...##',
    '....##.',
    '...##..',
    '...##..',
    '.......',
    '...##..',
  ]);
}

/// Draws a [PixelGlyph] with square cells snapped to the device pixel grid,
/// optionally with a hard shadow one cell down and right.
class PixelIcon extends StatelessWidget {
  const PixelIcon(
    this.glyph, {
    super.key,
    this.cell = 4,
    this.color = RetroColors.paper,
    this.shadow = true,
  });

  final PixelGlyph glyph;

  /// Logical size of one glyph pixel before snapping.
  final double cell;
  final Color color;
  final bool shadow;

  @override
  Widget build(BuildContext context) {
    final double c = RetroGrid.snap(cell);
    final double extra = shadow ? c : 0;
    return CustomPaint(
      size: Size(glyph.width * c + extra, glyph.height * c + extra),
      painter: _PixelGlyphPainter(glyph, c, color, shadow),
    );
  }
}

class _PixelGlyphPainter extends CustomPainter {
  const _PixelGlyphPainter(this.glyph, this.cell, this.color, this.shadow);

  final PixelGlyph glyph;
  final double cell;
  final Color color;
  final bool shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path();
    for (int y = 0; y < glyph.rows.length; y++) {
      final String row = glyph.rows[y];
      for (int x = 0; x < row.length; x++) {
        if (row[x] == '#') {
          path.addRect(Rect.fromLTWH(x * cell, y * cell, cell, cell));
        }
      }
    }
    if (shadow) {
      canvas.drawPath(
        path.shift(Offset(cell, cell)),
        Paint()
          ..color = RetroColors.ink
          ..isAntiAlias = false,
      );
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..isAntiAlias = false,
    );
  }

  @override
  bool shouldRepaint(_PixelGlyphPainter old) =>
      old.glyph != glyph ||
      old.cell != cell ||
      old.color != color ||
      old.shadow != shadow;
}

/// An icon button drawn from a [PixelGlyph]. Sinks into its shadow when pressed.
class RetroIconButton extends StatefulWidget {
  const RetroIconButton({
    super.key,
    required this.glyph,
    required this.onPressed,
    this.tooltip,
  });

  final PixelGlyph glyph;
  final VoidCallback onPressed;
  final String? tooltip;

  @override
  State<RetroIconButton> createState() => _RetroIconButtonState();
}

class _RetroIconButtonState extends State<RetroIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final double c = RetroGrid.snap(4);
    Widget button = Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: widget.onPressed,
        onHighlightChanged: (bool value) => setState(() => _pressed = value),
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Padding(
            // Shift by one cell when pressed; the shadow cell is dropped so
            // the footprint stays the same.
            padding: EdgeInsets.only(
              left: _pressed ? c : 0,
              top: _pressed ? c : 0,
            ),
            child: PixelIcon(widget.glyph, shadow: !_pressed),
          ),
        ),
      ),
    );
    if (widget.tooltip != null) {
      button = Tooltip(message: widget.tooltip!, child: button);
    }
    return Semantics(button: true, label: widget.tooltip, child: button);
  }
}

/// An on/off switch drawn as a boxed track with a square knob. No animation:
/// the knob jumps, like a hardware switch.
class RetroToggle extends StatelessWidget {
  const RetroToggle({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      toggled: value,
      button: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => onChanged(!value),
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          child: Padding(
            // Room for the hard shadow.
            padding: const EdgeInsets.only(
              right: RetroBox.shadow,
              bottom: RetroBox.shadow,
            ),
            child: Container(
              width: 64,
              height: 32,
              decoration: BoxDecoration(
                color: value ? RetroColors.coral : RetroColors.slate,
                border: Border.all(
                  color: RetroColors.ink,
                  width: RetroBox.border,
                ),
                boxShadow: const <BoxShadow>[RetroBox.hardShadow],
              ),
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                margin: const EdgeInsets.all(3),
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: RetroColors.paper,
                  border: Border.all(color: RetroColors.ink, width: 2),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One entry in a [RetroChoice].
class RetroOption<T> {
  const RetroOption(this.value, this.label);

  final T value;
  final String label;
}

/// A menu-style list of options with a cursor on the selected one. Every
/// option is visible and tappable, so nothing pops up.
class RetroChoice<T> extends StatelessWidget {
  const RetroChoice({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final T value;
  final List<RetroOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: RetroColors.tint,
        border: Border.all(color: RetroColors.paper, width: 2),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: <Widget>[
            for (final RetroOption<T> option in options)
              _RetroChoiceRow(
                label: option.label,
                selected: option.value == value,
                onTap: () => onChanged(option.value),
              ),
          ],
        ),
      ),
    );
  }
}

class _RetroChoiceRow extends StatelessWidget {
  const _RetroChoiceRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        focusColor: Colors.transparent,
        child: Container(
          color: selected ? RetroColors.slate : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 28,
                child: Text(
                  selected ? '>' : '',
                  style: RetroText.style(
                    14,
                    color: RetroColors.coral,
                    shadow: false,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  label,
                  style: RetroText.style(
                    14,
                    color: selected ? RetroColors.paper : RetroColors.mist,
                    shadow: false,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The sunset artwork with a dark overlay, which every screen is drawn on.
class RetroBackground extends StatelessWidget {
  const RetroBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.asset('assets/images/game_bg.png', fit: BoxFit.cover),
        const ColoredBox(color: RetroColors.scrim),
        child,
      ],
    );
  }
}

/// A loading indicator: four boxes lighting up in turn, stepped, not eased.
class RetroLoader extends StatefulWidget {
  const RetroLoader({super.key});

  @override
  State<RetroLoader> createState() => _RetroLoaderState();
}

class _RetroLoaderState extends State<RetroLoader>
    with SingleTickerProviderStateMixin {
  static const int _boxes = 4;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (BuildContext context, Widget? child) {
          final int active = (_controller.value * _boxes).floor() % _boxes;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int i = 0; i < _boxes; i++)
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: i == active ? RetroColors.coral : RetroColors.slate,
                    border: Border.all(color: RetroColors.ink, width: 2),
                    boxShadow: const <BoxShadow>[RetroBox.hardShadow],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
