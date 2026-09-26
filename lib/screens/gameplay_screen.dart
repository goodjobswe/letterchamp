import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:letterchamp/data/letter_stroke_paths.dart';
import 'package:letterchamp/data/stroke_path_tools.dart';
import 'package:letterchamp/models/game_rules.dart';
import 'package:letterchamp/models/stroke_checkpoint.dart';
import 'package:letterchamp/models/stroke_validator.dart';
import 'package:letterchamp/services/settings_service.dart';
import 'package:letterchamp/services/sound_effects_manager.dart';
import 'package:letterchamp/theme/retro_theme.dart';
import 'package:letterchamp/theme/retro_widgets.dart';
import 'package:letterchamp/widgets/tracing_canvas.dart';

/// The game: trace letters in the chosen order, earn points and streaks,
/// and buy hints with points.
class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  State<GameplayScreen> createState() => _GameplayScreenState();
}

class _GameplayScreenState extends State<GameplayScreen>
    with SingleTickerProviderStateMixin {
  /// How close, in design units, a stroke must pass each checkpoint.
  static const double _tolerance = 30;

  /// Strokes shorter than this are treated as accidental touches.
  static const double _minStrokeLength = 20;

  /// A dot stroke is accepted when the tap lands this close to it.
  static const double _dotTolerance = 20;

  /// Players may draw up to this many expected strokes without lifting the
  /// finger, for example a whole E in one go.
  static const int _maxJoinedStrokes = 4;

  static const List<String> _cheersEn = [
    "Great job!",
    "Awesome work!",
    "Fantastic!",
    "Brilliant!",
    "Well done!",
    "Superb!",
    "Excellent!",
    "Keep it up!",
    "Outstanding!",
    "You're on fire!",
  ];
  static const List<String> _cheersSv = [
    'Bra jobbat!',
    'Fantastiskt!',
    'Strålande!',
    'Utmärkt!',
    'Toppen!',
    'Suveränt!',
    'Jättebra!',
    'Fortsätt så!',
    'Enastående!',
    'Du är grym!',
  ];

  /// Short openers; the line after them already says "Try again!".
  static const List<String> _missesEn = [
    'Oops!',
    'Not quite!',
    'Almost!',
    'So close!',
    'Whoops!',
    "That one didn't count.",
  ];
  static const List<String> _missesSv = [
    'Oj!',
    'Inte riktigt!',
    'Nästan!',
    'Nära!',
    'Hoppsan!',
    'Den räknades inte.',
  ];

  final SettingsService _settingsService = SettingsService();
  final Random _random = Random();
  late final AnimationController _hintAnimation = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  /// Captured early so the message box can be hidden while disposing.
  late ScaffoldMessengerState _messenger;

  bool _loading = true;
  String _language = 'en';
  List<String> _letters = [];
  int _letterIndex = 0;

  List<Offset> _userStroke = [];
  final List<List<Offset>> _completedStrokes = [];
  int _strokeIndex = 0;

  int _score = 0;
  int _streak = 0;
  bool _freeHintUsed = false;
  bool _highScoreAnnounced = false;
  bool _showHint = false;

  bool get _swedish => _language == 'sv';
  String get _letter => _letters[_letterIndex];
  List<StrokeCheckpoints> get _strokes => letterStrokePaths[_letter]!;

  /// True from the last accepted stroke until the next letter is shown.
  bool get _letterComplete => _strokeIndex >= _strokes.length;

  @override
  void initState() {
    super.initState();
    _loadSettingsAndLetters();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _messenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    _hintAnimation.dispose();
    _messenger.hideCurrentSnackBar();
    super.dispose();
  }

  /// Builds the list of characters to practice from the settings, then
  /// greets the player.
  Future<void> _loadSettingsAndLetters() async {
    final String language = await _settingsService.getLanguage();
    final String gameMode = await _settingsService.getGameMode();
    final String letterOrder = await _settingsService.getLetterOrder();
    final bool numbersEnabled = await _settingsService.getNumbersEnabled();
    SoundEffectsManager().enabled =
        await _settingsService.getSoundEffectsEnabled();

    final List<String> characters = 'abcdefghijklmnopqrstuvwxyz'.split('');
    if (language == 'sv') characters.addAll(['å', 'ä', 'ö']);
    if (numbersEnabled) characters.addAll('0123456789'.split(''));
    if (letterOrder == 'random') characters.shuffle(_random);
    final List<String> letters = [
      for (final String character in characters)
        switch (gameMode) {
          'uppercase' => character.toUpperCase(),
          'lowercase' => character.toLowerCase(),
          _ =>
            _random.nextBool()
                ? character.toUpperCase()
                : character.toLowerCase(),
        },
    ];

    if (!mounted) return;
    setState(() {
      _language = language;
      _letters = letters;
      _loading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoundEffectsManager().play(SoundEffect.start);
      _showMessage(
        _swedish
            ? 'Nu kör vi! Rita din första bokstav!'
            : "Let's go! Draw your first letter!",
      );
    });
  }

  void _nextLetter() {
    setState(() {
      _letterIndex = (_letterIndex + 1) % _letters.length;
      _strokeIndex = 0;
      _completedStrokes.clear();
      _userStroke = [];
    });
  }

  void _showMessage(String message) {
    _messenger.hideCurrentSnackBar();
    _messenger.showSnackBar(retroSnackBar(message));
  }

  /// Animates the hint once and hides it again after [duration].
  void _showHintFor(Duration duration) {
    setState(() => _showHint = true);
    _hintAnimation.forward(from: 0);
    Future.delayed(duration, () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  /// The first hint in a game is free; later ones cost points.
  void _requestHint() {
    if (!_freeHintUsed) {
      _freeHintUsed = true;
      _showMessage(
        _swedish
            ? 'Den här hjälpen är gratis. Nästa kostar ${GameRules.hintCost} poäng.'
            : 'This hint is free. The next one costs ${GameRules.hintCost} points.',
      );
      _showHintFor(const Duration(seconds: 2));
    } else if (_score >= GameRules.hintCost) {
      setState(() => _score -= GameRules.hintCost);
      _showMessage(
        _swedish
            ? 'Hjälpen kostade ${GameRules.hintCost} poäng.'
            : 'That hint cost ${GameRules.hintCost} points.',
      );
      _showHintFor(const Duration(seconds: 1));
    } else {
      _showMessage(
        _swedish
            ? 'Du behöver ${GameRules.hintCost} poäng för att få hjälp.'
            : 'You need ${GameRules.hintCost} points for a hint.',
      );
    }
  }

  /// Decides what the stroke just drawn was worth and moves the game on.
  Future<void> _evaluateStroke() async {
    if (kDebugMode) {
      // For authoring new letter paths: the checkpoints this stroke gives.
      debugPrint('Checkpoints: ${evenlySpacedPoints(_userStroke, 35)}');
    }
    final StrokeCheckpoints expected = _strokes[_strokeIndex];
    if (_isAccidental(expected)) {
      setState(() => _userStroke = []);
      return;
    }
    final int strokesMatched = _countMatchedStrokes(expected);
    if (strokesMatched == 0) {
      _rejectStroke();
    } else {
      await _acceptStroke(strokesMatched);
    }
  }

  /// A touch too small to be an attempt, ignored without penalty.
  bool _isAccidental(StrokeCheckpoints expected) {
    if (_userStroke.isEmpty) return true;
    if (StrokeValidator.isDot(expected)) {
      return (_userStroke.first - expected.start).distance > _dotTolerance;
    }
    return StrokeValidator.pathLength(_userStroke) < _minStrokeLength;
  }

  /// How many expected strokes, starting with the current one, the drawn
  /// stroke covers: one for a plain match, more when the player joined
  /// several strokes without lifting the finger, zero when it matches none.
  int _countMatchedStrokes(StrokeCheckpoints expected) {
    if (StrokeValidator.isDot(expected)) return 1;
    if (StrokeValidator.matches(
      _userStroke,
      expected,
      tolerance: _tolerance,
      maxDeviation: _tolerance,
    )) {
      return 1;
    }
    for (int count = 2; count <= _maxJoinedStrokes; count++) {
      if (_strokeIndex + count > _strokes.length) break;
      final StrokeCheckpoints joined = StrokeValidator.join(
        _strokes.sublist(_strokeIndex, _strokeIndex + count),
      );
      // A longer joined stroke gets a little more slack.
      if (StrokeValidator.matches(
        _userStroke,
        joined,
        tolerance: _tolerance,
        maxDeviation: 40.0 + 5.0 * count,
      )) {
        return count;
      }
    }
    return 0;
  }

  void _rejectStroke() {
    SoundEffectsManager().play(SoundEffect.fail);
    _streak = 0;
    setState(() {
      _score -= GameRules.strokePenalty;
      _userStroke = [];
    });
    final String opener =
        _swedish
            ? _missesSv[_random.nextInt(_missesSv.length)]
            : _missesEn[_random.nextInt(_missesEn.length)];
    _showMessage(
      _swedish
          ? '$opener Du förlorade ${GameRules.strokePenalty} poäng. Försök igen!'
          : '$opener You lost ${GameRules.strokePenalty} points. Try again!',
    );
  }

  /// Keeps the stroke and, when it finishes the letter, scores it and moves
  /// on after a short pause.
  Future<void> _acceptStroke(int strokesMatched) async {
    _completedStrokes.add(List.of(_userStroke));
    setState(() {
      _userStroke = [];
      _strokeIndex += strokesMatched;
    });
    if (!_letterComplete) {
      SoundEffectsManager().play(SoundEffect.success);
      return;
    }

    SoundEffectsManager().play(SoundEffect.complete);
    final int previousHighScore = await _settingsService.getHighScore();
    final int previousLongestStreak = await _settingsService.getHighestStreak();
    if (!mounted) return;
    _streak++;
    final int bonus = GameRules.bonusForStreak(_streak);
    setState(() => _score += bonus);

    final bool newHighScore = _score > previousHighScore;
    if (newHighScore) await _settingsService.setHighScore(_score);
    if (_streak > previousLongestStreak) {
      await _settingsService.setHighestStreak(_streak);
    }
    _showMessage(
      _cheer(bonus, announceRecord: newHighScore && !_highScoreAnnounced),
    );
    if (newHighScore) _highScoreAnnounced = true;

    // Leave the finished letter on screen for a moment.
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    _nextLetter();
  }

  String _cheer(int bonus, {required bool announceRecord}) {
    final String opener =
        _swedish
            ? _cheersSv[_random.nextInt(_cheersSv.length)]
            : _cheersEn[_random.nextInt(_cheersEn.length)];
    final String streak =
        _streak > 1
            ? (_swedish ? ' $_streak rätt i rad!' : ' $_streak in a row!')
            : '';
    final String record =
        announceRecord ? (_swedish ? ' Nytt rekord!' : ' New high score!') : '';
    return _swedish
        ? '$opener Du fick $bonus poäng.$streak$record'
        : '$opener You earned $bonus points.$streak$record';
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: RetroBackground(child: Center(child: RetroLoader())),
      );
    }

    final bool digit = RegExp(r'^\d$').hasMatch(_letter);
    final String title =
        _swedish
            ? (digit ? 'Siffra: $_letter' : 'Bokstav: $_letter')
            : (digit ? 'Number: $_letter' : 'Letter: $_letter');

    return Scaffold(
      body: RetroBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: RetroIconButton(
                    glyph: PixelGlyph.arrowLeft,
                    tooltip: _swedish ? 'Huvudmeny' : 'Main Menu',
                    onPressed: () {
                      SoundEffectsManager().play(SoundEffect.click);
                      Navigator.pop(context);
                    },
                  ),
                  centerTitle: true,
                  title: Text(title, style: RetroText.style(16)),
                  actions: [
                    RetroIconButton(
                      glyph: PixelGlyph.question,
                      tooltip: _swedish ? 'Hjälp' : 'Hint',
                      onPressed: () {
                        SoundEffectsManager().play(SoundEffect.click);
                        _requestHint();
                      },
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    _swedish ? 'Poäng: $_score' : 'Score: $_score',
                    style: RetroText.style(20),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: TracingCanvas(
                    letter: _letter,
                    hint: _letterComplete ? null : _strokes[_strokeIndex],
                    showHint: _showHint,
                    hintAnimation: _hintAnimation,
                    userStroke: _userStroke,
                    completedStrokes: _completedStrokes,
                    acceptsInput: !_letterComplete,
                    onStrokeStart:
                        (Offset point) => setState(() {
                          _userStroke = [point];
                          _showHint = false;
                        }),
                    onStrokeUpdate:
                        (Offset point) =>
                            setState(() => _userStroke.add(point)),
                    onStrokeEnd: _evaluateStroke,
                  ),
                ),
                // Room for the floating message box.
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
