import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/location_model.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/utils/weather_helper.dart';

void main() {
  test('WeatherHelper menerjemahkan kode WMO dengan benar', () {
    expect(WeatherHelper.getWeatherDescription(0), 'Cerah');
    expect(WeatherHelper.getWeatherDescription(3), 'Berawan');
    expect(WeatherHelper.getWeatherDescription(61), 'Hujan');
    expect(WeatherHelper.getWeatherDescription(95), 'Hujan Petir');
  });

  test('LocationModel parsing JSON dan Map berfungsi', () {
    final json = {
      'name': 'Purbalingga',
      'admin1': 'Jawa Tengah',
      'country': 'Indonesia',
      'latitude': -7.3881,
      'longitude': 109.3639,
    };
    final loc = LocationModel.fromJson(json);
    expect(loc.name, 'Purbalingga');
    expect(loc.region, 'Jawa Tengah');

    final fromMap = LocationModel.fromMap(loc.toMap());
    expect(fromMap, loc);
  });

  test('WeatherModel parsing JSON Open-Meteo berfungsi', () {
    final json = {
      'current': {
        'temperature_2m': 28.5,
        'relative_humidity_2m': 78,
        'apparent_temperature': 31.0,
        'precipitation': 0.2,
        'weather_code': 2,
        'wind_speed_10m': 10.4,
      },
      'daily': {
        'time': ['2026-11-25'],
        'temperature_2m_max': [31.5],
        'temperature_2m_min': [23.0],
        'precipitation_probability_max': [60],
        'weather_code': [61],
      },
    };
    final weather = WeatherModel.fromJson(json);
    expect(weather.current.temperature, 28.5);
    expect(weather.current.relativeHumidity, 78);
    expect(weather.daily.length, 1);
    expect(weather.daily.first.precipitationProbabilityMax, 60);
  });
}
