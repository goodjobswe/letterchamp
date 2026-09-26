import 'dart:math';

/// Scoring rules shared by the game and the text that explains them.
class GameRules {
  GameRules._();

  /// Points for a correctly traced letter before the streak multiplier.
  static const int letterBonus = 10;

  /// Points lost for an incorrect stroke. A mistake also resets the streak.
  static const int strokePenalty = 2;

  /// Points a hint costs after the first free one in each game.
  static const int hintCost = 5;

  /// The multiplier grows by a fifth for every correct letter in a row and
  /// stops here.
  static const double maxStreakMultiplier = 3.0;

  /// Points awarded for a correct letter at the given streak length.
  static int bonusForStreak(int streak) {
    final double multiplier =
        1.0 + min(streak / 5.0, maxStreakMultiplier - 1.0);
    return (letterBonus * multiplier).round();
  }
}
