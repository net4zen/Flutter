/// API base URLs and endpoint paths.
/// All network addresses are centralised here — never scattered across widgets.
class ApiConstants {
  ApiConstants._();

  /// Open-Meteo weather forecast endpoint.
  static const String forecastBaseUrl = 'https://api.open-meteo.com';
  static const String forecastPath = '/v1/forecast';

  /// Open-Meteo geocoding (city search) endpoint.
  static const String geocodingBaseUrl = 'https://geocoding-api.open-meteo.com';
  static const String geocodingPath = '/v1/search';

  /// Comma-separated list of current weather variables to request.
  static const String currentVariables =
      'temperature_2m,'
      'apparent_temperature,'
      'relative_humidity_2m,'
      'weather_code,'
      'wind_speed_10m,'
      'precipitation,'
      'is_day,'
      'surface_pressure,'
      'visibility';

  /// Number of geocoding results to return.
  static const int geocodingCount = 10;

  /// Timeout durations.
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
