import 'package:flutter/material.dart';

/// Defines the expected checkpoints for a single stroke.
class StrokeCheckpoints {
  final Offset start;
  final List<Offset> inBetween;
  final Offset end;

  const StrokeCheckpoints({
    required this.start,
    required this.inBetween,
    required this.end,
  });

  /// Returns the full list of checkpoints in order.
  List<Offset> get points => [start, ...inBetween, end];
}
