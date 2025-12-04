import 'package:just_audio/just_audio.dart';
import 'package:flutter_application_rpl_final/services/background_music_service.dart';
import 'package:flutter_application_rpl_final/utils/logger.dart';

class SoundHelper {
  /// Player global untuk efek suara yang bisa overlap dengan background music
  static final AudioPlayer _effectPlayer = AudioPlayer();

  /// Inisialisasi sekali (bisa dipanggil dari main atau saat pertama kali dipakai)
  static Future<void> initialize() async {
    // Tidak perlu konfigurasi khusus di sini untuk just_audio
  }

  /// Helper internal untuk memutar efek suara dari assets
  static Future<void> _playEffect(
    String assetPath, {
    double volume = 1.0,
  }) async {
    try {
      await _effectPlayer.setAudioSource(AudioSource.asset(assetPath));
      await _effectPlayer.setVolume(volume.clamp(0.0, 1.0));
      await _effectPlayer.play();
    } catch (e, stackTrace) {
      AppLogger.warning(
        'Error playing sound effect: $assetPath',
        e,
        stackTrace,
      );
    }
  }

  // Memutar suara transisi (sementara dinonaktifkan)
  static Future<void> playTransition() async {
    // Fungsi dinonaktifkan sementara - akan diganti dengan suara baru nanti
    return;
  }

  // Memutar suara error
  static Future<void> playError() async {
    // Trade-off: jika musik latar aktif, jangan putar suara error
    // untuk mencegah musik dipause oleh sistem/audio focus.
    final musicService = BackgroundMusicService();
    if (musicService.isEnabled) return;

    await _playEffect('assets/error.wav');
  }

  // Memutar suara success
  static Future<void> playSuccess() async {
    await _playEffect('assets/success.wav');
  }

  // Memutar suara click (sementara dinonaktifkan)
  static Future<void> playClick() async {
    // Fungsi dinonaktifkan sementara - akan diganti dengan suara baru nanti
    return;
  }
}
