import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/weather_model.dart';

/// Local data source — reads and writes the weather cache in SharedPreferences.
///
/// Uses a single JSON-encoded string for simplicity. Corrupt or missing data
/// is handled gracefully (returns null rather than throwing).
class WeatherLocalDataSource {
  WeatherLocalDataSource({this._prefs});

  SharedPreferences? _prefs;

  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Returns the last cached [WeatherModel], or null if none exists or the
  /// stored JSON is corrupt/missing.
  Future<WeatherModel?> getCachedWeather() async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(AppConstants.cachedWeatherKey);
      return WeatherModel.fromCacheJson(raw);
    } catch (_) {
      // Never crash the app because of a bad cache read.
      return null;
    }
  }

  /// Persists [weather] to SharedPreferences.
  Future<void> cacheWeather(WeatherModel weather) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(
        AppConstants.cachedWeatherKey,
        weather.toCacheJson(),
      );
    } catch (_) {
      // Cache write failure is non-fatal — the UI can still operate.
    }
  }

  /// Removes any cached weather data.
  Future<void> clearCache() async {
    try {
      final prefs = await _getPrefs();
      await prefs.remove(AppConstants.cachedWeatherKey);
    } catch (_) {
      // Non-fatal.
    }
  }
}
