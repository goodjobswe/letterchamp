import 'dart:math';
import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:letterchamp/theme/retro_theme.dart';

/// Drawing routines shared by the tracing painters.
///
/// Strokes use square caps and bevel joins, checkpoints are outlined squares
/// and the guide line is dashed, so everything reads as pixels rather than
/// marker pen.
class RetroPaint {
  RetroPaint._();

  static const double strokeWidth = 8;
  static const double guideWidth = 4;
  static const double dashOn = 10;
  static const double dashOff = 8;
  static const double endpointSize = 16;
  static const double midpointSize = 10;
  static const double outlineWidth = 2;

  static Paint _strokePaint(Color color, double width) =>
      Paint()
        ..color = color
        ..strokeWidth = width
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.square
        ..strokeJoin = StrokeJoin.bevel;

  static Path _polyline(List<Offset> points) {
    final Path path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final Offset p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    return path;
  }

  /// Draws finished strokes. A single-point stroke becomes a square dot.
  static void drawCompletedStrokes(Canvas canvas, List<List<Offset>> strokes) {
    final Paint paint = _strokePaint(RetroColors.green, strokeWidth);
    for (final List<Offset> stroke in strokes) {
      if (stroke.isEmpty) continue;
      if (stroke.length == 1) {
        canvas.drawRect(
          Rect.fromCenter(
            center: stroke.first,
            width: strokeWidth * 2,
            height: strokeWidth * 2,
          ),
          Paint()..color = RetroColors.green,
        );
      } else {
        canvas.drawPath(_polyline(stroke), paint);
      }
    }
  }

  /// Draws the stroke currently being traced.
  static void drawUserStroke(Canvas canvas, List<Offset> stroke) {
    if (stroke.isEmpty) return;
    canvas.drawPath(
      _polyline(stroke),
      _strokePaint(RetroColors.sky, strokeWidth),
    );
  }

  /// Draws the hint for one stroke: a dashed guide line that grows with
  /// [progress] from 0.0 to 1.0, then the checkpoints on top of it.
  static void drawHint(Canvas canvas, List<Offset> points, double progress) {
    if (points.isEmpty) return;

    final Path dashed = Path();
    for (final PathMetric metric in _polyline(points).computeMetrics()) {
      final double visible = metric.length * progress;
      double start = 0;
      while (start < visible) {
        final double end = min(start + dashOn, visible);
        dashed.addPath(metric.extractPath(start, end), Offset.zero);
        start += dashOn + dashOff;
      }
    }
    canvas.drawPath(
      dashed,
      Paint()
        ..color = RetroColors.amber
        ..strokeWidth = guideWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.butt,
    );

    final Paint outline =
        Paint()
          ..color = RetroColors.ink
          ..strokeWidth = outlineWidth
          ..style = PaintingStyle.stroke;
    for (int i = 0; i < points.length; i++) {
      final bool isStart = i == 0;
      final bool isEnd = i == points.length - 1;
      final Color color =
          isStart
              ? RetroColors.lime
              : (isEnd ? RetroColors.crimson : RetroColors.steel);
      final double size = (isStart || isEnd) ? endpointSize : midpointSize;
      final Rect rect = Rect.fromCenter(
        center: points[i],
        width: size,
        height: size,
      );
      canvas.drawRect(rect, Paint()..color = color);
      canvas.drawRect(rect, outline);
    }
  }
}
