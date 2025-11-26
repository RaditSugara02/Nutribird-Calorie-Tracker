import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';

class AddWeightScreen extends StatefulWidget {
  final Function(double weight) onWeightAdded;

  const AddWeightScreen({super.key, required this.onWeightAdded});

  @override
  State<AddWeightScreen> createState() => _AddWeightScreenState();
}

class _AddWeightScreenState extends State<AddWeightScreen> {
  final TextEditingController _weightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  // Listener untuk memastikan video tetap playing
  void _videoListener() {
    if (_isVideoInitialized &&
        _videoController.value.isInitialized &&
        !_videoController.value.isPlaying &&
        _videoController.value.duration != _videoController.value.position) {
      // Video terhenti tanpa alasan, lanjutkan
      _videoController.play();
    }
  }

  Future<void> _initializeVideo() async {
    try {
      _videoController = VideoPlayerController.asset(
        'lib/vid/Gendut_processed.mp4',
      );

      await _videoController.initialize();

      if (mounted) {
        // Set video untuk looping
        _videoController.setLooping(true);

        // Set volume ke 0 untuk mematikan suara video
        await _videoController.setVolume(0.0);

        setState(() {
          _isVideoInitialized = true;
        });

        // Mulai memutar video
        _videoController.play();

        // Tambahkan listener untuk memastikan video tetap playing
        _videoController.addListener(_videoListener);
      }
    } catch (e) {
      print('Error initializing video: $e');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Remove listener sebelum dispose
    if (_isVideoInitialized) {
      _videoController.removeListener(_videoListener);
    }
    _weightController.dispose();
    _videoController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // Fungsi untuk memutar suara error tanpa mengganggu video
  void _playErrorSound() async {
    try {
      // Simpan status video sebelum memutar suara (jika video sudah initialized)
      bool wasPlaying = false;
      if (_isVideoInitialized) {
        wasPlaying = _videoController.value.isPlaying;
      }

      // Play error sound
      await _audioPlayer.play(AssetSource('error.wav'));

      // Jika video sedang playing, pastikan tetap berjalan setelah error sound
      if (_isVideoInitialized && wasPlaying) {
        // Check dan resume video setelah error sound diputar
        Future.delayed(Duration(milliseconds: 50), () {
          if (mounted &&
              _isVideoInitialized &&
              !_videoController.value.isPlaying) {
            _videoController.play();
          }
        });

        // Juga check dengan post frame callback
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted &&
              _isVideoInitialized &&
              !_videoController.value.isPlaying) {
            _videoController.play();
          }
        });
      }
    } catch (e) {
      print('Error playing sound: $e');
      // Pastikan video tetap berjalan meskipun ada error
      if (_isVideoInitialized && !_videoController.value.isPlaying) {
        _videoController.play();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color darkGreenBg = const Color(0xFF1D362C);
    final Color lightGreenText = const Color(0xFFA2F46E);
    final Color darkText = const Color(0xFF112D21);

    return Scaffold(
      backgroundColor: darkGreenBg,
      appBar: AppBar(
        backgroundColor: darkGreenBg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: lightGreenText),
          onPressed: () async {
            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Catat Berat Badan',
          style: TextStyle(
            color: lightGreenText,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 24.0,
            right: 24.0,
            top: 24.0,
            bottom: 24.0 + MediaQuery.of(context).padding.bottom,
          ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Video Player dengan looping
              if (_isVideoInitialized)
                Container(
                  height: 200,
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: lightGreenText.withOpacity(0.5),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: _videoController.value.size.width,
                        height: _videoController.value.size.height,
                        child: VideoPlayer(_videoController),
                      ),
                    ),
                  ),
                )
              else
                Container(
                  height: 200,
                  margin: const EdgeInsets.only(bottom: 24.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: lightGreenText.withOpacity(0.5),
                      width: 2,
                    ),
                    color: darkGreenBg,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(color: lightGreenText),
                  ),
                ),
              Text(
                'Berat Badan (kg)',
                style: TextStyle(fontSize: 16, color: lightGreenText),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _weightController,
                style: TextStyle(color: lightGreenText),
                keyboardType: TextInputType.number, // Memastikan input numerik
                decoration: InputDecoration(
                  hintText: 'Contoh: 65.5',
                  hintStyle: TextStyle(color: lightGreenText.withOpacity(0.6)),
                  filled: true,
                  fillColor: darkGreenBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: lightGreenText),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: lightGreenText),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: lightGreenText, width: 2.0),
                  ),
                  errorStyle: TextStyle(color: Colors.redAccent),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    _playErrorSound();
                    // Pastikan video tetap berjalan setelah validator error
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_isVideoInitialized &&
                          !_videoController.value.isPlaying) {
                        _videoController.play();
                      }
                    });
                    return 'Berat badan tidak boleh kosong';
                  }
                  final weight = double.tryParse(value);
                  if (weight == null) {
                    _playErrorSound();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_isVideoInitialized &&
                          !_videoController.value.isPlaying) {
                        _videoController.play();
                      }
                    });
                    return 'Masukkan angka yang valid';
                  }
                  if (weight < 20) {
                    _playErrorSound();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_isVideoInitialized &&
                          !_videoController.value.isPlaying) {
                        _videoController.play();
                      }
                    });
                    return 'Berat badan minimal 20 kg';
                  }
                  if (weight > 200) {
                    _playErrorSound();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_isVideoInitialized &&
                          !_videoController.value.isPlaying) {
                        _videoController.play();
                      }
                    });
                    return 'Berat badan maksimal 200 kg';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final double weight = double.parse(
                        _weightController.text,
                      );
                      widget.onWeightAdded(weight);
                      if (mounted) {
                        Navigator.pop(context);
                      }
                    } else {
                      // Pastikan video tetap berjalan jika validasi gagal
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_isVideoInitialized &&
                            !_videoController.value.isPlaying) {
                          _videoController.play();
                        }
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: lightGreenText,
                    foregroundColor: darkText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Catat Berat Badan',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
