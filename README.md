# Weatherly 🌤️

A professional Flutter weather application built as an internship coding assignment. Weatherly fetches real-time weather data using the free, open-source [Open-Meteo API](https://open-meteo.com/) — no API key required.

---

## Features

### Core
- 🌤️ **Real-time weather** — temperature, feels-like, humidity, wind speed, precipitation, pressure, visibility
- 🔍 **City search** — geocoding-backed search with debounce, suggestion list, and empty/error states
- 🔄 **Manual refresh** — dedicated refresh button in the app bar
- ↕️ **Pull-to-refresh** — swipe down on the weather screen
- ⚡ **Splash screen** — branded animated splash with smooth transition
- 🌙 **Day/Night indication** — condition icons and gradients adapt to day/night
- 📍 **Weather code mapping** — all WMO codes mapped to human-readable conditions

### State Management
- **Initial loading** with skeleton UI
- **Success** with full weather display
- **Refresh in progress** (existing data remains visible)
- **Refresh failure** — existing data preserved, non-blocking SnackBar error
- **Initial load failure** — full-screen error with retry

### Bonus Features
- 💾 **Local cache** — last successful response cached in SharedPreferences
- 📡 **Offline startup** — cached data shown immediately on app open; background refresh attempted
- 📍 **GPS location** — "Use my location" button using Geolocator (optional, permission-respecting)
- 🎨 **Light & Dark themes** — respects system theme preference
- 📱 **Responsive layout** — 2-column grid on phones, 3-column on tablets

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.47+ / Dart 3.13+ |
| State Management | Riverpod 3.x (StateNotifier) |
| HTTP Client | Dio 5.x |
| Local Cache | SharedPreferences |
| GPS | Geolocator 14.x |
| Date Formatting | intl |
| Testing | flutter_test + Mockito |

---

## Architecture Overview

```
lib/
├── main.dart                    # Entry point — ProviderScope
├── app/
│   ├── app.dart                 # Root MaterialApp with light/dark theme
│   └── theme/
│       └── app_theme.dart       # ThemeData + AppColors extension
├── core/
│   ├── constants/
│   │   ├── api_constants.dart   # Base URLs, paths, timeouts
│   │   └── app_constants.dart   # Cache keys, defaults, debounce
│   ├── errors/
│   │   └── app_exception.dart   # Sealed exception hierarchy
│   ├── network/
│   │   └── dio_client.dart      # Dio factory + exception mapping
│   └── utils/
│       └── weather_code_mapper.dart  # WMO code → condition/icon/gradient
└── features/
    ├── weather/
    │   ├── data/
    │   │   ├── models/          # WeatherModel, LocationModel (JSON + cache)
    │   │   ├── datasources/     # Remote (Dio) + Local (SharedPreferences)
    │   │   └── repositories/    # WeatherRepository interface + impl
    │   └── presentation/
    │       ├── providers/       # WeatherNotifier, SearchNotifier (Riverpod)
    │       ├── screens/         # SplashScreen, WeatherScreen
    │       └── widgets/         # All reusable UI components
    └── location/
        └── presentation/
            └── providers/       # LocationNotifier (Geolocator)
```

### Layer Responsibilities

```
UI (widgets/screens)
       ↓ reads state, calls actions
Riverpod Notifiers (WeatherNotifier, SearchNotifier, LocationNotifier)
       ↓ delegates to
Repository (WeatherRepositoryImpl)
       ↓ coordinates
Remote Datasource ←→ Local Datasource
(Dio/Open-Meteo)      (SharedPreferences)
```

---

## API Used

### Open-Meteo Forecast API
```
GET https://api.open-meteo.com/v1/forecast
  ?latitude={lat}
  &longitude={lon}
  &current=temperature_2m,apparent_temperature,relative_humidity_2m,
           weather_code,wind_speed_10m,precipitation,is_day,
           surface_pressure,visibility
  &wind_speed_unit=kmh
  &precipitation_unit=mm
  &timezone=auto
```

### Open-Meteo Geocoding API
```
GET https://geocoding-api.open-meteo.com/v1/search
  ?name={query}
  &count=10
  &language=en
  &format=json
```

### Why Open-Meteo?
- ✅ Completely free for non-commercial use
- ✅ No API key required
- ✅ High-quality global forecast data
- ✅ Separate geocoding API for city search
- ✅ Reliable, well-documented REST API
- ✅ Returns coordinates + WMO weather codes

---

## State Management Approach

**Riverpod StateNotifier** is used for all application state:

- `WeatherNotifier` — controls the 6-state weather lifecycle
- `SearchNotifier` — manages debounced city search with `autoDispose`
- `LocationNotifier` — handles GPS permission + coordinate retrieval

### WeatherState Sealed Class

```dart
sealed class WeatherState { ... }

WeatherInitialLoading   // First launch, no cache
WeatherSuccess          // Fresh data displayed
WeatherInitialError     // No data, no internet
WeatherRefreshing       // Refreshing (old data shown)
WeatherRefreshError     // Refresh failed (old data preserved!)
WeatherCached           // Stale cache shown (offline start)
```

**Critical rule implemented**: If a refresh fails while data is displayed, the state transitions to `WeatherRefreshError` which **keeps the existing WeatherModel** — the UI never blanks.

---

## Caching Strategy

1. **On successful fetch** → `WeatherModel.toCacheJson()` written to SharedPreferences
2. **On app launch** → `WeatherLocalDataSource.getCachedWeather()` read first
3. **Cache hit** → `WeatherCached` state shown immediately → background refresh
4. **Cache miss** → `WeatherInitialLoading` → fetch default city (London)
5. **Corrupt JSON** → `WeatherModel.fromCacheJson()` returns `null` safely (no crash)

---

## Error Handling Strategy

All errors flow through a typed `AppException` sealed hierarchy:

| Exception | Trigger | User Message |
|---|---|---|
| `NoInternetException` | No network / SocketException | "You're offline..." |
| `TimeoutException` | Dio timeout | "Request timed out..." |
| `RateLimitException` | HTTP 429 | "Weather service is busy..." |
| `ServerException` | HTTP 4xx/5xx | "Service temporarily unavailable..." |
| `ParseException` | Malformed JSON | "Unexpected data received..." |
| `NoCityResultsException` | Empty geocoding results | "Couldn't find that city..." |
| `LocationPermissionDeniedException` | Permission denied | User-friendly guidance |

Raw exceptions (DioException, SocketException) are **never exposed to the UI**.

---

## GPS / Location Behaviour

1. User taps "My Location" (📍 icon in app bar)
2. `LocationNotifier.requestLocation()` is called
3. Location services checked → permission requested
4. On success → `WeatherNotifier.loadWeatherForCoordinates(lat, lon)`
5. On failure → SnackBar with user-friendly guidance
6. Manual city search **always works** regardless of GPS

Reverse geocoding is intentionally omitted (avoids extra dependency). GPS-derived weather shows "Current Location" as city label.

---

## Setup Instructions

```bash
# 1. Clone the repository
git clone <repo-url>
cd weatherly

# 2. Install dependencies
flutter pub get

# 3. (Optional) Regenerate test mocks
dart run build_runner build --delete-conflicting-outputs
```

---

## Run Instructions

```bash
# Run on connected device or emulator
flutter run

# Run in release mode
flutter run --release
```

---

## Testing Instructions

```bash
# Run all tests
flutter test

# Run only unit tests
flutter test test/unit/

# Run only widget tests
flutter test test/widget/

# Run with coverage
flutter test --coverage
```

---

## Build Instructions

```bash
# Debug APK
flutter build apk

# Release APK (unsigned)
flutter build apk --release

# Release App Bundle
flutter build appbundle --release
```

---

## Code Quality

```bash
# Format all Dart code
flutter format .

# Static analysis
flutter analyze

# Check for outdated packages
flutter pub outdated
```

---

## Screenshots

> 📸 **Instructions for screenshots**:
> 1. Run `flutter run` on an Android device or emulator
> 2. Use `adb shell screencap -p /sdcard/screen.png && adb pull /sdcard/screen.png` to capture
> 3. Or use Android Studio → Device Manager → Screenshot button

| Screen | Description |
|---|---|
| Splash | Branded launch screen |
| Weather (day) | Full weather display with sunny gradient |
| Weather (night) | Dark gradient variant |
| Search | City search with suggestions |
| Error state | Network error with retry |
| Cached/Offline | Stale banner + cached data |

---

## Assumptions & Trade-offs

1. **No reverse geocoding** — GPS shows "Current Location" label. Adds clarity without requiring an extra package.
2. **Default city (London)** — Used on first launch when cache is empty and no GPS. Configurable via `AppConstants.defaultCityName`.
3. **StateNotifier over AsyncNotifier** — Provides more granular control over the 6 required states (including refresh-failure-with-data-preservation).
4. **Dio over http** — Better timeout control and interceptors for future logging/retry.
5. **No code generation for models** — Avoids mandatory build_runner for the app code itself; only test mocks require it.
6. **Single SharedPreferences key** — Simplest reliable approach; sufficient for this use case.

---

## Future Improvements

- [ ] Add 7-day forecast section
- [ ] Add hourly forecast chart
- [ ] Implement reverse geocoding for GPS coordinates
- [ ] Add `FutureProvider` for async provider initialization
- [ ] Unit conversion toggle (°C/°F, km/h/mph)
- [ ] Weather notifications / alerts
- [ ] Multiple saved cities
- [ ] Widget (home screen widget) support
- [ ] iOS-specific configuration and testing
- [ ] CI/CD pipeline with automated testing
