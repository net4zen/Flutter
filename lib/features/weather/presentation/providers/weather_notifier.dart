import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/weather_local_datasource.dart';
import '../../data/datasources/weather_remote_datasource.dart';
import '../../data/models/location_model.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../data/repositories/weather_repository.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import 'weather_state.dart';

// ─── Providers ────────────────────────────────────────────────────────────────

/// Provides the [WeatherRemoteDataSource]. Overridable in tests.
final weatherRemoteDataSourceProvider = Provider<WeatherRemoteDataSource>((
  ref,
) {
  return WeatherRemoteDataSource();
});

/// Provides the [WeatherLocalDataSource]. Overridable in tests.
final weatherLocalDataSourceProvider = Provider<WeatherLocalDataSource>((ref) {
  return WeatherLocalDataSource();
});

/// Provides the [WeatherRepository].
final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return WeatherRepositoryImpl(
    remoteDataSource: ref.watch(weatherRemoteDataSourceProvider),
    localDataSource: ref.watch(weatherLocalDataSourceProvider),
  );
});

/// The main provider that drives the weather screen.
final weatherNotifierProvider = NotifierProvider<WeatherNotifier, WeatherState>(
  WeatherNotifier.new,
);

// ─── Notifier ─────────────────────────────────────────────────────────────────

/// Controls weather data loading, refreshing, searching and caching.
///
/// IMPORTANT refresh-failure contract:
/// If existing weather data is already shown and a refresh fails:
///   → state becomes [WeatherRefreshError] (keeps old data visible)
///   → UI shows a non-blocking SnackBar error
///   → UI stays interactive
class WeatherNotifier extends Notifier<WeatherState> {
  bool _isFetching = false;

  @override
  WeatherState build() {
    // Schedule initial load after build returns so the initial state is
    // synchronously returned first. We cancel/guard via ref.mounted.
    Future.microtask(_initialLoad);
    return const WeatherInitialLoading();
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  /// Safe state setter — no-ops if the provider has been disposed.
  void _setState(WeatherState next) {
    if (!ref.mounted) return;
    state = next;
  }

  WeatherRepository get _repo => ref.read(weatherRepositoryProvider);

  // ─── Initial load ──────────────────────────────────────────────────────────

  Future<void> _initialLoad() async {
    if (!ref.mounted) return;

    final cached = await _repo.getCachedWeather();
    if (!ref.mounted) return;

    if (cached != null) {
      _setState(WeatherCached(weather: cached));
      await _backgroundRefresh(cached.location);
    } else {
      await _fetchDefault();
    }
  }

  Future<void> _backgroundRefresh(LocationModel location) async {
    if (_isFetching || !ref.mounted) return;
    _isFetching = true;
    try {
      final fresh = await _repo.fetchWeather(location);
      if (!ref.mounted) return;
      _setState(WeatherSuccess(fresh));
    } on AppException catch (e) {
      if (!ref.mounted) return;
      final current = state.weatherOrNull;
      if (current != null) {
        _setState(WeatherCached(weather: current, refreshError: e.message));
      }
    } finally {
      _isFetching = false;
    }
  }

  Future<void> _fetchDefault() async {
    _isFetching = true;
    if (!ref.mounted) {
      _isFetching = false;
      return;
    }
    final defaultLocation = LocationModel(
      id: 0,
      name: AppConstants.defaultCityName,
      latitude: AppConstants.defaultLatitude,
      longitude: AppConstants.defaultLongitude,
      country: AppConstants.defaultCountry,
    );
    try {
      final weather = await _repo.fetchWeather(defaultLocation);
      _setState(WeatherSuccess(weather));
    } on AppException catch (e) {
      _setState(WeatherInitialError(e.message));
    } finally {
      _isFetching = false;
    }
  }

  // ─── Public actions ────────────────────────────────────────────────────────

  Future<void> loadWeatherForLocation(LocationModel location) async {
    if (_isFetching || !ref.mounted) return;
    _isFetching = true;

    final existing = state.weatherOrNull;
    if (existing != null) {
      _setState(WeatherRefreshing(existing.copyWith(location: location)));
    } else {
      _setState(const WeatherInitialLoading());
    }

    try {
      final weather = await _repo.fetchWeather(location);
      _setState(WeatherSuccess(weather));
    } on AppException catch (e) {
      if (existing != null) {
        _setState(WeatherRefreshError(weather: existing, message: e.message));
      } else {
        _setState(WeatherInitialError(e.message));
      }
    } finally {
      _isFetching = false;
    }
  }

  Future<void> refresh() async {
    if (_isFetching || !ref.mounted) return;
    final current = state.weatherOrNull;
    if (current == null) {
      _setState(const WeatherInitialLoading());
      await _fetchDefault();
      return;
    }

    _isFetching = true;
    _setState(WeatherRefreshing(current));

    try {
      final fresh = await _repo.fetchWeather(current.location);
      _setState(WeatherSuccess(fresh));
    } on AppException catch (e) {
      _setState(WeatherRefreshError(weather: current, message: e.message));
    } finally {
      _isFetching = false;
    }
  }

  Future<void> retryInitialLoad() async {
    if (_isFetching || !ref.mounted) return;
    _setState(const WeatherInitialLoading());
    await _fetchDefault();
  }

  Future<void> loadWeatherForCoordinates(
    double latitude,
    double longitude,
  ) async {
    if (_isFetching || !ref.mounted) return;
    _isFetching = true;

    final gpsLocation = LocationModel(
      id: -1,
      name: 'Current Location',
      latitude: latitude,
      longitude: longitude,
      country: '',
    );

    final existing = state.weatherOrNull;
    if (existing != null) {
      _setState(WeatherRefreshing(existing.copyWith(location: gpsLocation)));
    } else {
      _setState(const WeatherInitialLoading());
    }

    try {
      final weather = await _repo.fetchWeather(gpsLocation);
      _setState(WeatherSuccess(weather));
    } on AppException catch (e) {
      if (existing != null) {
        // Use a GPS-specific message so the user understands it was the
        // location weather fetch that failed, not a general service outage.
        _setState(WeatherRefreshError(
          weather: existing,
          message: "Couldn't get weather for your current location. ${e.message}",
        ));
      } else {
        _setState(WeatherInitialError(e.message));
      }
    } finally {
      _isFetching = false;
    }
  }
}
