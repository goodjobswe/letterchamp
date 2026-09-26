import 'package:flutter_test/flutter_test.dart';
import 'package:letterchamp/data/letter_stroke_paths.dart';

void main() {
  test('every playable letter and number has a tracing path', () {
    const alphabet = 'abcdefghijklmnopqrstuvwxyzåäö';
    final characters = '$alphabet${alphabet.toUpperCase()}0123456789';
    for (final character in characters.split('')) {
      expect(letterStrokePaths[character], isNotEmpty, reason: character);
    }
  });

  test('all tracing checkpoints contain finite coordinates', () {
    for (final entry in letterStrokePaths.entries) {
      for (final stroke in entry.value) {
        for (final point in stroke.points) {
          expect(
            point.dx.isFinite && point.dy.isFinite,
            isTrue,
            reason: entry.key,
          );
        }
      }
    }
  });
}
