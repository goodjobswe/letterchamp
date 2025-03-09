import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioManager with WidgetsBindingObserver {
  static final AudioManager _instance = AudioManager._internal();
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false; // Track playback state

  factory AudioManager() => _instance;

  AudioManager._internal() {
    WidgetsBinding.instance.addObserver(this); // Listen for app lifecycle events

    // Lower the volume to 15%
    _player.setVolume(0.15);
    // Set the release mode to loop.
    _player.setReleaseMode(ReleaseMode.loop);
    // Set as media player
    _player.setPlayerMode(PlayerMode.mediaPlayer);
    // Set audio context
    _player.setAudioContext(
      AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: true,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.gainTransientMayDuck, // Allows other sounds to play
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.playback,
          options: {AVAudioSessionOptions.mixWithOthers}, //
        ),
      ),
    );
  }

  Future<void> play() async {
    await _player.play(AssetSource('audio/background_music.mp3'));
    _isPlaying = true;
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      // Pause music when app goes to background
      if (_isPlaying) {
        _player.pause();
      }
    } else if (state == AppLifecycleState.resumed) {
      // Resume music when app comes back into focus
      if (_isPlaying) {
        _player.resume();
      }
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
  }
}