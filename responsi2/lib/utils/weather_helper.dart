import 'package:flutter/material.dart';

/// Kelas helper untuk menerjemahkan kode cuaca WMO (0–99) ke deskripsi
/// Bahasa Indonesia, ikon Material yang sesuai, serta format nama hari.
class WeatherHelper {
  /// Mengembalikan deskripsi kondisi cuaca dalam Bahasa Indonesia berdasarkan kode WMO.
  static String getWeatherDescription(int code) {
    if (code == 0) {
      return 'Cerah';
    } else if (code == 1) {
      return 'Cerah Berawan';
    } else if (code == 2) {
      return 'Berawan Sebagian';
    } else if (code == 3) {
      return 'Berawan';
    } else if (code == 45 || code == 48) {
      return 'Berkabut';
    } else if (code >= 51 && code <= 55) {
      return 'Gerimis';
    } else if (code == 56 || code == 57) {
      return 'Gerimis Beku';
    } else if (code >= 61 && code <= 65) {
      return 'Hujan';
    } else if (code == 66 || code == 67) {
      return 'Hujan Beku';
    } else if (code >= 71 && code <= 77) {
      return 'Salju';
    } else if (code >= 80 && code <= 82) {
      return 'Hujan Deras';
    } else if (code == 85 || code == 86) {
      return 'Hujan Salju';
    } else if (code == 95) {
      return 'Hujan Petir';
    } else if (code == 96 || code == 99) {
      return 'Hujan Petir & Es';
    }
    return 'Tidak Diketahui';
  }

  /// Mengembalikan ikon Material bawaan yang sesuai dengan kode cuaca WMO.
  static IconData getWeatherIcon(int code) {
    if (code == 0) {
      return Icons.wb_sunny_rounded;
    } else if (code == 1 || code == 2) {
      return Icons.wb_cloudy_rounded;
    } else if (code == 3) {
      return Icons.cloud_rounded;
    } else if (code == 45 || code == 48) {
      return Icons.foggy;
    } else if ((code >= 51 && code <= 57) || (code >= 61 && code <= 67)) {
      return Icons.grain_rounded;
    } else if (code >= 71 && code <= 77 || code == 85 || code == 86) {
      return Icons.ac_unit_rounded;
    } else if (code >= 80 && code <= 82) {
      return Icons.water_drop_rounded;
    } else if (code >= 95 && code <= 99) {
      return Icons.thunderstorm_rounded;
    }
    return Icons.cloud_queue_rounded;
  }

  /// Mengubah string tanggal (YYYY-MM-DD) menjadi nama hari dalam Bahasa Indonesia.
  static String formatDayName(String dateString, {int index = -1}) {
    if (index == 0) return 'Hari Ini';
    if (index == 1) return 'Besok';

    final parsed = DateTime.tryParse(dateString);
    if (parsed == null) return dateString;

    const days = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return days[parsed.weekday - 1];
  }
}
