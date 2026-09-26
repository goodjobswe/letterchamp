/// Helpers for authoring new entries in `letter_stroke_paths.dart`.
///
/// They are not part of gameplay. In debug builds the game prints the
/// checkpoints a drawn stroke would produce, which is how the existing paths
/// were made: draw the stroke on a device, then copy the printed points.
library;

import 'dart:math';
import 'dart:ui';

import 'package:letterchamp/models/stroke_validator.dart';

/// Points spaced about [spacing] apart along the stroke through [points],
/// excluding the end points.
///
/// A nearly straight stroke, one that never leaves the line between its ends
/// by more than [snapThreshold], is treated as exactly straight. Curved
/// strokes are smoothed with a Catmull-Rom spline first.
List<Offset> evenlySpacedPoints(
  List<Offset> points,
  double spacing, {
  double snapThreshold = 10.0,
}) {
  if (points.length < 2) return [];
  final Offset start = points.first;
  final Offset end = points.last;

  double maxDeviation = 0.0;
  for (int i = 1; i < points.length - 1; i++) {
    maxDeviation = max(
      maxDeviation,
      StrokeValidator.distanceToSegment(points[i], start, end),
    );
  }
  if (maxDeviation < snapThreshold) {
    final int count = max(1, ((end - start).distance / spacing).floor() - 1);
    return [
      for (int i = 1; i <= count; i++)
        Offset.lerp(start, end, i / (count + 1))!,
    ];
  }

  const int resolution = 1000;
  final List<Offset> samples = List.generate(
    resolution + 1,
    (int i) => _catmullRom(points, i / resolution),
  );
  final List<double> cumulative = [0.0];
  for (int i = 1; i < samples.length; i++) {
    cumulative.add(cumulative.last + (samples[i] - samples[i - 1]).distance);
  }
  final double totalLength = cumulative.last;
  final int count = max(1, (totalLength / spacing).floor() - 1);
  final double step = totalLength / (count + 1);

  final List<Offset> result = [];
  for (int i = 1; i <= count; i++) {
    final double target = step * i;
    int segment = 0;
    while (segment < cumulative.length - 1 &&
        cumulative[segment + 1] < target) {
      segment++;
    }
    final double segmentStart = cumulative[segment];
    final double segmentEnd = cumulative[segment + 1];
    final double t = (target - segmentStart) / (segmentEnd - segmentStart);
    result.add(Offset.lerp(samples[segment], samples[segment + 1], t)!);
  }
  return result;
}

/// A point on the Catmull-Rom spline through [points] at [t] in 0..1.
Offset _catmullRom(List<Offset> points, double t) {
  final int segments = points.length - 1;
  double local = t * segments;
  int i = local.floor();
  if (i >= segments) {
    i = segments - 1;
    local = 1.0;
  } else {
    local -= i;
  }
  final Offset p0 = i == 0 ? points[i] : points[i - 1];
  final Offset p1 = points[i];
  final Offset p2 = points[i + 1];
  final Offset p3 = (i + 2 < points.length) ? points[i + 2] : points[i + 1];
  final double u = local;
  final double u2 = u * u;
  final double u3 = u2 * u;
  final double x =
      0.5 *
      ((2 * p1.dx) +
          (-p0.dx + p2.dx) * u +
          (2 * p0.dx - 5 * p1.dx + 4 * p2.dx - p3.dx) * u2 +
          (-p0.dx + 3 * p1.dx - 3 * p2.dx + p3.dx) * u3);
  final double y =
      0.5 *
      ((2 * p1.dy) +
          (-p0.dy + p2.dy) * u +
          (2 * p0.dy - 5 * p1.dy + 4 * p2.dy - p3.dy) * u2 +
          (-p0.dy + 3 * p1.dy - 3 * p2.dy + p3.dy) * u3);
  return Offset(x, y);
}
