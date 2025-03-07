import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/stroke_checkpoint.dart';
import '../services/settings_service.dart';
import 'package:letterchamp/data/letter_stroke_paths.dart';

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

  // Tracing variables.
  List<Offset> _userStroke = [];
  final List<List<Offset>> _completedStrokes = [];
  int currentStrokeIndex = 0;
  late List<StrokeCheckpoints> strokeCheckpointsList;

  // Scoring variables.
  int _score = 0;
  int _streak = 0;
  final int _baseLetterBonus = 10; // Base bonus for a correct letter.
  final int _baseLetterPenalty = 2; // Penalty for an incorrect stroke.
  final double _maxMultiplier = 3.0; // Maximum bonus multiplier.

  // Help state.
  bool _showHelp = false;
  final int _helpCost = 5; // Points deducted per help press.
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

    // Generate the basic English alphabet.
    List<String> letters = 'abcdefghijklmnopqrstuvwxyz'.split('');

    // If language is Swedish, add å, ä, ö.
    if (language == 'sv') {
      letters.addAll(['å', 'ä', 'ö']);
    }

    // Determine letter order.
    if (letterOrder == 'random') {
      letters.shuffle();
    }
    // If letterOrder is 'alphabetic', we leave the list as is.

    // Adjust capitalization based on game mode.
    Random random = Random();
    List<String> formattedLetters = letters.map((letter) {
      if (gameMode == 'random') {
        return random.nextBool() ? letter.toUpperCase() : letter.toLowerCase();
      } else if (gameMode == 'uppercase') {
        return letter.toUpperCase();
      } else if (gameMode == 'lowercase') {
        return letter.toLowerCase();
      }
      return letter; // fallback
    }).toList();

    setState(() {
      _letters = formattedLetters;
      _isLoading = false;
      _currentLetterIndex = 0;
      letter = _letters[_currentLetterIndex];
      // Cache the stroke checkpoints for the current letter.
      strokeCheckpointsList =
      letterStrokePaths[letter!] as List<StrokeCheckpoints>;
      _language = language; // Store language for later use.
    });
  }

  /// Advances the game to the next letter.
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

  /// Displays a custom SnackBar with the provided message.
  void _showSnackBar(String message) {
    _scaffoldMessenger.hideCurrentSnackBar();
    _scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.pressStart2p(
            textStyle: const TextStyle(fontSize: 14, color: Colors.white),
          ),
        ),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  /// Triggers the help animation and hides the help overlay after [delay].
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

  /// Called when help is requested.
  void _requestHelp() {
    _scaffoldMessenger.hideCurrentSnackBar();

    if (!_firstHelpUsed) {
      _firstHelpUsed = true;
      final String helpCostMessage = _language == "sv"
          ? "Första hjälpen är gratis! Nästa kostar $_helpCost poäng."
          : "First help is free! Next help will cost $_helpCost points!";
      _showSnackBar(helpCostMessage);
      _triggerHelpAnimation(const Duration(seconds: 2));
    } else {
      if (_score >= _helpCost) {
        setState(() {
          _score -= _helpCost;
        });
        final String helpCostMessage = _language == "sv"
            ? "Hjälp kostade $_helpCost poäng!"
            : "Help cost $_helpCost points!";
        _showSnackBar(helpCostMessage);
        _triggerHelpAnimation(const Duration(seconds: 1));
      } else {
        final String notEnoughPointsMessage = _language == "sv"
            ? "Inte tillräckligt med poäng för hjälp!"
            : "Not enough points for help!";
        _showSnackBar(notEnoughPointsMessage);
      }
    }
  }

  /// Calculates bonus based on current streak.
  int _calculateBonus() {
    double multiplier = 1.0 + min(_streak / 5.0, _maxMultiplier - 1.0);
    return (_baseLetterBonus * multiplier).round();
  }

  /// Processes the user stroke when the pan gesture ends.
  Future<void> _processUserStroke() async {
    final List<Offset> inBetween =
    getEvenlyDistributedPointsDynamic(_userStroke, 35.0);
    if (kDebugMode) {
      print("inBetween: $inBetween");
    }
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
      valid = _isStrokeValid(_userStroke, expectedStroke, 25.0, 25.0);
      if (valid) {
        if (kDebugMode) print("Single stroke valid");
      } else if ((currentStrokeIndex + 1) < strokeCheckpointsList.length) {
        final nextExpected = strokeCheckpointsList[currentStrokeIndex + 1];
        List<Offset> combinedPoints = [
          ...expectedStroke.points,
          ...nextExpected.points
        ];
        valid = _isStrokeValid(
          _userStroke,
          StrokeCheckpoints(
            start: combinedPoints.first,
            inBetween: combinedPoints.sublist(1, combinedPoints.length - 1),
            end: combinedPoints.last,
          ),
          25.0,
          25.0,
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
            ...nextNextExpected.points
          ];
          valid = _isStrokeValid(
            _userStroke,
            StrokeCheckpoints(
              start: tripleCombinedPoints.first,
              inBetween:
              tripleCombinedPoints.sublist(1, tripleCombinedPoints.length - 1),
              end: tripleCombinedPoints.last,
            ),
            25.0,
            25.0,
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
              ...nextNextNextExpected.points
            ];
            valid = _isStrokeValid(
              _userStroke,
              StrokeCheckpoints(
                start: quadrupleCombinedPoints.first,
                inBetween: quadrupleCombinedPoints.sublist(
                    1, quadrupleCombinedPoints.length - 1),
                end: quadrupleCombinedPoints.last,
              ),
              25.0,
              25.0,
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

  /// Handles a valid stroke and awards points if the letter is finished.
  Future<void> _handleValidStroke(int additionalSegments) async {
    _completedStrokes.add(List.from(_userStroke));
    currentStrokeIndex += (1 + additionalSegments);
    if (currentStrokeIndex >= strokeCheckpointsList.length) {
      final int oldHighScore = await settingsService.getHighScore();
      final int oldHighestStreak = await settingsService.getHighestStreak();
      _streak++;
      final int bonus = _calculateBonus();
      setState(() {
        _score += bonus;
      });
      bool newHighScore = false;
      if (_score > oldHighScore) {
        newHighScore = true;
        await settingsService.setHighScore(_score);
      }
      if (_streak > oldHighestStreak) {
        await settingsService.setHighestStreak(_streak);
      }
      String streakMessage = _streak > 1
          ? _language == "sv"
          ? " $_streak i rad bonus!"
          : " $_streak in a row bonus!"
          : "";
      String newHighScoreMessage = newHighScore
          ? _language == "sv"
          ? " Nytt rekord!"
          : " New high score!"
          : "";
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
        "You're on fire!"
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
        "Du är grym!"
      ];
      final String greeting = _language == "sv"
          ? swedishGreetings[random.nextInt(swedishGreetings.length)]
          : englishGreetings[random.nextInt(englishGreetings.length)];
      final String snackMessage = _language == "sv"
          ? "$greeting Du fick $bonus poäng.$streakMessage$newHighScoreMessage"
          : "$greeting You earned $bonus points.$streakMessage$newHighScoreMessage";
      _showSnackBar(snackMessage);
      _nextLetter();
    }
  }

  /// Handles an invalid stroke by resetting the streak and deducting penalty points.
  void _handleInvalidStroke() {
    _streak = 0;
    setState(() {
      _score -= _baseLetterPenalty;
    });
    final Random random = Random();
    final List<String> englishErrorMessages = [
      "Oops! That didn't work.",
      "Whoops! That wasn't quite right.",
      "Hmm, something went wrong.",
      "Oh no! That stroke didn't count.",
      "Yikes! That didn't come out as expected.",
      "Darn! Let's try that stroke again.",
      "Uh-oh! That stroke missed the mark.",
      "Oops! Not quite right.",
      "Ah, that didn't work. Give it another go!",
      "Oops! Let's try that again."
    ];
    final List<String> swedishErrorMessages = [
      "Oj då! Det blev fel.",
      "Oj, det var inte rätt.",
      "Hmm, något gick snett.",
      "Åh nej! Den linjen räknades inte.",
      "Oj, det blev inte som förväntat.",
      "Aj då! Försök igen.",
      "Hmm, den linjen blev inte rätt.",
      "Oj, inte riktigt, försök igen!",
      "Aj, det där blev inte som det skulle. Prova igen!",
      "Oj, det där räckte inte. Försök en gång till!"
    ];
    final String errorMessage = _language == "sv"
        ? swedishErrorMessages[random.nextInt(swedishErrorMessages.length)]
        : englishErrorMessages[random.nextInt(englishErrorMessages.length)];
    final String snackMessage = _language == "sv"
        ? "$errorMessage Du förlorade $_baseLetterPenalty poäng. Försök igen!"
        : "$errorMessage You lost $_baseLetterPenalty points. Try again!";
    _showSnackBar(snackMessage);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || letter == null) {
      return Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/game_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Container(
              color: Color.fromRGBO(0, 0, 0, 0.4),
            ),
            const Center(child: CircularProgressIndicator()),
          ],
        ),
      );
    }

    final String appBarTitle =
    _language == "sv" ? "Bokstav: $letter" : "Letter: $letter";
    final String scoreText =
    _language == "sv" ? "Poäng: $_score" : "Score: $_score";

    return Scaffold(
      body: Stack(
        children: [
          // Background image.
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/game_bg.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark overlay.
          Container(
            color: Color.fromRGBO(0, 0, 0, 0.4),
          ),
          // Main content.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  // Custom transparent AppBar with a back button.
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon:
                      const Icon(Icons.arrow_back, color: Colors.white),
                      iconSize: 36,
                      onPressed: () => Navigator.pop(context),
                      tooltip: _language == "sv"
                          ? "Huvudmeny"
                          : "Main Menu",
                    ),
                    centerTitle: true,
                    title: Text(
                      appBarTitle,
                      style: GoogleFonts.pressStart2p(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.help_outline,
                            color: Colors.white),
                        iconSize: 36,
                        onPressed: _requestHelp,
                      ),
                    ],
                  ),
                  // Display the score below the AppBar.
                  Container(
                    margin:
                    const EdgeInsets.only(top: 8, bottom: 8),
                    child: Text(
                      scoreText,
                      style: GoogleFonts.pressStart2p(
                        textStyle: const TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
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
                            constraints.maxHeight / designHeight);
                        final double dx = (constraints.maxWidth -
                            designWidth * scale) /
                            2;
                        final double dy = (constraints.maxHeight -
                            designHeight * scale) /
                            2;

                        return GestureDetector(
                          onPanStart: (details) {
                            final Offset designPos =
                                (details.localPosition -
                                    Offset(dx, dy)) /
                                    scale;
                            if (kDebugMode) {
                              print("Offset: $designPos");
                            }
                            setState(() {
                              _userStroke = [designPos];
                              _showHelp = false;
                            });
                          },
                          onPanUpdate: (details) {
                            final Offset designPos =
                                (details.localPosition -
                                    Offset(dx, dy)) /
                                    scale;
                            setState(() {
                              _userStroke.add(designPos);
                            });
                          },
                          onPanEnd: (details) async {
                            await _processUserStroke();
                          },
                          child: AnimatedBuilder(
                            animation: _helpAnimationController,
                            builder: (context, child) {
                              return CustomPaint(
                                size: Size(constraints.maxWidth,
                                    constraints.maxHeight),
                                painter: CheckpointPainter(
                                  letter: letter!,
                                  strokeCheckpoints:
                                  currentStrokeIndex <
                                      strokeCheckpointsList.length
                                      ? strokeCheckpointsList[
                                  currentStrokeIndex]
                                      : null,
                                  userStroke: _userStroke,
                                  completedStrokes: _completedStrokes,
                                  scale: scale,
                                  dx: dx,
                                  dy: dy,
                                  showHelp: _showHelp,
                                  helpProgress:
                                  _helpAnimationController.value,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 100,),
                ],
              ),
            ),
          ),
        ],
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
      double maxDevTol) {
    final List<Offset> expectedPoints = checkpoints.points;
    if (stroke.isEmpty) return false;
    if ((stroke.first - expectedPoints.first).distance > tolerance) {
      return false;
    }
    if ((stroke.last - expectedPoints.last).distance > tolerance) {
      return false;
    }

    final List<int> hitIndices = [];
    int cpIndex = 0;
    for (int i = 0; i < stroke.length; i++) {
      if (cpIndex >= expectedPoints.length) break;
      if ((stroke[i] - expectedPoints[cpIndex]).distance <= tolerance) {
        hitIndices.add(i);
        cpIndex++;
      }
    }
    if (hitIndices.length != expectedPoints.length) return false;

    for (int j = 0; j < hitIndices.length - 1; j++) {
      int startIndex = hitIndices[j];
      int endIndex = hitIndices[j + 1];
      final Offset p1 = expectedPoints[j];
      final Offset p2 = expectedPoints[j + 1];
      for (int k = startIndex; k <= endIndex; k++) {
        final double d = distanceToSegment(stroke[k], p1, p2);
        if (d > maxDevTol) return false;
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

List<Offset> getEvenlyDistributedPointsDynamic(
    List<Offset> points, double desiredSpacing,
    {double snapThreshold = 10.0}) {
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
    final double dist =
        (sampledPoints[i] - sampledPoints[i - 1]).distance;
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
    final double tLocal =
        (target - segmentStart) / (segmentEnd - segmentStart);
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
  final double x = 0.5 *
      ((2 * p1.dx) +
          (-p0.dx + p2.dx) * u +
          (2 * p0.dx - 5 * p1.dx + 4 * p2.dx - p3.dx) * u2 +
          (-p0.dx + 3 * p1.dx - 3 * p2.dx + p3.dx) * u3);
  final double y = 0.5 *
      ((2 * p1.dy) +
          (-p0.dy + p2.dy) * u +
          (2 * p0.dy - 5 * p1.dy + 4 * p2.dy - p3.dy) * u2 +
          (-p0.dy + 3 * p1.dy - 3 * p2.dy + p3.dy) * u3);
  return Offset(x, y);
}

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
      style: GoogleFonts.poppins(
        fontSize: 300,
        color: Colors.grey.shade300,
      ),
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
    if (completedStrokes.isNotEmpty) {
      final Paint completedPaint = Paint()
        ..color = const Color(0xFF32CD32) // LimeGreen
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      for (var stroke in completedStrokes) {
        if (stroke.isNotEmpty) {
          if (stroke.length == 1) {
            final Paint fillPaint = Paint()
              ..color = Colors.blue
              ..style = PaintingStyle.fill;
            canvas.drawCircle(stroke.first, 8.0, fillPaint);
          } else {
            final Path path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
            for (final Offset p in stroke.skip(1)) {
              path.lineTo(p.dx, p.dy);
            }
            canvas.drawPath(path, completedPaint);
          }
        }
      }
    }

    // Draw the current stroke.
    if (userStroke.isNotEmpty) {
      final Paint strokePaint = Paint()
        ..color = const Color(0xFF00BFFF) // DeepSkyBlue
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final Path path = Path()..moveTo(userStroke.first.dx, userStroke.first.dy);
      for (final Offset p in userStroke.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, strokePaint);
    }

    // Draw expected stroke guidance if help is requested.
    if (strokeCheckpoints != null && showHelp) {
      final List<Offset> points = strokeCheckpoints!.points;
      for (int i = 0; i < points.length; i++) {
        final Color color = i == 0
            ? const Color(0xFF39FF14)
            : (i == points.length - 1 ? const Color(0xFFFF073A) : Colors.grey);
        final double radius = (i == 0 || i == points.length - 1) ? 8.0 : 4.0;
        final Paint checkpointPaint = Paint()..color = color;
        canvas.drawCircle(points[i], radius, checkpointPaint);
      }

      final Paint helpPaint = Paint()
        ..color = Colors.amberAccent.shade700
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      final Path fullPath = Path()..moveTo(points.first.dx, points.first.dy);
      for (final Offset p in points.skip(1)) {
        fullPath.lineTo(p.dx, p.dy);
      }

      final Path animatedPath = Path();
      for (final metric in fullPath.computeMetrics()) {
        final double length = metric.length * helpProgress;
        animatedPath.addPath(metric.extractPath(0, length), Offset.zero);
      }
      canvas.drawPath(animatedPath, helpPaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
