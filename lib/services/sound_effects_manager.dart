import 'package:audioplayers/audioplayers.dart';

/// The short sounds the game plays.
enum SoundEffect {
  click('button_click'),
  cancel('cancel'),
  complete('complete'),
  fail('fail'),
  start('start'),
  success('success');

  const SoundEffect(this._file);

  final String _file;

  String get assetPath => 'audio/$_file.wav';
}

/// Plays one sound effect at a time. The app shares a single instance.
class SoundEffectsManager {
  factory SoundEffectsManager() => _instance;

  SoundEffectsManager._() {
    _player.setPlayerMode(PlayerMode.mediaPlayer);
    _player.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck,
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
  }

  static final SoundEffectsManager _instance = SoundEffectsManager._();

  final AudioPlayer _player = AudioPlayer();

  /// Mirrors the sound-effects setting. [play] does nothing while false.
  bool enabled = true;

  /// Plays [effect], cutting off whichever effect is still playing.
  Future<void> play(SoundEffect effect) async {
    if (!enabled) return;
    await _player.stop();
    await _player.play(AssetSource(effect.assetPath));
  }
}
