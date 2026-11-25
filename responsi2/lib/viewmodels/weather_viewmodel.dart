import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

/// ViewModel utama yang mengelola state cuaca, pencarian kota, dan penyimpanan lokal.
class WeatherViewModel extends ChangeNotifier {
  final WeatherService _weatherService = WeatherService();

  static const String _favoritesKey = 'favorite_locations';
  static const String _lastLocationKey = 'last_selected_location';

  bool isLoading = false;
  bool isSearching = false;
  String? errorMessage;
  String? searchErrorMessage;

  WeatherModel? currentWeather;
  LocationModel selectedLocation = LocationModel.defaultLocation;
  List<LocationModel> searchResults = [];
  List<LocationModel> favoriteLocations = [];

  WeatherViewModel() {
    _init();
  }

  /// Inisialisasi awal: memuat daftar favorit dan lokasi terakhir dari SharedPreferences,
  /// lalu mengambil data cuaca (fallback ke Purbalingga jika belum ada lokasi tersimpan).
  Future<void> _init() async {
    await loadFavorites();
    await _loadLastLocation();
    await fetchWeather(selectedLocation);
  }

  /// Memuat daftar kota favorit yang tersimpan di SharedPreferences.
  Future<void> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_favoritesKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        favoriteLocations = decoded
            .map((item) => LocationModel.fromMap(item as Map<String, dynamic>))
            .toList();
        notifyListeners();
      }
    } catch (_) {
      favoriteLocations = [];
    }
  }

  /// Menyimpan daftar kota favorit ke SharedPreferences dalam bentuk JSON string.
  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      favoriteLocations.map((loc) => loc.toMap()).toList(),
    );
    await prefs.setString(_favoritesKey, encoded);
  }

  /// Memuat lokasi terakhir yang dipilih pengguna dari SharedPreferences.
  Future<void> _loadLastLocation() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_lastLocationKey);
      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(jsonString);
        selectedLocation = LocationModel.fromMap(decoded);
      } else {
        selectedLocation = LocationModel.defaultLocation;
      }
    } catch (_) {
      selectedLocation = LocationModel.defaultLocation;
    }
  }

  /// Menyimpan lokasi terakhir yang dipilih agar langsung tampil saat aplikasi dibuka kembali.
  Future<void> _saveLastLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastLocationKey, jsonEncode(location.toMap()));
  }

  /// Mengecek apakah suatu lokasi sudah ada di dalam daftar kota favorit.
  bool isFavorite(LocationModel location) {
    return favoriteLocations.contains(location);
  }

  /// Menambah atau menghapus lokasi dari daftar favorit dan menyimpannya ke SharedPreferences.
  Future<void> toggleFavorite(LocationModel location) async {
    if (isFavorite(location)) {
      favoriteLocations.removeWhere((item) => item == location);
    } else {
      favoriteLocations.add(location);
    }
    notifyListeners();
    await _saveFavorites();
  }

  /// Mengambil data cuaca dari Open-Meteo untuk lokasi tertentu dan menyimpan lokasi tersebut.
  Future<void> fetchWeather(LocationModel location) async {
    selectedLocation = location;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    await _saveLastLocation(location);

    try {
      currentWeather = await _weatherService.fetchWeather(
        latitude: location.latitude,
        longitude: location.longitude,
      );
    } catch (e) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Mencari kota menggunakan Geocoding API berdasarkan teks pencarian dari pengguna.
  Future<void> searchCity(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      searchResults = [];
      searchErrorMessage = null;
      isSearching = false;
      notifyListeners();
      return;
    }

    isSearching = true;
    searchErrorMessage = null;
    notifyListeners();

    try {
      final results = await _weatherService.searchCities(trimmed);
      searchResults = results;
      if (results.isEmpty) {
        searchErrorMessage = 'Kota "$trimmed" tidak ditemukan.';
      }
    } catch (e) {
      searchResults = [];
      searchErrorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isSearching = false;
      notifyListeners();
    }
  }

  /// Membersihkan hasil pencarian saat pengguna mengosongkan kolom input atau keluar halaman.
  void clearSearch() {
    searchResults = [];
    searchErrorMessage = null;
    isSearching = false;
    notifyListeners();
  }
}
