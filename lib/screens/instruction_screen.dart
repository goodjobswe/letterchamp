import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:letterchamp/models/game_rules.dart';
import 'package:letterchamp/models/stroke_checkpoint.dart';
import 'package:letterchamp/services/settings_service.dart';
import 'package:letterchamp/services/sound_effects_manager.dart';
import 'package:letterchamp/theme/retro_paint.dart';
import 'package:letterchamp/theme/retro_theme.dart';
import 'package:letterchamp/theme/retro_widgets.dart';

class InstructionScreen extends StatefulWidget {
  const InstructionScreen({super.key});

  @override
  InstructionScreenState createState() => InstructionScreenState();
}

class InstructionScreenState extends State<InstructionScreen>
    with SingleTickerProviderStateMixin {
  final SettingsService settingsService = SettingsService();

  // Predefined stroke paths for tutorial letters.
  final Map<String, List<StrokeCheckpoints>> letterStrokePaths = {
    'A': [
      const StrokeCheckpoints(
        start: Offset(150, 55),
        inBetween: [
          Offset(136.0, 92.5),
          Offset(121.2, 130.9),
          Offset(106.3, 169.3),
          Offset(91.5, 207.7),
        ],
        end: Offset(77, 243),
      ),
      const StrokeCheckpoints(
        start: Offset(150, 55),
        inBetween: [
          Offset(165.8, 92.5),
          Offset(180.7, 130.9),
          Offset(195.7, 169.3),
          Offset(210.6, 207.7),
        ],
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
        inBetween: [
          Offset(124, 97.6),
          Offset(124, 134.6),
          Offset(124.0, 171.7),
          Offset(124, 208.8),
          Offset(124, 243),
          Offset(160.5, 243),
        ],
        end: Offset(197, 243),
      ),
    ],
  };

  List<String> _letters = [];
  bool _isLoading = true;
  int _currentLetterIndex = 0;
  String? letter; // Current letter used in tutorial.
  String _language = "en"; // Default language.
  int _helpStepIndex = 0;
  MainAxisAlignment columnAlignment = MainAxisAlignment.start;
  bool _soundEffectsEnabled = false;

  // Tracing variables.
  List<Offset> _userStroke = [];
  final List<List<Offset>> _completedStrokes = [];
  int currentStrokeIndex = 0;
  late List<StrokeCheckpoints> strokeCheckpointsList;

  // Help state.
  bool _showHelp = false;
  late AnimationController _helpAnimationController;
  final Duration _helpDuration = const Duration(seconds: 1);

  // Tutorial help messages.
  final List<Map<String, String>> helpMessages = [
    {
      "sv": "Dra med fingret för att rita första delen.",
      "en": "Drag your finger to draw the first part.",
    },
    {
      "sv": "Dra med fingret igen för nästa del.",
      "en": "Drag your finger again for the next part.",
    },
    {
      "sv": "Dra med fingret en gång till för sista delen.",
      "en": "Drag your finger once more for the final part.",
    },
    {
      "sv":
          "Vissa bokstäver ritas i ett enda drag.\n\nDra med fingret för att rita hela bokstaven.",
      "en":
          "Some letters are drawn in one stroke.\n\nDrag your finger to draw the whole letter.",
    },
    {
      "sv":
          "Tryck på frågetecknet uppe till höger om du behöver hjälp.\n\nDu får hjälp gratis första gången, sedan kostar det ${GameRules.hintCost} poäng.\n\nTryck på frågetecknet för att fortsätta.",
      "en":
          "Tap the question mark at the top right if you need a hint.\n\nThe first hint is free. After that a hint costs ${GameRules.hintCost} points.\n\nTap the question mark to continue.",
    },
    {
      "sv":
          "Rita bokstäverna på rätt sätt för att få poäng!\n\nFlera rätt i rad ger bonus. Ett misstag nollställer bonusen och kostar ${GameRules.strokePenalty} poäng.",
      "en":
          "Draw the letter correctly to earn points!\n\nCorrect letters in a row earn a bonus. A mistake resets your bonus and costs ${GameRules.strokePenalty} points.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSettingsAndGenerateDictionary();
    _helpAnimationController = AnimationController(
      vsync: this,
      duration: _helpDuration,
    );
    // Add a single status listener for the help animation.
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
  void dispose() {
    _helpAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettingsAndGenerateDictionary() async {
    await settingsService.init();
    final language = await settingsService.getLanguage();
    final soundEffectsEnabled = await settingsService.getSoundEffectsEnabled();
    // Use only the tutorial letters.
    List<String> formattedLetters = 'AL'.split('');
    if (!mounted) return;
    setState(() {
      _letters = formattedLetters;
      _isLoading = false;
      _currentLetterIndex = 0;
      letter = _letters[_currentLetterIndex];
      strokeCheckpointsList =
          letterStrokePaths[letter!] as List<StrokeCheckpoints>;
      _language = language;
      _soundEffectsEnabled = soundEffectsEnabled;
      _requestHelp(); // Automatically show help on load.
    });
  }

  /// True from the last accepted stroke until the next letter is shown.
  bool get _letterComplete =>
      currentStrokeIndex >= strokeCheckpointsList.length;

  // Advances the tutorial to the next letter.
  void _nextLetter() {
    if (_currentLetterIndex < _letters.length - 1) {
      _currentLetterIndex++;
    } else {
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

  // Sets the help overlay visible and starts the animation.
  void _requestHelp() {
    setState(() {
      _showHelp = true;
    });
    if (mounted) {
      _helpAnimationController.forward(from: 0.0);
    }
  }

  // Helper to build a common text style.
  TextStyle _instructionTextStyle(double size, {bool withShadow = true}) {
    return RetroText.style(size, shadow: withShadow);
  }

  // Helper to build the main menu button.
  Widget _buildMainMenuButton(String text, VoidCallback onPressed) {
    return RetroButton(label: text, onPressed: onPressed);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || letter == null) {
      return const Scaffold(
        body: RetroBackground(child: Center(child: RetroLoader())),
      );
    }

    final String appBarTitle =
        _language == "sv" ? "Så spelar du" : "How to Play";
    final String mainMenuText = _language == "sv" ? "Huvudmeny" : "Main Menu";

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
                  title: Text(appBarTitle, style: _instructionTextStyle(16)),
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
                        if (_helpStepIndex == 4) {
                          setState(() {
                            _helpStepIndex++;
                          });
                        }
                      },
                    ),
                  ],
                ),
                // Drawing area.
                if (_helpStepIndex < 4)
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
                                (details.localPosition - Offset(dx, dy)) /
                                scale;
                            setState(() {
                              _userStroke = [designPos];
                            });
                          },
                          onPanUpdate: (details) {
                            if (_letterComplete) return;
                            final Offset designPos =
                                (details.localPosition - Offset(dx, dy)) /
                                scale;
                            setState(() {
                              _userStroke.add(designPos);
                            });
                          },
                          onPanEnd: (details) async {
                            if (_letterComplete) return;
                            final expectedStroke =
                                strokeCheckpointsList[currentStrokeIndex];
                            bool valid = false;
                            if (_userStroke.isEmpty) {
                              setState(() {
                                _userStroke = [];
                              });
                              return;
                            }
                            valid = _isStrokeValid(
                              _userStroke,
                              expectedStroke,
                              20.0,
                              20.0,
                            );
                            if (valid) {
                              if (_soundEffectsEnabled) {
                                SoundEffectsManager().playEffect(
                                  'audio/success.wav',
                                );
                              }
                              setState(() {
                                _helpStepIndex++;
                                if (_helpStepIndex == 4) {
                                  _showHelp = false;
                                  columnAlignment = MainAxisAlignment.center;
                                }
                              });
                            } else {
                              if (_soundEffectsEnabled) {
                                SoundEffectsManager().playEffect(
                                  'audio/fail.wav',
                                );
                              }
                            }
                            if (currentStrokeIndex <
                                    strokeCheckpointsList.length &&
                                valid) {
                              _completedStrokes.add(List.from(_userStroke));
                              currentStrokeIndex++;
                              if (currentStrokeIndex ==
                                  strokeCheckpointsList.length) {
                                if (_soundEffectsEnabled) {
                                  SoundEffectsManager().playEffect(
                                    'audio/complete.wav',
                                  );
                                }
                                // Clear the blue stroke immediately so the green one is visible.
                                setState(() {
                                  _userStroke = [];
                                });
                                await Future.delayed(
                                  const Duration(seconds: 1),
                                ); // Delay to show green stroke.
                                if (!mounted) return;
                                _nextLetter();
                                return;
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
                const SizedBox(height: 20),
                // Instructional text and main menu button.
                Expanded(
                  child: Column(
                    mainAxisAlignment: columnAlignment,
                    children: [
                      Text(
                        _language == "sv"
                            ? helpMessages[_helpStepIndex]["sv"]!
                            : helpMessages[_helpStepIndex]["en"]!,
                        textAlign: TextAlign.center,
                        style: _instructionTextStyle(18),
                      ),
                      if (_helpStepIndex == 5) const SizedBox(height: 36),
                      if (_helpStepIndex == 5)
                        Center(
                          child: _buildMainMenuButton(mainMenuText, () {
                            if (_soundEffectsEnabled) {
                              SoundEffectsManager().playEffect(
                                'audio/button_click.wav',
                              );
                            }
                            Navigator.pop(context);
                          }),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
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
    if ((stroke.first - expectedPoints.first).distance > tolerance) {
      return false;
    }
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
  final double helpProgress; // 0.0 to 1.0

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

    // Draw expected stroke guidance if help is active.
    if (strokeCheckpoints != null && showHelp) {
      RetroPaint.drawHint(canvas, strokeCheckpoints!.points, helpProgress);
    }

    // Draw current user stroke.
    RetroPaint.drawUserStroke(canvas, userStroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
