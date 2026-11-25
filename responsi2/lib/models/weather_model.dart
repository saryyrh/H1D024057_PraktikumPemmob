/// Model data cuaca lengkap dari Open-Meteo Forecast API,
/// mencakup data cuaca saat ini (current) dan prakiraan harian (daily).
class WeatherModel {
  final CurrentWeather current;
  final List<DailyWeather> daily;

  const WeatherModel({
    required this.current,
    required this.daily,
  });

  /// Parsing JSON dari endpoint /v1/forecast Open-Meteo.
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>? ?? {};
    final dailyJson = json['daily'] as Map<String, dynamic>? ?? {};

    final times = List<String>.from(dailyJson['time'] ?? []);
    final maxTemps = List<dynamic>.from(dailyJson['temperature_2m_max'] ?? []);
    final minTemps = List<dynamic>.from(dailyJson['temperature_2m_min'] ?? []);
    final rainProbs =
        List<dynamic>.from(dailyJson['precipitation_probability_max'] ?? []);
    final weatherCodes = List<dynamic>.from(dailyJson['weather_code'] ?? []);

    final List<DailyWeather> dailyList = [];
    for (int i = 0; i < times.length; i++) {
      dailyList.add(
        DailyWeather(
          time: times[i],
          temperatureMax:
              i < maxTemps.length && maxTemps[i] != null
                  ? (maxTemps[i] as num).toDouble()
                  : 0.0,
          temperatureMin:
              i < minTemps.length && minTemps[i] != null
                  ? (minTemps[i] as num).toDouble()
                  : 0.0,
          precipitationProbabilityMax:
              i < rainProbs.length && rainProbs[i] != null
                  ? (rainProbs[i] as num).toInt()
                  : 0,
          weatherCode:
              i < weatherCodes.length && weatherCodes[i] != null
                  ? (weatherCodes[i] as num).toInt()
                  : 0,
        ),
      );
    }

    return WeatherModel(
      current: CurrentWeather.fromJson(currentJson),
      daily: dailyList,
    );
  }
}

/// Model data cuaca terkini (current).
class CurrentWeather {
  final double temperature;
  final int relativeHumidity;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;

  const CurrentWeather({
    required this.temperature,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature:
          (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Model data prakiraan cuaca harian (daily).
class DailyWeather {
  final String time;
  final double temperatureMax;
  final double temperatureMin;
  final int precipitationProbabilityMax;
  final int weatherCode;

  const DailyWeather({
    required this.time,
    required this.temperatureMax,
    required this.temperatureMin,
    required this.precipitationProbabilityMax,
    required this.weatherCode,
  });
}
