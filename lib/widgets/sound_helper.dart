import 'package:audioplayers/audioplayers.dart';

class SoundHelper {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  // Memutar suara transisi (sementara dinonaktifkan)
  static Future<void> playTransition() async {
    // Fungsi dinonaktifkan sementara - akan diganti dengan suara baru nanti
    return;
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

  // Memutar suara click (sementara dinonaktifkan)
  static Future<void> playClick() async {
    // Fungsi dinonaktifkan sementara - akan diganti dengan suara baru nanti
    return;
  }

  static void dispose() {
    _audioPlayer.dispose();
  }
}
