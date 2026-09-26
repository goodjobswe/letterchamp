import 'package:flutter/material.dart';
import 'package:letterchamp/data/letter_stroke_paths.dart';
import 'package:letterchamp/models/game_rules.dart';
import 'package:letterchamp/models/stroke_checkpoint.dart';
import 'package:letterchamp/models/stroke_validator.dart';
import 'package:letterchamp/services/settings_service.dart';
import 'package:letterchamp/services/sound_effects_manager.dart';
import 'package:letterchamp/theme/retro_theme.dart';
import 'package:letterchamp/theme/retro_widgets.dart';
import 'package:letterchamp/widgets/tracing_canvas.dart';

/// The guided introduction: trace an A in three strokes and an L in one,
/// then read how hints and scoring work.
class InstructionScreen extends StatefulWidget {
  const InstructionScreen({super.key});

  @override
  State<InstructionScreen> createState() => _InstructionScreenState();
}

class _InstructionScreenState extends State<InstructionScreen>
    with SingleTickerProviderStateMixin {
  static const List<String> _letters = ['A', 'L'];

  /// The tutorial draws its L in a single stroke to teach continuous strokes;
  /// the game's L in [letterStrokePaths] uses two.
  static final Map<String, List<StrokeCheckpoints>> _paths = {
    'A': letterStrokePaths['A']!,
    'L': [
      const StrokeCheckpoints(
        start: Offset(124, 61),
        inBetween: [
          Offset(124, 97.6),
          Offset(124, 134.6),
          Offset(124, 171.7),
          Offset(124, 208.8),
          Offset(124, 243),
          Offset(160.5, 243),
        ],
        end: Offset(197, 243),
      ),
    ],
  };

  /// Steps before [_hintStep] each trace one stroke; the last two are text.
  static const int _hintStep = 4;
  static const int _scoringStep = 5;

  static const List<Map<String, String>> _stepMessages = [
    {
      'sv': 'Dra med fingret för att rita första delen.',
      'en': 'Drag your finger to draw the first part.',
    },
    {
      'sv': 'Dra med fingret igen för nästa del.',
      'en': 'Drag your finger again for the next part.',
    },
    {
      'sv': 'Dra med fingret en gång till för sista delen.',
      'en': 'Drag your finger once more for the final part.',
    },
    {
      'sv':
          'Vissa bokstäver ritas i ett enda drag.\n\nDra med fingret för att rita hela bokstaven.',
      'en':
          'Some letters are drawn in one stroke.\n\nDrag your finger to draw the whole letter.',
    },
    {
      'sv':
          'Tryck på frågetecknet uppe till höger om du behöver hjälp.\n\nDu får hjälp gratis första gången, sedan kostar det ${GameRules.hintCost} poäng.\n\nTryck på frågetecknet för att fortsätta.',
      'en':
          'Tap the question mark at the top right if you need a hint.\n\nThe first hint is free. After that a hint costs ${GameRules.hintCost} points.\n\nTap the question mark to continue.',
    },
    {
      'sv':
          'Rita bokstäverna på rätt sätt för att få poäng!\n\nFlera rätt i rad ger bonus. Ett misstag nollställer bonusen och kostar ${GameRules.strokePenalty} poäng.',
      'en':
          'Draw the letter correctly to earn points!\n\nCorrect letters in a row earn a bonus. A mistake resets your bonus and costs ${GameRules.strokePenalty} points.',
    },
  ];

  /// The tutorial is stricter than the game so that the strokes it accepts
  /// are clean examples.
  static const double _tolerance = 20;

  final SettingsService _settingsService = SettingsService();
  late final AnimationController _hintAnimation = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  );

  bool _loading = true;
  String _language = 'en';
  int _step = 0;
  int _letterIndex = 0;
  int _strokeIndex = 0;
  List<Offset> _userStroke = [];
  final List<List<Offset>> _completedStrokes = [];
  bool _showHint = false;

  bool get _swedish => _language == 'sv';
  String get _letter => _letters[_letterIndex];
  List<StrokeCheckpoints> get _strokes => _paths[_letter]!;

  /// True from the last accepted stroke until the next letter is shown.
  bool get _letterComplete => _strokeIndex >= _strokes.length;

  @override
  void initState() {
    super.initState();
    // Replay the hint every few seconds for as long as it is shown.
    _hintAnimation.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed && _showHint) {
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _showHint) _hintAnimation.forward(from: 0);
        });
      }
    });
    _loadSettings();
  }

  @override
  void dispose() {
    _hintAnimation.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final String language = await _settingsService.getLanguage();
    SoundEffectsManager().enabled =
        await _settingsService.getSoundEffectsEnabled();
    if (!mounted) return;
    setState(() {
      _language = language;
      _loading = false;
    });
    _startHint();
  }

  void _startHint() {
    setState(() => _showHint = true);
    _hintAnimation.forward(from: 0);
  }

  void _nextLetter() {
    setState(() {
      _letterIndex = (_letterIndex + 1) % _letters.length;
      _strokeIndex = 0;
      _completedStrokes.clear();
      _userStroke = [];
    });
  }

  /// Accepts or rejects the stroke just drawn and moves the tutorial on.
  Future<void> _evaluateStroke() async {
    if (_userStroke.isEmpty) return;
    final bool accepted = StrokeValidator.matches(
      _userStroke,
      _strokes[_strokeIndex],
      tolerance: _tolerance,
      maxDeviation: _tolerance,
    );
    if (!accepted) {
      SoundEffectsManager().play(SoundEffect.fail);
      setState(() => _userStroke = []);
      return;
    }

    _completedStrokes.add(List.of(_userStroke));
    setState(() {
      _userStroke = [];
      _strokeIndex++;
      _step++;
      if (_step == _hintStep) _showHint = false;
    });
    if (!_letterComplete) {
      SoundEffectsManager().play(SoundEffect.success);
      return;
    }

    SoundEffectsManager().play(SoundEffect.complete);
    // Leave the finished letter on screen for a moment.
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    _nextLetter();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: RetroBackground(child: Center(child: RetroLoader())),
      );
    }

    final String message = _stepMessages[_step][_swedish ? 'sv' : 'en']!;
    final bool tracing = _step < _hintStep;

    return Scaffold(
      body: RetroBackground(
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
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
                      title: Text(
                        _swedish ? 'Så spelar du' : 'How to Play',
                        style: RetroText.style(16),
                      ),
                      actions: [
                        RetroIconButton(
                          glyph: PixelGlyph.question,
                          tooltip: _swedish ? 'Hjälp' : 'Hint',
                          onPressed: () {
                            SoundEffectsManager().play(SoundEffect.click);
                            if (_step == _hintStep) setState(() => _step++);
                          },
                        ),
                      ],
                    ),
                    if (tracing) ...[
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
                              (Offset point) =>
                                  setState(() => _userStroke = [point]),
                          onStrokeUpdate:
                              (Offset point) =>
                                  setState(() => _userStroke.add(point)),
                          onStrokeEnd: _evaluateStroke,
                        ),
                      ),
                      // Same bottom reserve as the game, under the floating
                      // message, so the letter sits where it does in the game.
                      const SizedBox(height: 100),
                    ] else
                      // The text-only steps center the message, with the menu
                      // button under the last one.
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RetroMessage(message, fontSize: 16),
                              if (_step == _scoringStep) ...[
                                const SizedBox(height: 24),
                                RetroButton(
                                  label: _swedish ? 'Huvudmeny' : 'Main Menu',
                                  onPressed: () {
                                    SoundEffectsManager().play(
                                      SoundEffect.click,
                                    );
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // The instruction floats at the bottom like the game's
              // messages, so the drawing area keeps its size on every step.
              if (tracing)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: RetroMessage(message, fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
