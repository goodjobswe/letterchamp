/// Scoring rules shared by the game and the text that explains them.
class GameRules {
  GameRules._();

  /// Points a hint costs after the first free one in each game.
  static const int hintCost = 5;

  /// Points lost for an incorrect stroke.
  static const int strokePenalty = 2;
}
