import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// Loops the background music and pauses it while the app is in the
/// background. The app shares a single instance.
class MusicManager with WidgetsBindingObserver {
  factory MusicManager() => _instance;

  MusicManager._() {
    WidgetsBinding.instance.addObserver(this);
    _player.setVolume(1.0);
    _player.setReleaseMode(ReleaseMode.loop);
    _player.setPlayerMode(PlayerMode.mediaPlayer);
    _player.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
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

  static final MusicManager _instance = MusicManager._();

  final AudioPlayer _player = AudioPlayer();

  /// Whether the music should be heard; it is paused, not stopped, while the
  /// app is in the background.
  bool _playing = false;

  /// Starts the music unless it is already playing, so re-reading the
  /// settings never restarts the track.
  Future<void> play() async {
    if (_playing) return;
    _playing = true;
    await _player.play(AssetSource('audio/background_music.mp3'));
  }

  Future<void> stop() async {
    _playing = false;
    await _player.stop();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_playing) return;
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _player.pause();
      case AppLifecycleState.resumed:
        _player.resume();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }
}
