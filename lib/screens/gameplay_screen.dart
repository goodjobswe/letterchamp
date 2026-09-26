import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letterchamp/models/game_rules.dart';
import 'package:letterchamp/models/stroke_checkpoint.dart';
import 'package:letterchamp/services/settings_service.dart';
import 'package:letterchamp/data/letter_stroke_paths.dart';
import 'package:letterchamp/services/sound_effects_manager.dart';
import 'package:letterchamp/theme/retro_paint.dart';
import 'package:letterchamp/theme/retro_theme.dart';
import 'package:letterchamp/theme/retro_widgets.dart';

class GameplayScreen extends StatefulWidget {
  const GameplayScreen({super.key});

  @override
  GameplayScreenState createState() => GameplayScreenState();
}

class GameplayScreenState extends State<GameplayScreen>
    with SingleTickerProviderStateMixin {
  // Settings service.
  final SettingsService settingsService = SettingsService();

  List<String> _letters = [];
  bool _isLoading = true;
  int _currentLetterIndex = 0;
  String? letter; // Current letter to trace.
  String _language = "en"; // default language
  bool _firstHelpUsed = false;
  bool _soundEffectsEnabled = false;
  bool _hasDisplayedHighScoreMessage = false;

  // Tracing variables.
  List<Offset> _userStroke = [];
  final List<List<Offset>> _completedStrokes = [];
  int currentStrokeIndex = 0;
  late List<StrokeCheckpoints> strokeCheckpointsList;

  // Scoring variables.
  int _score = 0;
  int _streak = 0;
  final int _baseLetterBonus = 10; // Base bonus for a correct letter.
  final int _baseLetterPenalty = GameRules.strokePenalty;
  final double _maxMultiplier = 3.0; // Maximum bonus multiplier.

  // Help state.
  bool _showHelp = false;
  final int _helpCost = GameRules.hintCost;
  late AnimationController _helpAnimationController;
  final Duration _helpDuration = const Duration(seconds: 1);

  late ScaffoldMessengerState _scaffoldMessenger;

  @override
  void initState() {
    super.initState();
    _loadSettingsAndGenerateDictionary();
    _helpAnimationController = AnimationController(
      vsync: this,
      duration: _helpDuration,
    );
    // Add a single listener for the help animation.
    _helpAnimationController.addStatusListener((status) {
      // We control the hiding of the help overlay via _triggerHelpAnimation.
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaffoldMessenger = ScaffoldMessenger.of(context);
  }

  @override
  void dispose() {
    _helpAnimationController.dispose();
    _scaffoldMessenger.hideCurrentSnackBar();
    super.dispose();
  }

  Future<void> _loadSettingsAndGenerateDictionary() async {
    await settingsService.init();

    final language = await settingsService.getLanguage();
    final gameMode = await settingsService.getGameMode();
    final letterOrder = await settingsService.getLetterOrder();
    final soundEffectsEnabled = await settingsService.getSoundEffectsEnabled();
    final numbersEnabled = await settingsService.getNumbersEnabled();

    // Generate the basic English alphabet.
    List<String> letters = 'abcdefghijklmnopqrstuvwxyz'.split('');

    // If language is Swedish, add å, ä, ö.
    if (language == 'sv') {
      letters.addAll(['å', 'ä', 'ö']);
    }

    // If numbers
    if (numbersEnabled) {
      letters.addAll(['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']);
    }

    // Determine letter order.
    if (letterOrder == 'random') {
      letters.shuffle();
    }
    // If letterOrder is 'alphabetic', we leave the list as is.

    // Adjust capitalization based on game mode.
    Random random = Random();
    List<String> formattedLetters =
        letters.map((letter) {
          if (gameMode == 'random') {
            return random.nextBool()
                ? letter.toUpperCase()
                : letter.toLowerCase();
          } else if (gameMode == 'uppercase') {
            return letter.toUpperCase();
          } else if (gameMode == 'lowercase') {
            return letter.toLowerCase();
          }
          return letter; // fallback
        }).toList();

    if (!mounted) return;
    setState(() {
      _letters = formattedLetters;
      _isLoading = false;
      _currentLetterIndex = 0;
      letter = _letters[_currentLetterIndex];
      // Cache the stroke checkpoints for the current letter.
      strokeCheckpointsList =
          letterStrokePaths[letter!] as List<StrokeCheckpoints>;
      _language = language; // Store language for later use.
      _soundEffectsEnabled = soundEffectsEnabled;
    });

    // Schedule the welcome message after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_soundEffectsEnabled) {
        SoundEffectsManager().playEffect('audio/start.wav');
      }
      final String welcomeMessage =
          _language == "sv"
              ? "Nu kör vi! Rita din första bokstav!"
              : "Let's go! Draw your first letter!";
      _showSnackBar(welcomeMessage);
    });
  }

  /// True from the last accepted stroke until the next letter is shown.
  bool get _letterComplete =>
      currentStrokeIndex >= strokeCheckpointsList.length;

  // Advances the game to the next letter.
  void _nextLetter() {
    if (_currentLetterIndex < _letters.length - 1) {
      _currentLetterIndex++;
    } else {
      // Restart from beginning if reached the end.
      _currentLetterIndex = 0;
    }
    setState(() {
      letter = _letters[_currentLetterIndex];
      strokeCheckpointsList =
          letterStrokePaths[letter!] as List<StrokeCheckpoints>;
      currentStrokeIndex = 0;
      _completedStrokes.clear();
      _userStroke.clear();
    });
  }

  // Displays a custom SnackBar with the provided message.
  void _showSnackBar(String message) {
    _scaffoldMessenger.hideCurrentSnackBar();
    _scaffoldMessenger.showSnackBar(retroSnackBar(message));
  }

  // Triggers the help animation and hides the help overlay after [delay].
  void _triggerHelpAnimation(Duration delay) {
    setState(() {
      _showHelp = true;
    });
    _helpAnimationController.forward(from: 0.0);
    Future.delayed(delay, () {
      if (mounted) {
        setState(() {
          _showHelp = false;
        });
      }
    });
  }

  // Called when help is requested.
  void _requestHelp() {
    _scaffoldMessenger.hideCurrentSnackBar();

    if (!_firstHelpUsed) {
      _firstHelpUsed = true;
      final String helpCostMessage =
          _language == "sv"
              ? "Den här hjälpen är gratis. Nästa kostar $_helpCost poäng."
              : "This hint is free. The next one costs $_helpCost points.";
      _showSnackBar(helpCostMessage);
      _triggerHelpAnimation(const Duration(seconds: 2));
    } else {
      if (_score >= _helpCost) {
        setState(() {
          _score -= _helpCost;
        });
        final String helpCostMessage =
            _language == "sv"
                ? "Hjälpen kostade $_helpCost poäng."
                : "That hint cost $_helpCost points.";
        _showSnackBar(helpCostMessage);
        _triggerHelpAnimation(const Duration(seconds: 1));
      } else {
        final String notEnoughPointsMessage =
            _language == "sv"
                ? "Du behöver $_helpCost poäng för att få hjälp."
                : "You need $_helpCost points for a hint.";
        _showSnackBar(notEnoughPointsMessage);
      }
    }
  }

  // Calculates bonus based on current streak.
  int _calculateBonus() {
    double multiplier = 1.0 + min(_streak / 5.0, _maxMultiplier - 1.0);
    return (_baseLetterBonus * multiplier).round();
  }

  // Processes the user stroke when the pan gesture ends.
  Future<void> _processUserStroke() async {
    final List<Offset> inBetween = getEvenlyDistributedPointsDynamic(
      _userStroke,
      35.0,
    );
    if (kDebugMode) print("inBetween: $inBetween");
    final expectedStroke = strokeCheckpointsList[currentStrokeIndex];
    bool valid = false;
    int additionalSegments = 0;

    // Handle dot strokes.
    if (_isDotStroke(expectedStroke)) {
      if (_userStroke.isEmpty ||
          (_userStroke.first - expectedStroke.start).distance > 20.0) {
        if (kDebugMode) print("Dot stroke invalid: tap not near dot.");
        _resetUserStroke();
        return;
      } else {
        if (kDebugMode) print("Dot stroke valid.");
        valid = true;
      }
    } else {
      final double totalDistance = _calculateStrokeDistance(_userStroke);
      if (_userStroke.isEmpty || totalDistance < 20.0) {
        if (kDebugMode) {
          print("Stroke too short, ignoring. Total distance: $totalDistance");
        }
        _resetUserStroke();
        return;
      }
      valid = _isStrokeValid(_userStroke, expectedStroke, 30.0, 30.0);
      if (valid) {
        if (kDebugMode) print("Single stroke valid");
      } else if ((currentStrokeIndex + 1) < strokeCheckpointsList.length) {
        final nextExpected = strokeCheckpointsList[currentStrokeIndex + 1];
        List<Offset> combinedPoints = [
          ...expectedStroke.points,
          ...nextExpected.points,
        ];
        valid = _isStrokeValid(
          _userStroke,
          StrokeCheckpoints(
            start: combinedPoints.first,
            inBetween: combinedPoints.sublist(1, combinedPoints.length - 1),
            end: combinedPoints.last,
          ),
          30.0,
          50.0,
        );
        if (valid) {
          if (kDebugMode) print("Combined stroke (2 segments) is valid");
          additionalSegments = 1;
        } else if ((currentStrokeIndex + 2) < strokeCheckpointsList.length) {
          final nextNextExpected =
              strokeCheckpointsList[currentStrokeIndex + 2];
          List<Offset> tripleCombinedPoints = [
            ...expectedStroke.points,
            ...nextExpected.points,
            ...nextNextExpected.points,
          ];
          valid = _isStrokeValid(
            _userStroke,
            StrokeCheckpoints(
              start: tripleCombinedPoints.first,
              inBetween: tripleCombinedPoints.sublist(
                1,
                tripleCombinedPoints.length - 1,
              ),
              end: tripleCombinedPoints.last,
            ),
            30.0,
            55.0,
          );
          if (valid) {
            if (kDebugMode) print("Combined stroke (3 segments) is valid");
            additionalSegments = 2;
          } else if ((currentStrokeIndex + 3) < strokeCheckpointsList.length) {
            final nextNextNextExpected =
                strokeCheckpointsList[currentStrokeIndex + 3];
            List<Offset> quadrupleCombinedPoints = [
              ...expectedStroke.points,
              ...nextExpected.points,
              ...strokeCheckpointsList[currentStrokeIndex + 2].points,
              ...nextNextNextExpected.points,
            ];
            valid = _isStrokeValid(
              _userStroke,
              StrokeCheckpoints(
                start: quadrupleCombinedPoints.first,
                inBetween: quadrupleCombinedPoints.sublist(
                  1,
                  quadrupleCombinedPoints.length - 1,
                ),
                end: quadrupleCombinedPoints.last,
              ),
              30.0,
              60.0,
            );
            if (valid) {
              if (kDebugMode) print("Combined stroke (4 segments) is valid");
              additionalSegments = 3;
            } else {
              if (kDebugMode) print("Stroke is invalid");
            }
          } else {
            if (kDebugMode) print("Stroke is invalid");
          }
        } else {
          if (kDebugMode) print("Stroke is invalid");
        }
      } else {
        if (kDebugMode) print("Stroke is invalid");
      }
    }

    if (valid) {
      await _handleValidStroke(additionalSegments);
    } else {
      _handleInvalidStroke();
    }
    _resetUserStroke();
  }

  void _resetUserStroke() {
    setState(() {
      _userStroke = [];
    });
  }

  // Handles a valid stroke and awards points if the letter is finished.
  Future<void> _handleValidStroke(int additionalSegments) async {
    _completedStrokes.add(List.from(_userStroke));
    currentStrokeIndex += (1 + additionalSegments);
    if (currentStrokeIndex >= strokeCheckpointsList.length) {
      if (_soundEffectsEnabled) {
        SoundEffectsManager().playEffect('audio/complete.wav');
      }

      // Immediately clear the current (blue) stroke so only the green stroke shows.
      setState(() {
        _userStroke.clear();
      });

      final int oldHighScore = await settingsService.getHighScore();
      final int oldHighestStreak = await settingsService.getHighestStreak();
      if (!mounted) return;
      _streak++;
      final int bonus = _calculateBonus();
      setState(() {
        _score += bonus;
      });
      bool newHighScore = false;
      if (_score > oldHighScore) {
        if (!_hasDisplayedHighScoreMessage) {
          newHighScore = true;
          _hasDisplayedHighScoreMessage = true;
        }
        await settingsService.setHighScore(_score);
      }
      if (_streak > oldHighestStreak) {
        await settingsService.setHighestStreak(_streak);
      }
      final Random random = Random();
      final List<String> englishGreetings = [
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
      final List<String> swedishGreetings = [
        "Bra jobbat!",
        "Fantastiskt!",
        "Strålande!",
        "Utmärkt!",
        "Toppen!",
        "Suveränt!",
        "Jättebra!",
        "Fortsätt så!",
        "Enastående!",
        "Du är grym!",
      ];
      final String greeting =
          _language == "sv"
              ? swedishGreetings[random.nextInt(swedishGreetings.length)]
              : englishGreetings[random.nextInt(englishGreetings.length)];
      final String streakMessage =
          _streak > 1
              ? _language == "sv"
                  ? " $_streak rätt i rad!"
                  : " $_streak in a row!"
              : "";
      final String newHighScoreMessage =
          newHighScore
              ? _language == "sv"
                  ? " Nytt rekord!"
                  : " New high score!"
              : "";
      final String snackMessage =
          _language == "sv"
              ? "$greeting Du fick $bonus poäng.$streakMessage$newHighScoreMessage"
              : "$greeting You earned $bonus points.$streakMessage$newHighScoreMessage";

      _showSnackBar(snackMessage);

      // Delay so the player can see the finished letter with the green stroke.
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      _nextLetter();
    } else {
      if (_soundEffectsEnabled) {
        SoundEffectsManager().playEffect('audio/success.wav');
      }
    }
  }

  // Handles an invalid stroke by resetting the streak and deducting penalty points.
  void _handleInvalidStroke() {
    if (_soundEffectsEnabled) {
      SoundEffectsManager().playEffect('audio/fail.wav');
    }
    _streak = 0;
    setState(() {
      _score -= _baseLetterPenalty;
    });
    final Random random = Random();
    // Short openers; the line after them already says "Try again!".
    final List<String> englishErrorMessages = [
      "Oops!",
      "Not quite!",
      "Almost!",
      "So close!",
      "Whoops!",
      "That one didn't count.",
    ];
    final List<String> swedishErrorMessages = [
      "Oj!",
      "Inte riktigt!",
      "Nästan!",
      "Nära!",
      "Hoppsan!",
      "Den räknades inte.",
    ];
    final String errorMessage =
        _language == "sv"
            ? swedishErrorMessages[random.nextInt(swedishErrorMessages.length)]
            : englishErrorMessages[random.nextInt(englishErrorMessages.length)];
    final String snackMessage =
        _language == "sv"
            ? "$errorMessage Du förlorade $_baseLetterPenalty poäng. Försök igen!"
            : "$errorMessage You lost $_baseLetterPenalty points. Try again!";
    _showSnackBar(snackMessage);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || letter == null) {
      return const Scaffold(
        body: RetroBackground(child: Center(child: RetroLoader())),
      );
    }

    final bool isNumeric = RegExp(r'^\d+$').hasMatch(letter!);
    final String appBarTitle =
        _language == "sv"
            ? (isNumeric ? "Siffra: $letter" : "Bokstav: $letter")
            : (isNumeric ? "Number: $letter" : "Letter: $letter");
    final String scoreText =
        _language == "sv" ? "Poäng: $_score" : "Score: $_score";

    return Scaffold(
      body: RetroBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                // Custom transparent AppBar with a back button.
                AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: RetroIconButton(
                    glyph: PixelGlyph.arrowLeft,
                    onPressed: () {
                      if (_soundEffectsEnabled) {
                        SoundEffectsManager().playEffect(
                          'audio/button_click.wav',
                        );
                      }
                      Navigator.pop(context);
                    },
                    tooltip: _language == "sv" ? "Huvudmeny" : "Main Menu",
                  ),
                  centerTitle: true,
                  title: Text(appBarTitle, style: RetroText.style(16)),
                  actions: [
                    RetroIconButton(
                      glyph: PixelGlyph.question,
                      tooltip: _language == "sv" ? "Hjälp" : "Hint",
                      onPressed: () {
                        if (_soundEffectsEnabled) {
                          SoundEffectsManager().playEffect(
                            'audio/button_click.wav',
                          );
                        }
                        _requestHelp();
                      },
                    ),
                  ],
                ),
                // Display the score below the AppBar.
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  child: Text(
                    scoreText,
                    style: RetroText.style(20),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Drawing area.
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      const double designWidth = 300;
                      const double designHeight = 300;
                      final double scale = min(
                        constraints.maxWidth / designWidth,
                        constraints.maxHeight / designHeight,
                      );
                      final double dx =
                          (constraints.maxWidth - designWidth * scale) / 2;
                      final double dy =
                          (constraints.maxHeight - designHeight * scale) / 2;

                      return GestureDetector(
                        onPanStart: (details) {
                          // Ignore input while a finished letter is shown.
                          if (_letterComplete) return;
                          final Offset designPos =
                              (details.localPosition - Offset(dx, dy)) / scale;
                          setState(() {
                            _userStroke = [designPos];
                            _showHelp = false;
                          });
                        },
                        onPanUpdate: (details) {
                          if (_letterComplete) return;
                          final Offset designPos =
                              (details.localPosition - Offset(dx, dy)) / scale;
                          setState(() {
                            _userStroke.add(designPos);
                          });
                        },
                        onPanEnd: (details) async {
                          if (_letterComplete) return;
                          await _processUserStroke();
                        },
                        child: AnimatedBuilder(
                          animation: _helpAnimationController,
                          builder: (context, child) {
                            return CustomPaint(
                              size: Size(
                                constraints.maxWidth,
                                constraints.maxHeight,
                              ),
                              painter: CheckpointPainter(
                                letter: letter!,
                                strokeCheckpoints:
                                    currentStrokeIndex <
                                            strokeCheckpointsList.length
                                        ? strokeCheckpointsList[currentStrokeIndex]
                                        : null,
                                userStroke: _userStroke,
                                completedStrokes: _completedStrokes,
                                scale: scale,
                                dx: dx,
                                dy: dy,
                                showHelp: _showHelp,
                                helpProgress: _helpAnimationController.value,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _calculateStrokeDistance(List<Offset> points) {
    double total = 0;
    for (int i = 1; i < points.length; i++) {
      total += (points[i] - points[i - 1]).distance;
    }
    return total;
  }

  bool _isDotStroke(StrokeCheckpoints cp) {
    return cp.inBetween.isEmpty && cp.start == cp.end;
  }

  bool _isStrokeValid(
    List<Offset> stroke,
    StrokeCheckpoints checkpoints,
    double tolerance,
    double maxDevTol,
  ) {
    final List<Offset> expectedPoints = checkpoints.points;
    if (stroke.isEmpty) return false;

    // Check that the stroke starts near the expected start.
    if ((stroke.first - expectedPoints.first).distance > tolerance) {
      if (kDebugMode) print("The stroke did not start at the right place");
      return false;
    }

    final List<int> hitIndices = [];
    int cpIndex = 0;
    // Collect indices where each expected checkpoint is hit.
    for (int i = 0; i < stroke.length; i++) {
      if (cpIndex >= expectedPoints.length) break;
      if ((stroke[i] - expectedPoints[cpIndex]).distance <= tolerance) {
        hitIndices.add(i);
        cpIndex++;
      }
    }
    if (hitIndices.length != expectedPoints.length) {
      if (kDebugMode) print("The stroke did not hit all checkpoints");
      return false;
    }

    // Ensure that any stroke points after the last matched checkpoint remain
    // within tolerance of the expected end. This prevents extra stray offsets.
    int lastHit = hitIndices.last;
    for (int i = lastHit; i < stroke.length; i++) {
      if ((stroke[i] - expectedPoints.last).distance > tolerance) {
        if (kDebugMode) {
          print(
            "The stroke hit all checkpoints but contains lines too far away from checkpoints",
          );
        }
        return false;
      }
    }

    // For each segment between consecutive checkpoints,
    // ensure the stroke doesn’t deviate too far.
    for (int j = 0; j < hitIndices.length - 1; j++) {
      int startIndex = hitIndices[j];
      int endIndex = hitIndices[j + 1];
      final Offset p1 = expectedPoints[j];
      final Offset p2 = expectedPoints[j + 1];
      for (int k = startIndex; k <= endIndex; k++) {
        final double d = distanceToSegment(stroke[k], p1, p2);
        if (d > maxDevTol) {
          if (kDebugMode) {
            print("The stroke deviates too far from the expected path");
          }
          return false;
        }
      }
    }
    return true;
  }
}

double distanceToSegment(Offset p, Offset a, Offset b) {
  final ap = p - a;
  final ab = b - a;
  final double ab2 = ab.dx * ab.dx + ab.dy * ab.dy;
  if (ab2 == 0) return (p - a).distance;
  double t = (ap.dx * ab.dx + ap.dy * ab.dy) / ab2;
  t = t.clamp(0, 1);
  final Offset closest = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
  return (p - closest).distance;
}

// Admin function to add new shapes (letter_stroke_paths)
List<Offset> getEvenlyDistributedPointsDynamic(
  List<Offset> points,
  double desiredSpacing, {
  double snapThreshold = 10.0,
}) {
  if (points.length < 2) return [];
  final Offset start = points.first;
  final Offset end = points.last;
  double maxDeviation = 0.0;
  for (int i = 1; i < points.length - 1; i++) {
    final double d = distanceToSegment(points[i], start, end);
    if (d > maxDeviation) maxDeviation = d;
  }
  if (maxDeviation < snapThreshold) {
    final double lineLength = (end - start).distance;
    int count = (lineLength / desiredSpacing).floor() - 1;
    if (count < 1) count = 1;
    final List<Offset> result = [];
    for (int i = 1; i <= count; i++) {
      final double fraction = i / (count + 1);
      final Offset interpolated = Offset.lerp(start, end, fraction)!;
      result.add(interpolated);
    }
    return result;
  }
  const int resolution = 1000;
  final List<Offset> sampledPoints = List.generate(
    resolution + 1,
    (i) => _catmullRom(points, i / resolution),
  );
  final List<double> cumulative = [0.0];
  for (int i = 1; i < sampledPoints.length; i++) {
    final double dist = (sampledPoints[i] - sampledPoints[i - 1]).distance;
    cumulative.add(cumulative.last + dist);
  }
  final double totalLength = cumulative.last;
  int count = (totalLength / desiredSpacing).floor() - 1;
  if (count < 1) count = 1;
  final double spacing = totalLength / (count + 1);
  final List<Offset> result = [];
  for (int i = 1; i <= count; i++) {
    final double target = spacing * i;
    int segmentIndex = 0;
    while (segmentIndex < cumulative.length - 1 &&
        cumulative[segmentIndex + 1] < target) {
      segmentIndex++;
    }
    final double segmentStart = cumulative[segmentIndex];
    final double segmentEnd = cumulative[segmentIndex + 1];
    final double tLocal = (target - segmentStart) / (segmentEnd - segmentStart);
    final Offset p0 = sampledPoints[segmentIndex];
    final Offset p1 = sampledPoints[segmentIndex + 1];
    final Offset interpolated = Offset(
      p0.dx + tLocal * (p1.dx - p0.dx),
      p0.dy + tLocal * (p1.dy - p0.dy),
    );
    result.add(interpolated);
  }
  return result;
}

// Admin function to even out curves when getting new shapes
Offset _catmullRom(List<Offset> points, double t) {
  final int n = points.length;
  final int segments = n - 1;
  double segmentT = t * segments;
  int i = segmentT.floor();
  if (i >= segments) {
    i = segments - 1;
    segmentT = 1.0;
  } else {
    segmentT -= i;
  }
  final Offset p0 = i == 0 ? points[i] : points[i - 1];
  final Offset p1 = points[i];
  final Offset p2 = points[i + 1];
  final Offset p3 = (i + 2 < n) ? points[i + 2] : points[i + 1];
  final double u = segmentT;
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

// Canvas painters
class CheckpointPainter extends CustomPainter {
  final String letter;
  final StrokeCheckpoints? strokeCheckpoints;
  final List<Offset> userStroke;
  final List<List<Offset>> completedStrokes;
  final double scale;
  final double dx;
  final double dy;
  final bool showHelp;
  final double helpProgress; // Value from 0.0 to 1.0

  CheckpointPainter({
    required this.letter,
    required this.strokeCheckpoints,
    required this.userStroke,
    required this.completedStrokes,
    required this.scale,
    required this.dx,
    required this.dy,
    required this.showHelp,
    required this.helpProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    // Draw the letter.
    final TextSpan span = TextSpan(
      text: letter,
      style: GoogleFonts.poppins(fontSize: 300, color: RetroColors.letter),
    );
    final TextPainter tp = TextPainter(
      text: span,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    final Offset textPos = Offset((300 - tp.width) / 2, (300 - tp.height) / 2);
    tp.paint(canvas, textPos);

    // Draw completed strokes.
    RetroPaint.drawCompletedStrokes(canvas, completedStrokes);

    // Draw the current stroke.
    RetroPaint.drawUserStroke(canvas, userStroke);

    // Draw expected stroke guidance if help is requested.
    if (strokeCheckpoints != null && showHelp) {
      RetroPaint.drawHint(canvas, strokeCheckpoints!.points, helpProgress);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
