import '../../data/models/weather_model.dart';
import '../../data/models/location_model.dart';

/// Describes every possible state the weather screen can be in.
///
/// Using a sealed class (union type) makes it impossible to represent an
/// impossible state (e.g. "loading=true but also has data").
///
/// States:
/// 1. [WeatherInitialLoading]   — first launch, no cache, fetching.
/// 2. [WeatherSuccess]          — fresh data displayed.
/// 3. [WeatherInitialError]     — first launch failed with no prior data.
/// 4. [WeatherRefreshing]       — user requested refresh; old data still shown.
/// 5. [WeatherRefreshError]     — refresh failed; old data still shown.
/// 6. [WeatherCached]           — showing stale cached data (offline startup).
sealed class WeatherState {
  const WeatherState();
}

/// First-launch loading with no cached data to show.
class WeatherInitialLoading extends WeatherState {
  const WeatherInitialLoading();
}

/// Successfully loaded fresh weather data.
class WeatherSuccess extends WeatherState {
  const WeatherSuccess(this.weather);
  final WeatherModel weather;
}

/// Initial load failed and there is no cached data to fall back to.
class WeatherInitialError extends WeatherState {
  const WeatherInitialError(this.message);
  final String message;
}

/// Refreshing — existing weather data is still shown.
class WeatherRefreshing extends WeatherState {
  const WeatherRefreshing(this.weather);
  final WeatherModel weather;
}

/// Refresh failed — existing weather data is preserved, error is surfaced
/// non-blocking (e.g. SnackBar).
class WeatherRefreshError extends WeatherState {
  const WeatherRefreshError({required this.weather, required this.message});
  final WeatherModel weather;
  final String message;
}

/// Showing stale cached data because the app started offline.
class WeatherCached extends WeatherState {
  const WeatherCached({required this.weather, this.refreshError});
  final WeatherModel weather;

  /// Non-null if a background refresh was attempted and failed.
  final String? refreshError;
}

/// Extension helpers for conveniently extracting weather from any state.
extension WeatherStateX on WeatherState {
  /// Returns the [WeatherModel] if this state holds one, otherwise null.
  WeatherModel? get weatherOrNull => switch (this) {
    WeatherSuccess(weather: final w) => w,
    WeatherRefreshing(weather: final w) => w,
    WeatherRefreshError(weather: final w) => w,
    WeatherCached(weather: final w) => w,
    _ => null,
  };

  /// True when a network operation is in progress.
  bool get isLoading => switch (this) {
    WeatherInitialLoading() => true,
    WeatherRefreshing() => true,
    _ => false,
  };

  /// True when the displayed data came from the local cache (stale).
  bool get isFromCache => this is WeatherCached;

  /// Returns the selected [LocationModel] if available.
  LocationModel? get locationOrNull => weatherOrNull?.location;
}
