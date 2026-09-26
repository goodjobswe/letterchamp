import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letterchamp/models/stroke_checkpoint.dart';
import 'package:letterchamp/theme/retro_paint.dart';
import 'package:letterchamp/theme/retro_theme.dart';

/// The surface a letter is traced on.
///
/// Letter paths are authored in a square design space of [designSize] units.
/// The canvas scales that space to fit its box and converts pointer positions
/// back into design units before handing them to the callbacks, so screens
/// never deal with screen coordinates.
class TracingCanvas extends StatelessWidget {
  const TracingCanvas({
    super.key,
    required this.letter,
    required this.hint,
    required this.showHint,
    required this.hintAnimation,
    required this.userStroke,
    required this.completedStrokes,
    required this.acceptsInput,
    required this.onStrokeStart,
    required this.onStrokeUpdate,
    required this.onStrokeEnd,
  });

  /// Side of the square design space the letter paths are authored in.
  static const double designSize = 300;

  final String letter;

  /// The stroke a hint would show, or null when the letter is finished.
  final StrokeCheckpoints? hint;
  final bool showHint;

  /// Drives the hint's dashed line from nothing to the full stroke.
  final Animation<double> hintAnimation;

  final List<Offset> userStroke;
  final List<List<Offset>> completedStrokes;

  /// While false, touches are ignored, for example when a finished letter is
  /// left on screen for a moment.
  final bool acceptsInput;

  /// Called with positions in design units.
  final ValueChanged<Offset> onStrokeStart;
  final ValueChanged<Offset> onStrokeUpdate;
  final VoidCallback onStrokeEnd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double scale =
            min(constraints.maxWidth, constraints.maxHeight) / designSize;
        final Offset origin = Offset(
          (constraints.maxWidth - designSize * scale) / 2,
          (constraints.maxHeight - designSize * scale) / 2,
        );
        Offset toDesign(Offset local) => (local - origin) / scale;

        return GestureDetector(
          onPanStart: (DragStartDetails details) {
            if (acceptsInput) onStrokeStart(toDesign(details.localPosition));
          },
          onPanUpdate: (DragUpdateDetails details) {
            if (acceptsInput) onStrokeUpdate(toDesign(details.localPosition));
          },
          onPanEnd: (DragEndDetails details) {
            if (acceptsInput) onStrokeEnd();
          },
          child: AnimatedBuilder(
            animation: hintAnimation,
            builder: (BuildContext context, Widget? child) {
              return CustomPaint(
                size: Size(constraints.maxWidth, constraints.maxHeight),
                painter: TracingPainter(
                  letter: letter,
                  hint: showHint ? hint : null,
                  hintProgress: hintAnimation.value,
                  userStroke: userStroke,
                  completedStrokes: completedStrokes,
                  scale: scale,
                  origin: origin,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// Paints the letter, the finished strokes, the hint and the stroke in
/// progress, in that order, inside the scaled design space.
class TracingPainter extends CustomPainter {
  const TracingPainter({
    required this.letter,
    required this.hint,
    required this.hintProgress,
    required this.userStroke,
    required this.completedStrokes,
    required this.scale,
    required this.origin,
  });

  final String letter;
  final StrokeCheckpoints? hint;
  final double hintProgress;
  final List<Offset> userStroke;
  final List<List<Offset>> completedStrokes;
  final double scale;
  final Offset origin;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(origin.dx, origin.dy);
    canvas.scale(scale, scale);

    final TextPainter glyph = TextPainter(
      text: TextSpan(
        text: letter,
        style: GoogleFonts.poppins(
          fontSize: TracingCanvas.designSize,
          color: RetroColors.letter,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    glyph.paint(
      canvas,
      Offset(
        (TracingCanvas.designSize - glyph.width) / 2,
        (TracingCanvas.designSize - glyph.height) / 2,
      ),
    );

    RetroPaint.drawCompletedStrokes(canvas, completedStrokes);
    if (hint != null) {
      RetroPaint.drawHint(canvas, hint!.points, hintProgress);
    }
    RetroPaint.drawUserStroke(canvas, userStroke);
    canvas.restore();
  }

  // The stroke lists are mutated in place while tracing, so repaint always.
  @override
  bool shouldRepaint(TracingPainter oldDelegate) => true;
}
