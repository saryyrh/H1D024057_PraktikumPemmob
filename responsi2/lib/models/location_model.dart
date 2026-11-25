/// Model data untuk merepresentasikan lokasi/kota dari Open-Meteo Geocoding API
/// maupun yang disimpan di penyimpanan lokal (SharedPreferences).
class LocationModel {
  final String name;
  final String region;
  final String country;
  final double latitude;
  final double longitude;

  const LocationModel({
    required this.name,
    required this.region,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  /// Lokasi bawaan saat aplikasi pertama kali dibuka (Purbalingga, Jawa Tengah).
  static const LocationModel defaultLocation = LocationModel(
    name: 'Purbalingga',
    region: 'Jawa Tengah',
    country: 'Indonesia',
    latitude: -7.3881,
    longitude: 109.3639,
  );

  /// Membuat instance LocationModel dari respons JSON Open-Meteo Geocoding API.
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      name: (json['name'] ?? 'Tidak Diketahui').toString(),
      region: (json['admin1'] ?? json['region'] ?? '').toString(),
      country: (json['country'] ?? '').toString(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  /// Mengubah LocationModel menjadi format JSON.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'region': region,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Membuat instance LocationModel dari Map (untuk SharedPreferences).
  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      name: (map['name'] ?? 'Tidak Diketahui').toString(),
      region: (map['region'] ?? map['admin1'] ?? '').toString(),
      country: (map['country'] ?? '').toString(),
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
    );
  }

  /// Mengubah LocationModel menjadi Map (untuk SharedPreferences).
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'region': region,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Teks wilayah lengkap untuk ditampilkan di UI.
  String get subtitle {
    final parts = <String>[];
    if (region.isNotEmpty) parts.add(region);
    if (country.isNotEmpty) parts.add(country);
    return parts.join(', ');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LocationModel &&
        other.name == name &&
        (other.latitude - latitude).abs() < 0.001 &&
        (other.longitude - longitude).abs() < 0.001;
  }

  @override
  int get hashCode => Object.hash(
        name,
        latitude.toStringAsFixed(3),
        longitude.toStringAsFixed(3),
      );
}
