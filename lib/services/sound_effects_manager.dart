import 'package:audioplayers/audioplayers.dart';

class SoundEffectsManager {
  static final SoundEffectsManager _instance = SoundEffectsManager._internal();
  final AudioPlayer _player = AudioPlayer();

  factory SoundEffectsManager() => _instance;

  SoundEffectsManager._internal() {
    // Set player mode
    _player.setPlayerMode(PlayerMode.mediaPlayer); // Use mediaPlayer for general cases

    // Set audio context for sound effects
    _player.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,  // No need to keep awake for short effects
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck, // Allows multiple sounds
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers},
        ),
      ),
    );
  }

  Future<void> playEffect(String sourceString) async {
    await _player.stop();
    await _player.play(AssetSource(sourceString));
  }

  Future<void> stopEffect() async {
    await _player.stop();
  }
}
