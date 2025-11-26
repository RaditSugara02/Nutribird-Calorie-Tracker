import 'package:audioplayers/audioplayers.dart';

class SoundHelper {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  // Memutar suara transisi
  static Future<void> playTransition() async {
    try {
      await _audioPlayer.play(AssetSource('transition.wav'));
      // Tunggu untuk memastikan suara tidak terpotong saat navigasi
      // Delay 500ms untuk memastikan suara selesai diputar
      await Future.delayed(const Duration(milliseconds: 500));
    } catch (e) {
      print('Error playing transition sound: $e');
      // Jika error, tetap tunggu sedikit untuk konsistensi
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  // Memutar suara error
  static Future<void> playError() async {
    try {
      await _audioPlayer.play(AssetSource('error.wav'));
    } catch (e) {
      print('Error playing error sound: $e');
    }
  }

  // Memutar suara success
  static Future<void> playSuccess() async {
    try {
      await _audioPlayer.play(AssetSource('success.wav'));
    } catch (e) {
      print('Error playing success sound: $e');
    }
  }

  // Memutar suara click
  static Future<void> playClick() async {
    try {
      await _audioPlayer.play(AssetSource('click.wav'));
    } catch (e) {
      print('Error playing click sound: $e');
    }
  }

  static void dispose() {
    _audioPlayer.dispose();
  }
}
