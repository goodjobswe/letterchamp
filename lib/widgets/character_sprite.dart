import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:letterchamp/theme/retro_theme.dart';

/// The mascot, kept alive with an occasional blink and a one-pixel bob.
///
/// A blink swaps in a second frame of the sprite with the eyes closed. The
/// first blink comes shortly after the sprite appears; later ones are spaced
/// at random so the rhythm never looks mechanical.
class CharacterSprite extends StatefulWidget {
  const CharacterSprite({super.key, this.size = 200});

  /// Width and height of the sprite on screen.
  final double size;

  static const String eyesOpenAsset = 'assets/images/game_character.png';
  static const String eyesClosedAsset =
      'assets/images/game_character_blink.png';

  /// The sprite is drawn on a 64 by 64 grid.
  static const int gridSize = 64;

  static const Duration firstBlinkDelay = Duration(seconds: 1);
  static const Duration blinkDuration = Duration(milliseconds: 120);

  /// Later blinks wait between [minBlinkGap] and [maxBlinkGap].
  static const Duration minBlinkGap = Duration(seconds: 2);
  static const Duration maxBlinkGap = Duration(seconds: 5);

  /// The sprite moves up one pixel and back down once per period.
  static const Duration bobPeriod = Duration(milliseconds: 600);

  @override
  State<CharacterSprite> createState() => _CharacterSpriteState();
}

class _CharacterSpriteState extends State<CharacterSprite> {
  final Random _random = Random();
  Timer? _blinkTimer;
  Timer? _bobTimer;
  bool _eyesClosed = false;
  bool _bobbedUp = false;

  /// One sprite pixel on screen, snapped to whole device pixels.
  double get _spritePixel =>
      RetroGrid.snap(widget.size / CharacterSprite.gridSize);

  @override
  void initState() {
    super.initState();
    _bobTimer = Timer.periodic(CharacterSprite.bobPeriod, (_) {
      setState(() => _bobbedUp = !_bobbedUp);
    });
    _scheduleBlink(CharacterSprite.firstBlinkDelay);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Decode the closed-eye frame early, or the first blink shows a gap.
    precacheImage(const AssetImage(CharacterSprite.eyesClosedAsset), context);
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    _bobTimer?.cancel();
    super.dispose();
  }

  void _scheduleBlink(Duration delay) {
    _blinkTimer = Timer(delay, () {
      setState(() => _eyesClosed = true);
      _blinkTimer = Timer(CharacterSprite.blinkDuration, () {
        setState(() => _eyesClosed = false);
        final int gapRange =
            (CharacterSprite.maxBlinkGap - CharacterSprite.minBlinkGap)
                .inMilliseconds;
        _scheduleBlink(
          CharacterSprite.minBlinkGap +
              Duration(milliseconds: _random.nextInt(gapRange)),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, _bobbedUp ? -_spritePixel : 0),
      child: Image.asset(
        _eyesClosed
            ? CharacterSprite.eyesClosedAsset
            : CharacterSprite.eyesOpenAsset,
        width: widget.size,
        height: widget.size,
        fit: BoxFit.contain,
        // Keep the current frame on screen while the other one is fetched.
        gaplessPlayback: true,
      ),
    );
  }
}
