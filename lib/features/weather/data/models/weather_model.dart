import 'dart:convert';

import 'location_model.dart';

/// Full weather data model returned by the Open-Meteo Forecast API.
///
/// Includes the selected [location] so the cache stores everything needed
/// to re-display the screen without additional API calls.
class WeatherModel {
  final LocationModel location;
  final double temperature;
  final double apparentTemperature;
  final int humidity;
  final int weatherCode;
  final double windSpeed;
  final double precipitation;
  final bool isDay;
  final double? surfacePressure;
  final double? visibility;

  /// ISO-8601 timestamp of the weather observation (from the API `time` field).
  final String observationTime;

  /// [DateTime] at which this model was fetched/cached locally.
  final DateTime fetchedAt;

  const WeatherModel({
    required this.location,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.weatherCode,
    required this.windSpeed,
    required this.precipitation,
    required this.isDay,
    this.surfacePressure,
    this.visibility,
    required this.observationTime,
    required this.fetchedAt,
  });

  /// Parses the full Open-Meteo forecast API response JSON and a [location].
  factory WeatherModel.fromApiJson(
    Map<String, dynamic> json,
    LocationModel location,
  ) {
    final current = json['current'] as Map<String, dynamic>?;
    if (current == null) {
      throw const FormatException('Missing "current" field in API response');
    }

    return WeatherModel(
      location: location,
      temperature: _toDouble(current['temperature_2m']),
      apparentTemperature: _toDouble(current['apparent_temperature']),
      humidity: _toInt(current['relative_humidity_2m']),
      weatherCode: _toInt(current['weather_code']),
      windSpeed: _toDouble(current['wind_speed_10m']),
      precipitation: _toDouble(current['precipitation']),
      isDay: _toInt(current['is_day']) == 1,
      surfacePressure: current['surface_pressure'] != null
          ? _toDouble(current['surface_pressure'])
          : null,
      visibility: current['visibility'] != null
          ? _toDouble(current['visibility'])
          : null,
      observationTime: current['time'] as String? ?? '',
      fetchedAt: DateTime.now(),
    );
  }

  // ─── Cache serialization ───────────────────────────────────────────────────

  /// Serializes to a JSON string for SharedPreferences storage.
  String toCacheJson() => jsonEncode(toJson());

  /// Deserializes from a cached JSON string.
  /// Returns null if the JSON is missing or malformed.
  static WeatherModel? fromCacheJson(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return WeatherModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
    'location': location.toJson(),
    'temperature': temperature,
    'apparent_temperature': apparentTemperature,
    'humidity': humidity,
    'weather_code': weatherCode,
    'wind_speed': windSpeed,
    'precipitation': precipitation,
    'is_day': isDay,
    'surface_pressure': surfacePressure,
    'visibility': visibility,
    'observation_time': observationTime,
    'fetched_at': fetchedAt.toIso8601String(),
  };

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      location: LocationModel.fromJson(
        json['location'] as Map<String, dynamic>,
      ),
      temperature: _toDouble(json['temperature']),
      apparentTemperature: _toDouble(json['apparent_temperature']),
      humidity: _toInt(json['humidity']),
      weatherCode: _toInt(json['weather_code']),
      windSpeed: _toDouble(json['wind_speed']),
      precipitation: _toDouble(json['precipitation']),
      isDay: json['is_day'] as bool? ?? true,
      surfacePressure: json['surface_pressure'] != null
          ? _toDouble(json['surface_pressure'])
          : null,
      visibility: json['visibility'] != null
          ? _toDouble(json['visibility'])
          : null,
      observationTime: json['observation_time'] as String? ?? '',
      fetchedAt:
          DateTime.tryParse(json['fetched_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    return (value as num).toDouble();
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    return (value as num).toInt();
  }

  /// Creates a copy with updated fields — used to swap location without
  /// repeating all weather data.
  WeatherModel copyWith({
    LocationModel? location,
    double? temperature,
    double? apparentTemperature,
    int? humidity,
    int? weatherCode,
    double? windSpeed,
    double? precipitation,
    bool? isDay,
    double? surfacePressure,
    double? visibility,
    String? observationTime,
    DateTime? fetchedAt,
  }) {
    return WeatherModel(
      location: location ?? this.location,
      temperature: temperature ?? this.temperature,
      apparentTemperature: apparentTemperature ?? this.apparentTemperature,
      humidity: humidity ?? this.humidity,
      weatherCode: weatherCode ?? this.weatherCode,
      windSpeed: windSpeed ?? this.windSpeed,
      precipitation: precipitation ?? this.precipitation,
      isDay: isDay ?? this.isDay,
      surfacePressure: surfacePressure ?? this.surfacePressure,
      visibility: visibility ?? this.visibility,
      observationTime: observationTime ?? this.observationTime,
      fetchedAt: fetchedAt ?? this.fetchedAt,
    );
  }

  @override
  String toString() =>
      'WeatherModel(location: ${location.name}, temp: $temperature°C)';
}
