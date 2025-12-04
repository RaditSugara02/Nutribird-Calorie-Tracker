import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_rpl_final/utils/logger.dart';

class BackgroundMusicService {
  static final BackgroundMusicService _instance =
      BackgroundMusicService._internal();
  factory BackgroundMusicService() => _instance;

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isEnabled = false; // Default: music is off
  bool _isPlaying =
      false; // Status terakhir yang kita inginkan (bukan selalu sama dengan state native)
  static const String _prefKey = 'background_music_enabled';

  BackgroundMusicService._internal() {
    // Listen for player state changes untuk menjaga flag _isPlaying
    _audioPlayer.playerStateStream.listen((state) {
      if (state.playing) {
        _isPlaying = true;
      } else if (state.processingState == ProcessingState.completed ||
          state.processingState == ProcessingState.idle) {
        _isPlaying = false;
      }
    });
  }

  /// Initialize music service - load preference and start playing if enabled
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isEnabled = prefs.getBool(_prefKey) ?? false; // Default: music is off

    if (_isEnabled) {
      await play();
    }
  }

  /// Check if music is enabled
  bool get isEnabled => _isEnabled;

  /// Check if music is currently playing
  bool get isPlaying => _isPlaying;

  /// Enable background music
  Future<void> enable() async {
    if (_isEnabled) return;

    _isEnabled = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
    await play();
  }

  /// Disable background music
  Future<void> disable() async {
    if (!_isEnabled) return;

    _isEnabled = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, false);
    await stop();
  }

  /// Toggle music on/off
  Future<void> toggle() async {
    if (_isEnabled) {
      await disable();
    } else {
      await enable();
    }
  }

  /// Play background music (looping)
  Future<void> play() async {
    if (!_isEnabled) return;

    try {
      // Set sumber audio dari assets dan loop terus menerus
      await _audioPlayer.setAudioSource(
        AudioSource.asset('assets/background_music.mp3'),
        initialPosition: Duration.zero,
      );
      await _audioPlayer.setLoopMode(LoopMode.one);
      await _audioPlayer.play();
      _isPlaying = true;
    } catch (e, stackTrace) {
      AppLogger.warning('Error playing background music', e, stackTrace);
      // If music file doesn't exist, silently fail
      _isPlaying = false;
    }
  }

  /// Stop background music
  Future<void> stop() async {
    if (!_isPlaying) return;

    try {
      await _audioPlayer.stop();
      _isPlaying = false;
    } catch (e, stackTrace) {
      AppLogger.warning('Error stopping background music', e, stackTrace);
    }
  }

  /// Pause background music
  Future<void> pause() async {
    if (!_isPlaying) return;

    try {
      await _audioPlayer.pause();
      // Keep _isPlaying as true to indicate music should resume
      // We don't set it to false because we want to resume later
    } catch (e, stackTrace) {
      AppLogger.warning('Error pausing background music', e, stackTrace);
    }
  }

  /// Resume background music
  Future<void> resume() async {
    if (!_isEnabled) return;

    try {
      // Dengan just_audio, cukup panggil play lagi jika musik diaktifkan
      await _audioPlayer.play();
      _isPlaying = true;
    } catch (e, stackTrace) {
      AppLogger.warning('Error resuming background music', e, stackTrace);
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    final clampedVolume = volume.clamp(0.0, 1.0);
    await _audioPlayer.setVolume(clampedVolume);
  }

  /// Dispose resources
  void dispose() {
    _audioPlayer.dispose();
  }
}
