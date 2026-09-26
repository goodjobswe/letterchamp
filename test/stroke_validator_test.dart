import 'package:flutter_test/flutter_test.dart';
import 'package:letterchamp/models/game_rules.dart';
import 'package:letterchamp/models/stroke_checkpoint.dart';
import 'package:letterchamp/models/stroke_validator.dart';

void main() {
  // The first stroke of the letter A: from the apex down to the left foot.
  const StrokeCheckpoints leftLeg = StrokeCheckpoints(
    start: Offset(150, 55),
    inBetween: [Offset(113.5, 149)],
    end: Offset(77, 243),
  );

  List<Offset> line(Offset from, Offset to, {int steps = 20}) => [
    for (int i = 0; i <= steps; i++) Offset.lerp(from, to, i / steps)!,
  ];

  bool accepted(List<Offset> stroke, StrokeCheckpoints expected) =>
      StrokeValidator.matches(
        stroke,
        expected,
        tolerance: 20,
        maxDeviation: 20,
      );

  group('StrokeValidator.matches', () {
    test('accepts a stroke along the checkpoints', () {
      expect(accepted(line(leftLeg.start, leftLeg.end), leftLeg), isTrue);
    });

    test('rejects a stroke drawn in the wrong direction', () {
      expect(accepted(line(leftLeg.end, leftLeg.start), leftLeg), isFalse);
    });

    test('rejects a stroke that misses the middle checkpoint', () {
      const Offset detour = Offset(200, 150);
      final List<Offset> stroke = [
        ...line(leftLeg.start, detour, steps: 10),
        ...line(detour, leftLeg.end, steps: 10),
      ];
      expect(accepted(stroke, leftLeg), isFalse);
    });

    test('rejects a stroke that stops early', () {
      final List<Offset> stroke = line(leftLeg.start, leftLeg.inBetween.first);
      expect(accepted(stroke, leftLeg), isFalse);
    });

    test('rejects an empty stroke', () {
      expect(accepted(const [], leftLeg), isFalse);
    });
  });

  test('join runs strokes back to back', () {
    const StrokeCheckpoints second = StrokeCheckpoints(
      start: Offset(77, 243),
      inBetween: [],
      end: Offset(200, 243),
    );
    final StrokeCheckpoints joined = StrokeValidator.join([leftLeg, second]);
    expect(joined.points, [...leftLeg.points, ...second.points]);
  });

  test('a single tap counts as a dot stroke', () {
    const StrokeCheckpoints dot = StrokeCheckpoints(
      start: Offset(150, 60),
      inBetween: [],
      end: Offset(150, 60),
    );
    expect(StrokeValidator.isDot(dot), isTrue);
    expect(StrokeValidator.isDot(leftLeg), isFalse);
  });

  test('the streak bonus grows and then caps', () {
    expect(GameRules.bonusForStreak(1), 12);
    expect(GameRules.bonusForStreak(5), 20);
    expect(GameRules.bonusForStreak(10), 30);
    expect(GameRules.bonusForStreak(50), 30);
  });
}
