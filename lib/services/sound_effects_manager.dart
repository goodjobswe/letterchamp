import 'package:audioplayers/audioplayers.dart';

class SoundEffectsManager {
  // Singleton instance.
  static final SoundEffectsManager _instance = SoundEffectsManager._internal();
  final AudioPlayer _player = AudioPlayer();

  factory SoundEffectsManager() => _instance;

  SoundEffectsManager._internal();

  Future<void> playEffect(String assetPath) async {
    await _player.play(AssetSource(assetPath));
  }

  // Additional methods for more control if needed.
  Future<void> stopEffect() async {
    await _player.stop();
  }
}
