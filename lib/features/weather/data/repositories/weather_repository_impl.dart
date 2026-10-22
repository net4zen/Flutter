import '../datasources/weather_local_datasource.dart';
import '../datasources/weather_remote_datasource.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';
import 'weather_repository.dart';

/// Concrete implementation of [WeatherRepository].
///
/// Coordinates between the remote API and the local cache:
/// - On fetch: always tries remote first, falls back gracefully.
/// - On success: updates cache.
/// - Corrupt cache: silently discarded.
class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl({
    required WeatherRemoteDataSource remoteDataSource,
    required WeatherLocalDataSource localDataSource,
  }) : _remote = remoteDataSource,
       _local = localDataSource;

  final WeatherRemoteDataSource _remote;
  final WeatherLocalDataSource _local;

  @override
  Future<WeatherModel?> getCachedWeather() => _local.getCachedWeather();

  @override
  Future<WeatherModel> fetchWeather(LocationModel location) async {
    // Let AppExceptions propagate — the notifier handles them.
    final weather = await _remote.fetchWeather(location);
    // Persist successful result.
    await _local.cacheWeather(weather);
    return weather;
  }

  @override
  Future<List<LocationModel>> searchLocations(String query) {
    return _remote.searchLocations(query);
  }
}
