import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/stroke_checkpoint.dart';
import '../services/settings_service.dart';

class InstructionScreen extends StatefulWidget {
  const InstructionScreen({super.key});

  @override
  InstructionScreenState createState() => InstructionScreenState();
}

class InstructionScreenState extends State<InstructionScreen>
    with SingleTickerProviderStateMixin {
  // Settings service.
  final SettingsService settingsService = SettingsService();

  final Map<String, List<StrokeCheckpoints>> letterStrokePaths = {
    'A': [
      const StrokeCheckpoints(
        start: Offset(150, 55),
        inBetween: [Offset(136.0, 92.5), Offset(121.2, 130.9), Offset(106.3, 169.3), Offset(91.5, 207.7)],
        end: Offset(77, 243),
      ),
      const StrokeCheckpoints(
        start: Offset(150, 55),
        inBetween: [Offset(165.8, 92.5), Offset(180.7, 130.9), Offset(195.7, 169.3), Offset(210.6, 207.7)],
        end: Offset(222, 243),
      ),
      const StrokeCheckpoints(
        start: Offset(97, 196),
        inBetween: [Offset(131.4, 196.6), Offset(167.8, 196.4)],
        end: Offset(207, 196),
      ),
    ],
    'L': [
      const StrokeCheckpoints(
        start: Offset(124, 61),
        inBetween: [Offset(124, 97.6), Offset(124, 134.6), Offset(124.0, 171.7), Offset(124, 208.8), Offset(124, 243), Offset(160.5, 243)],
        end: Offset(197, 243),
      ),
    ],
  };

  List<String> _letters = [];
  bool _isLoading = true;
  int _currentLetterIndex = 0;
  String? letter; // Current letter to trace.
  String _language = "en"; // default language
  int _helpStepIndex = 0;
  MainAxisAlignment columnAlignment = MainAxisAlignment.start;

  // Tracing variables.
  List<Offset> _userStroke = [];
  final List<List<Offset>> _completedStrokes = [];
  int currentStrokeIndex = 0;
  late List<StrokeCheckpoints> strokeCheckpointsList;
  late List<StrokeCheckpoints> strokeCheckpointsListCombined;

  // Help state.
  bool _showHelp = false;
  late AnimationController _helpAnimationController;
  final Duration _helpDuration = const Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    _loadSettingsAndGenerateDictionary();
    _helpAnimationController = AnimationController(
      vsync: this,
      duration: _helpDuration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _showHelp = false;
    _helpAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettingsAndGenerateDictionary() async {
    await settingsService.init();

    final language = await settingsService.getLanguage();

    // Generate the letters for the tutorial
    List<String> formattedLetters = 'AL'.split('');

    setState(() {
      _letters = formattedLetters;
      _isLoading = false;
      _currentLetterIndex = 0;
      letter = _letters[_currentLetterIndex];
      // Cache the stroke checkpoints for the current letter.
      strokeCheckpointsList =
      letterStrokePaths[letter!] as List<StrokeCheckpoints>;
      _language = language; // Store language for later use.
      _requestHelp();
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

  /// Called when help is requested.
  void _requestHelp() {
      setState(() {
        _showHelp = true;
      });
      if (mounted) {
        _helpAnimationController.forward(from: 0.0);
      }
    _helpAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && _showHelp) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _helpAnimationController.forward(from: 0.0);
          }
        });
      }
    });
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

    // Only show the letter in the AppBar.
    final String appBarTitle = _language == "sv"
        ? "Instruktioner"
        : "Instructions";

    final List<Map<String, String>> helpMessages = [
      {
        "sv": "Dra med fingret för att rita första delen.",
        "en": "Drag your finger to draw the first part."
      },
      {
        "sv": "Dra med fingret igen för nästa del.",
        "en": "Drag your finger again for the next part."
      },
      {
        "sv": "Dra med fingret en gång till för sista delen.",
        "en": "Drag your finger once more for the final part."
      },
      {
        "sv": "Fantastiskt!\n\nVissa bokstäver kan ritas med en kontinuerlig linje.\n\nDra fingret för att rita hela bokstaven.",
        "en": "Great!\n\nSome letters can be drawn with one continuous stroke.\n\nDrag your finger to draw the whole letter."
      },
      {
        "sv": "Tryck på frågetecknet uppe till höger om du behöver hjälp.\n\nFörsta hjälpen är gratis, därefter kostar den 5 poäng.\n\nTryck på frågetecknet för att fortsätta.",
        "en": "Tap the question mark at the top right if you need any help.\n\nFirst help is free, thereafter it costs 5 points.\n\nTap the question mark to continue."
      },
      {
        "sv": "Rita bokstäverna på rätt sätt för att få poäng!\n\nFlera rätt i rad ger bonus. Ett misstag nollställer bonusen och kostar 2 poäng.",
        "en": "Draw the letter in the correct way to receive points!\n\nConsecutive letters earn bonus. A mistake resets your bonus and costs 2 points."
      },
    ];


    final String mainMenuText =
    _language == 'sv' ? 'Huvudmeny' : 'Main Menu';

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
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      iconSize: 36,
                      onPressed: () => Navigator.pop(context),
                      tooltip:
                      _language == "sv" ? "Huvudmeny" : "Main Menu",
                    ),
                    centerTitle: true,
                    title: Text(
                      appBarTitle,
                      style: GoogleFonts.pressStart2p(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10,
                              color: Colors.black,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.help_outline, color: Colors.white),
                        iconSize: 36,
                        onPressed: (){
                          if(_helpStepIndex == 4){
                            setState(() {
                              _helpStepIndex++;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  if(_helpStepIndex < 4)
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        const double designWidth = 300;
                        const double designHeight = 300;
                        final double scale = min(
                            constraints.maxWidth / designWidth,
                            constraints.maxHeight / designHeight);
                        final double dx =
                            (constraints.maxWidth - designWidth * scale) / 2;
                        final double dy =
                            (constraints.maxHeight - designHeight * scale) / 2;

                        return GestureDetector(
                          onPanStart: (details) {
                            final Offset designPos =
                                (details.localPosition - Offset(dx, dy)) / scale;
                            if (kDebugMode) {
                              print("Offset: $designPos");
                            }
                            setState(() {
                              _userStroke = [designPos];
                            });
                          },
                          onPanUpdate: (details) {
                            final Offset designPos =
                                (details.localPosition - Offset(dx, dy)) / scale;
                            setState(() {
                              _userStroke.add(designPos);
                            });
                          },
                          onPanEnd: (details) async {
                            final expectedStroke = strokeCheckpointsList[currentStrokeIndex];
                            bool valid = false;

                              if (_userStroke.isEmpty) {
                                setState(() {
                                  _userStroke = [];
                                });
                                return;
                              }
                              valid = _isStrokeValid(_userStroke, expectedStroke, 20.0, 20.0);
                              if (valid) {
                                setState(() {
                                  _helpStepIndex++;
                                  if(_helpStepIndex ==4){
                                    _showHelp = false;
                                    columnAlignment = MainAxisAlignment.center;
                                  }
                                });
                              } else {
                                if (kDebugMode) print("Stroke is invalid");
                              }

                            // Now award points only if the letter is completely finished.
                            if (currentStrokeIndex < strokeCheckpointsList.length) {
                              if (valid) {
                                _completedStrokes.add(List.from(_userStroke));
                                currentStrokeIndex++;
                                // Award bonus only when the entire letter is finished.
                                if (currentStrokeIndex == strokeCheckpointsList.length) {

                                  _nextLetter();
                                }
                              }
                            }
                            setState(() {
                              _userStroke = [];
                            });
                          },
                          child: AnimatedBuilder(
                            animation: _helpAnimationController,
                            builder: (context, child) {
                              return CustomPaint(
                                size: Size(constraints.maxWidth, constraints.maxHeight),
                                painter: CheckpointPainter(
                                  letter: letter!,
                                  strokeCheckpoints: currentStrokeIndex < strokeCheckpointsList.length
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
                  const SizedBox(height: 20),
                  // Instructional text.
                  Expanded(
                    child: Column(
                      mainAxisAlignment: columnAlignment,
                      children: [
                        Text(
                          _language == "sv"
                              ? helpMessages[_helpStepIndex]["sv"]!
                              : helpMessages[_helpStepIndex]["en"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.pressStart2p(
                            textStyle: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Colors.black,
                                  offset: Offset(2, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if(_helpStepIndex == 5)
                          const SizedBox(height: 36),
                        // Main Menu Button.
                        if(_helpStepIndex == 5)
                        Center(
                          child: ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: WidgetStateProperty.all(Colors.transparent),
                              elevation: WidgetStateProperty.all(0),
                              padding: WidgetStateProperty.all(EdgeInsets.zero),
                              shape: WidgetStateProperty.all(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Ink(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xfff45d27), Color(0xfff5851f)],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black45,
                                    blurRadius: 5,
                                    offset: Offset(3, 3),
                                  ),
                                ],
                              ),
                              child: Container(
                                constraints: const BoxConstraints(minWidth: 150, minHeight: 50),
                                alignment: Alignment.center,
                                child: Text(
                                  mainMenuText,
                                  style: GoogleFonts.pressStart2p(
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isStrokeValid(
      List<Offset> stroke,
      StrokeCheckpoints checkpoints,
      double tolerance,
      double maxDevTol,
      ) {
    final List<Offset> expectedPoints = checkpoints.points;
    if (stroke.isEmpty) return false;
    if ((stroke.first - expectedPoints.first).distance > tolerance) return false;
    if ((stroke.last - expectedPoints.last).distance > tolerance) return false;

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
        ..color = Color(0xFF32CD32) // LimeGreen
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

    // Draw expected stroke guidance if help is requested.
    if (strokeCheckpoints != null && showHelp) {
      final List<Offset> points = strokeCheckpoints!.points;
      for (int i = 0; i < points.length; i++) {
        final Color color = i == 0
            ? Color(0xFF39FF14)
            : (i == points.length - 1 ? Color(0xFFFF073A) : Colors.grey);
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

    // Draw the current stroke.
    if (userStroke.isNotEmpty) {
      final Paint strokePaint = Paint()
        ..color = Color(0xFF00BFFF) // DeepSkyBlue
        ..strokeWidth = 8
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final Path path = Path()..moveTo(userStroke.first.dx, userStroke.first.dy);
      for (final Offset p in userStroke.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(path, strokePaint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
