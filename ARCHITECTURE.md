# ARCHITECTURE.md — Weatherly

## Overview

Weatherly uses a clean, layered architecture with strict separation of concerns. Each layer has a single responsibility and communicates through well-defined interfaces.

---

## Architecture Diagram

```
┌─────────────────────────────────────────────────┐
│                    USER                         │
└───────────────────────┬─────────────────────────┘
                        │ taps / swipes
┌───────────────────────▼─────────────────────────┐
│           PRESENTATION LAYER                    │
│  SplashScreen  WeatherScreen  SearchBarWidget   │
│  WeatherHeaderWidget  WeatherMetricCard         │
│  WeatherLoadingWidget  WeatherErrorWidget       │
│  LocationButtonWidget                           │
└───────────────────────┬─────────────────────────┘
                        │ watches state / calls actions
┌───────────────────────▼─────────────────────────┐
│         RIVERPOD STATE LAYER                    │
│  WeatherNotifier   SearchNotifier               │
│  LocationNotifier                               │
│  (StateNotifier providers)                      │
└───────────────────────┬─────────────────────────┘
                        │ delegates to
┌───────────────────────▼─────────────────────────┐
│           REPOSITORY LAYER                      │
│  WeatherRepositoryImpl                          │
│  (implements WeatherRepository interface)       │
└──────────┬────────────────────────┬─────────────┘
           │                        │
┌──────────▼─────────┐  ┌──────────▼─────────────┐
│  REMOTE DATASOURCE │  │  LOCAL DATASOURCE       │
│  WeatherRemote     │  │  WeatherLocal           │
│  DataSource        │  │  DataSource             │
│  (Dio + Open-Meteo)│  │  (SharedPreferences)    │
└────────────────────┘  └─────────────────────────┘
```

---

## State Flow

### 6-State Weather Lifecycle

```
App Launch
    │
    ▼
getCachedWeather()
    │
    ├─► Cache exists ──────────────────────────────────────┐
    │                                                       │
    ▼                                                       ▼
WeatherInitialLoading                               WeatherCached(weather)
    │                                                       │
    ▼                                                       │ background refresh
fetchWeather(defaultCity)                                   │
    │                                              ┌────────▼─────────┐
    ├─► success ──► WeatherSuccess(weather)        │  fetchWeather()   │
    │                                              └──┬───────────┬───┘
    └─► failure ──► WeatherInitialError            success      failure
                                                      │              │
                                                 WeatherSuccess  WeatherCached
                                                                 (refreshError)
```

### Refresh Flow

```
User triggers refresh (button tap OR pull-to-refresh)
    │
    ▼
existing weather? ─── no ──► WeatherInitialLoading → _fetchDefault()
    │
   yes
    │
    ▼
WeatherRefreshing(existingWeather)  ← OLD DATA STILL VISIBLE
    │
    ▼
fetchWeather(currentLocation)
    │
    ├─► success ──► WeatherSuccess(freshWeather)   ← update cache
    │
    └─► failure ──► WeatherRefreshError(           ← OLD DATA PRESERVED
                        weather: existingWeather,
                        message: userFriendlyError
                    )
                        │
                        ▼
                    SnackBar shown (non-blocking)
                    App stays interactive
                    Retry possible
```

---

## API Request Flow

### Weather Fetch

```
WeatherNotifier.refresh()
    │
    ▼
WeatherRepositoryImpl.fetchWeather(location)
    │
    ▼
WeatherRemoteDataSource.fetchWeather(location)
    │
    ▼
Dio GET api.open-meteo.com/v1/forecast
    ?latitude={lat}&longitude={lon}
    &current=temperature_2m,apparent_temperature,...
    &timezone=auto
    │
    ├─► 200 OK ─► WeatherModel.fromApiJson(json, location)
    │                   │
    │                   ▼
    │             WeatherRepositoryImpl caches result
    │                   │
    │                   ▼
    │             Return WeatherModel to notifier
    │
    └─► error ─► DioClient.mapException(e) → AppException subtype
                      │
                      ▼
                 Re-thrown to WeatherNotifier
                      │
                      ▼
                 State → WeatherRefreshError (if data) or WeatherInitialError
```

### City Search Flow

```
User types in SearchBarWidget
    │
    ▼ (debounced 500ms)
SearchNotifier.onQueryChanged(query)
    │
    ▼
SearchState → SearchLoading
    │
    ▼
WeatherRepositoryImpl.searchLocations(query)
    │
    ▼
WeatherRemoteDataSource.searchLocations(query)
    │
    ▼
Dio GET geocoding-api.open-meteo.com/v1/search
    ?name={query}&count=10&language=en
    │
    ├─► results → SearchSuccess(List<LocationModel>)
    ├─► empty  → SearchEmpty()
    └─► error  → SearchError(message)
```

---

## Cache Flow

```
App Launch
    │
    ▼
WeatherLocalDataSource.getCachedWeather()
    │
    ├─► SharedPreferences.getString('cached_weather_data')
    │       │
    │       ├─► null / empty → return null
    │       ├─► valid JSON   → WeatherModel.fromJson(decoded)
    │       └─► corrupt JSON → catch + return null (never crash)
    │
    └─► Result returned to WeatherRepositoryImpl
            │
            └─► Forwarded to WeatherNotifier._initialLoad()

On successful API response:
    WeatherRepositoryImpl.fetchWeather()
        │
        ▼
    WeatherLocalDataSource.cacheWeather(weather)
        │
        ▼
    SharedPreferences.setString(
        'cached_weather_data',
        weather.toCacheJson()
    )
```

---

## Error Flow

```
Network / API error occurs
    │
    ▼
DioClient.mapException(error)
    │
    ├─► DioExceptionType.connectionTimeout   → TimeoutException
    ├─► DioExceptionType.connectionError     → NoInternetException
    ├─► DioExceptionType.unknown (Socket)    → NoInternetException
    ├─► HTTP 429                             → RateLimitException
    ├─► HTTP 4xx/5xx                         → ServerException
    ├─► JSON parse failure                   → ParseException
    └─► Other                                → UnknownException
                │
                ▼
        AppException subtype re-thrown
                │
                ▼
        WeatherNotifier catches AppException
                │
                ├─► has existing data → WeatherRefreshError(data, message)
                └─► no data          → WeatherInitialError(message)
                            │
                            ▼
                    UI renders user-friendly message
                    (Never exposes stack traces or HTTP details)
```

---

## Provider Dependency Graph

```
weatherNotifierProvider
    └── weatherRepositoryProvider
            ├── weatherRemoteDataSourceProvider  (Dio clients)
            └── weatherLocalDataSourceProvider   (SharedPreferences)

searchNotifierProvider (autoDispose)
    └── weatherRepositoryProvider

locationNotifierProvider
    └── (Geolocator — no provider dependency)
```

---

## Key Design Decisions

### 1. Sealed WeatherState
Using a sealed class guarantees all state variants are handled exhaustively in `switch` expressions. The compiler enforces completeness — no missed case.

### 2. Refresh-Failure Data Preservation
`WeatherRefreshError` carries the **previous** `WeatherModel`. This means the UI switch simply renders the old data in both `WeatherRefreshing` and `WeatherRefreshError` states — no special case logic needed in widgets.

### 3. StateNotifier Over AsyncNotifier
`AsyncNotifier` collapses all states into a three-value (`loading/data/error`) model. The 6-state requirement necessitates a custom `StateNotifier` with a sealed class.

### 4. Debounce in SearchNotifier
500ms debounce avoids hammering the geocoding API on every keystroke. The `onSubmit` path bypasses the debounce for immediate keyboard-confirmed searches.

### 5. Repository Coordinates Cache
The repository (not the notifier or datasource) is responsible for writing to cache after a successful fetch. This keeps the notifier ignorant of persistence details.

### 6. DioClient as a Mapper
`DioClient.mapException()` is a static utility that maps every possible Dio error to an `AppException`. This centralises the mapping logic so datasources stay focused on HTTP concerns only.
