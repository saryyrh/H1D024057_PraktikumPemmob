import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/location_model.dart';
import '../models/weather_model.dart';

/// Service untuk berkomunikasi dengan REST API Open-Meteo (Geocoding & Forecast).
class WeatherService {
  static const String _geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String _forecastBaseUrl =
      'https://api.open-meteo.com/v1/forecast';

  /// Mencari daftar kota berdasarkan kata kunci menggunakan Open-Meteo Geocoding API.
  Future<List<LocationModel>> searchCities(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return [];

    final uri = Uri.parse(_geocodingBaseUrl).replace(
      queryParameters: {
        'name': trimmedQuery,
        'count': '10',
        'language': 'id',
        'format': 'json',
      },
    );

    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final results = data['results'] as List<dynamic>?;
        if (results == null || results.isEmpty) {
          return [];
        }
        return results
            .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception(
          'Gagal mencari lokasi (Kode status: ${response.statusCode}).',
        );
      }
    } on SocketException {
      throw Exception(
        'Tidak ada koneksi internet. Periksa jaringan Anda lalu coba lagi.',
      );
    } on TimeoutException {
      throw Exception(
        'Waktu koneksi habis saat mencari kota. Silakan coba lagi.',
      );
    } on FormatException {
      throw Exception('Format data lokasi dari server tidak valid.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan saat mencari kota: $e');
    }
  }

  /// Mengambil data cuaca terkini dan prakiraan harian dari Open-Meteo Forecast API.
  Future<WeatherModel> fetchWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.parse(_forecastBaseUrl).replace(
      queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m',
        'daily':
            'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
        'timezone': 'auto',
      },
    );

    try {
      final response = await http.get(uri).timeout(
        const Duration(seconds: 15),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return WeatherModel.fromJson(data);
      } else {
        throw Exception(
          'Gagal memuat data cuaca dari server (Kode status: ${response.statusCode}).',
        );
      }
    } on SocketException {
      throw Exception(
        'Tidak ada koneksi internet. Pastikan Wi-Fi atau data seluler aktif.',
      );
    } on TimeoutException {
      throw Exception(
        'Koneksi ke server cuaca terlalu lama. Silakan coba lagi.',
      );
    } on FormatException {
      throw Exception('Data cuaca dari server tidak dapat dibaca.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Terjadi kesalahan saat mengambil data cuaca: $e');
    }
  }
}
