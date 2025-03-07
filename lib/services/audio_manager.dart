import 'package:audioplayers/audioplayers.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  factory AudioManager() => _instance;

  AudioManager._internal() {
    // Set the player to loop without starting playback.
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> startMusic() async {
    if (!_isPlaying) {
      await _audioPlayer.play(AssetSource('audio/background_music.mp3'));
      _isPlaying = true;
    }
  }

  Future<void> stopMusic() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      _isPlaying = false;
    }
  }
}
