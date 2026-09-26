import 'dart:ui';

import 'package:letterchamp/models/stroke_checkpoint.dart';

/// Decides whether a traced stroke follows an expected stroke closely enough.
///
/// All distances are in the 300 by 300 design space the letter paths are
/// authored in.
class StrokeValidator {
  StrokeValidator._();

  /// True when [stroke] passes every checkpoint of [expected] in order, each
  /// within [tolerance], and never strays more than [maxDeviation] from the
  /// straight line between two consecutive checkpoints.
  static bool matches(
    List<Offset> stroke,
    StrokeCheckpoints expected, {
    required double tolerance,
    required double maxDeviation,
  }) {
    if (stroke.isEmpty) return false;
    final List<Offset> checkpoints = expected.points;
    if ((stroke.first - checkpoints.first).distance > tolerance) return false;

    // Index into the stroke where each checkpoint was first reached.
    final List<int> hits = <int>[];
    for (
      int i = 0;
      i < stroke.length && hits.length < checkpoints.length;
      i++
    ) {
      if ((stroke[i] - checkpoints[hits.length]).distance <= tolerance) {
        hits.add(i);
      }
    }
    if (hits.length != checkpoints.length) return false;

    // Whatever is drawn after the last checkpoint must stay near it.
    for (int i = hits.last; i < stroke.length; i++) {
      if ((stroke[i] - checkpoints.last).distance > tolerance) return false;
    }

    // Between two checkpoints the stroke must stay close to the line that
    // joins them.
    for (int c = 0; c < hits.length - 1; c++) {
      for (int i = hits[c]; i <= hits[c + 1]; i++) {
        final double deviation = distanceToSegment(
          stroke[i],
          checkpoints[c],
          checkpoints[c + 1],
        );
        if (deviation > maxDeviation) return false;
      }
    }
    return true;
  }

  /// True for a stroke that is a single tap, such as the dot of an i.
  static bool isDot(StrokeCheckpoints stroke) =>
      stroke.inBetween.isEmpty && stroke.start == stroke.end;

  /// One stroke that runs through [strokes] back to back, for players who
  /// draw several expected strokes without lifting the finger.
  static StrokeCheckpoints join(List<StrokeCheckpoints> strokes) {
    final List<Offset> points = [
      for (final StrokeCheckpoints stroke in strokes) ...stroke.points,
    ];
    return StrokeCheckpoints(
      start: points.first,
      inBetween: points.sublist(1, points.length - 1),
      end: points.last,
    );
  }

  /// Length of the polyline through [points].
  static double pathLength(List<Offset> points) {
    double total = 0;
    for (int i = 1; i < points.length; i++) {
      total += (points[i] - points[i - 1]).distance;
    }
    return total;
  }

  /// Distance from [point] to the line segment between [a] and [b].
  static double distanceToSegment(Offset point, Offset a, Offset b) {
    final Offset ap = point - a;
    final Offset ab = b - a;
    final double abSquared = ab.dx * ab.dx + ab.dy * ab.dy;
    if (abSquared == 0) return ap.distance;
    final double t = ((ap.dx * ab.dx + ap.dy * ab.dy) / abSquared).clamp(
      0.0,
      1.0,
    );
    final Offset closest = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
    return (point - closest).distance;
  }
}
