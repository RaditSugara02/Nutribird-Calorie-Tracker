import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class PermissionHelper {
  /// Request permission untuk akses galeri
  /// Mengembalikan true jika permission diberikan, false jika ditolak
  static Future<bool> requestGalleryPermission(BuildContext context) async {
    // Cek permission status terlebih dahulu
    PermissionStatus status;
    
    // Untuk Android 13+ (API 33+), gunakan photos (READ_MEDIA_IMAGES)
    // Untuk Android 12 dan sebelumnya, gunakan storage (READ_EXTERNAL_STORAGE)
    // Untuk iOS, gunakan photos
    try {
      // Coba dengan photos permission terlebih dahulu (untuk Android 13+ dan iOS)
      status = await Permission.photos.status;
      if (status.isDenied) {
        status = await Permission.photos.request();
      }
      
      // Jika photos permission tidak granted dan kita di Android, coba storage
      if (!status.isGranted && Platform.isAndroid) {
        status = await Permission.storage.status;
        if (status.isDenied) {
          status = await Permission.storage.request();
        }
      }
    } catch (e) {
      // Jika ada error dengan photos, coba dengan storage permission (untuk Android versi lama)
      status = await Permission.storage.status;
      if (status.isDenied) {
        status = await Permission.storage.request();
      }
    }

    // Jika permission ditolak secara permanen, tampilkan dialog
    if (status.isPermanentlyDenied) {
      final shouldOpen = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Izin Diperlukan'),
            content: const Text(
              'Aplikasi memerlukan akses ke galeri foto untuk memilih gambar. '
              'Silakan aktifkan izin di Pengaturan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Buka Pengaturan'),
              ),
            ],
          );
        },
      );

      if (shouldOpen == true) {
        await openAppSettings();
        return false;
      }
      return false;
    }

    return status.isGranted;
  }

  /// Request permission untuk akses kamera
  static Future<bool> requestCameraPermission(BuildContext context) async {
    PermissionStatus status = await Permission.camera.status;
    
    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isPermanentlyDenied) {
      final shouldOpen = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Izin Diperlukan'),
            content: const Text(
              'Aplikasi memerlukan akses ke kamera untuk mengambil foto. '
              'Silakan aktifkan izin di Pengaturan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Buka Pengaturan'),
              ),
            ],
          );
        },
      );

      if (shouldOpen == true) {
        await openAppSettings();
        return false;
      }
      return false;
    }

    return status.isGranted;
  }
}

