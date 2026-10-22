import '../models/location_model.dart';
import '../models/weather_model.dart';

/// Contract for the weather repository.
///
/// Defined here in the data layer for simplicity. In a larger project this
/// would live in a separate domain layer.
abstract interface class WeatherRepository {
  /// Returns cached weather immediately if available, otherwise fetches live.
  Future<WeatherModel?> getCachedWeather();

  /// Fetches live weather for [location] and updates the cache on success.
  Future<WeatherModel> fetchWeather(LocationModel location);

  /// Searches for cities matching [query] using the geocoding API.
  Future<List<LocationModel>> searchLocations(String query);
}
