/// Application-level constants.
class AppConstants {
  AppConstants._();

  /// SharedPreferences key used to persist the last successful weather response.
  static const String cachedWeatherKey = 'cached_weather_data';

  /// Minimum search query length before firing a geocoding request.
  static const int minSearchLength = 2;

  /// Debounce delay for the search field (ms).
  static const int searchDebounceMs = 500;

  /// App display name used in UI strings.
  static const String appName = 'Weatherly';

  /// Default city shown on first launch if there is no cache and GPS is denied.
  static const String defaultCityName = 'London';
  static const double defaultLatitude = 51.5074;
  static const double defaultLongitude = -0.1278;
  static const String defaultCountry = 'United Kingdom';
}
