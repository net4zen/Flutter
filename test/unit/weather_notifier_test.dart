import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weatherly/core/errors/app_exception.dart';
import 'package:weatherly/features/weather/data/models/location_model.dart';
import 'package:weatherly/features/weather/data/models/weather_model.dart';
import 'package:weatherly/features/weather/data/repositories/weather_repository.dart';
import 'package:weatherly/features/weather/presentation/providers/weather_notifier.dart';
import 'package:weatherly/features/weather/presentation/providers/weather_state.dart';

@GenerateMocks([WeatherRepository])
import 'weather_notifier_test.mocks.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

WeatherModel makeWeather({String cityName = 'TestCity'}) {
  final location = LocationModel(
    id: 1,
    name: cityName,
    latitude: 0,
    longitude: 0,
    country: 'TestCountry',
  );
  return WeatherModel(
    location: location,
    temperature: 20.0,
    apparentTemperature: 18.0,
    humidity: 60,
    weatherCode: 0,
    windSpeed: 10.0,
    precipitation: 0.0,
    isDay: true,
    observationTime: '2025-01-01T12:00',
    fetchedAt: DateTime(2025, 1, 1, 12),
  );
}

/// Creates a [ProviderContainer] with [mockRepo] injected.
ProviderContainer makeContainer(MockWeatherRepository mockRepo) {
  final container = ProviderContainer(
    overrides: [weatherRepositoryProvider.overrideWithValue(mockRepo)],
  );
  // Eagerly read the provider to trigger build() / _initialLoad.
  container.read(weatherNotifierProvider);
  return container;
}

/// Waits until the notifier leaves the initial loading state.
Future<void> waitForLoad(ProviderContainer container) async {
  // Pump the event loop long enough for the microtask + async fetch to settle.
  for (var i = 0; i < 50; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (container.read(weatherNotifierProvider) is! WeatherInitialLoading) {
      break;
    }
  }
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late MockWeatherRepository mockRepo;

  setUp(() {
    mockRepo = MockWeatherRepository();
  });

  group('WeatherNotifier — initial load', () {
    test(
      'transitions to WeatherSuccess when no cache and fetch succeeds',
      () async {
        final weather = makeWeather();
        when(mockRepo.getCachedWeather()).thenAnswer((_) async => null);
        when(mockRepo.fetchWeather(any)).thenAnswer((_) async => weather);

        final container = makeContainer(mockRepo);
        await waitForLoad(container);
        addTearDown(container.dispose);

        expect(container.read(weatherNotifierProvider), isA<WeatherSuccess>());
        expect(
          (container.read(
            weatherNotifierProvider,
          ) as WeatherSuccess).weather.location.name,
          'TestCity',
        );
      },
    );

    test(
      'transitions to WeatherInitialError when no cache and fetch fails',
      () async {
        when(mockRepo.getCachedWeather()).thenAnswer((_) async => null);
        when(mockRepo.fetchWeather(any)).thenThrow(const NoInternetException());

        final container = makeContainer(mockRepo);
        await waitForLoad(container);
        addTearDown(container.dispose);

        final state = container.read(weatherNotifierProvider);
        expect(state, isA<WeatherInitialError>());
        expect((state as WeatherInitialError).message, isNotEmpty);
      },
    );

    test('shows WeatherCached or WeatherSuccess when cache exists', () async {
      final cached = makeWeather(cityName: 'Cached City');
      when(mockRepo.getCachedWeather()).thenAnswer((_) async => cached);
      when(mockRepo.fetchWeather(any)).thenAnswer((_) async => cached);

      final container = makeContainer(mockRepo);
      await waitForLoad(container);
      addTearDown(container.dispose);

      final state = container.read(weatherNotifierProvider);
      expect(state, anyOf(isA<WeatherCached>(), isA<WeatherSuccess>()));
    });
  });

  group('WeatherNotifier — refresh (CRITICAL: data preserved on failure)', () {
    test(
      'refresh failure keeps existing weather and emits WeatherRefreshError',
      () async {
        final weather = makeWeather();
        when(mockRepo.getCachedWeather()).thenAnswer((_) async => null);
        when(mockRepo.fetchWeather(any)).thenAnswer((_) async => weather);

        final container = makeContainer(mockRepo);
        await waitForLoad(container);

        expect(container.read(weatherNotifierProvider), isA<WeatherSuccess>());
        final originalName = (container.read(
          weatherNotifierProvider,
        ) as WeatherSuccess).weather.location.name;

        // Next fetch fails.
        when(mockRepo.fetchWeather(any)).thenThrow(const TimeoutException());

        await container.read(weatherNotifierProvider.notifier).refresh();

        final state = container.read(weatherNotifierProvider);

        // CRITICAL: old data must be preserved.
        expect(state, isA<WeatherRefreshError>());
        expect(
          (state as WeatherRefreshError).weather.location.name,
          originalName,
        );
        expect(state.message, isNotEmpty);

        container.dispose();
      },
    );

    test('successful refresh updates state to WeatherSuccess', () async {
      final weather = makeWeather();
      when(mockRepo.getCachedWeather()).thenAnswer((_) async => null);
      when(mockRepo.fetchWeather(any)).thenAnswer((_) async => weather);

      final container = makeContainer(mockRepo);
      await waitForLoad(container);

      final fresh = makeWeather();
      when(mockRepo.fetchWeather(any)).thenAnswer((_) async => fresh);
      await container.read(weatherNotifierProvider.notifier).refresh();

      expect(container.read(weatherNotifierProvider), isA<WeatherSuccess>());
      container.dispose();
    });

    test('duplicate refresh calls are no-ops while refreshing', () async {
      final weather = makeWeather();
      when(mockRepo.getCachedWeather()).thenAnswer((_) async => null);
      when(mockRepo.fetchWeather(any)).thenAnswer((_) async => weather);

      final container = makeContainer(mockRepo);
      await waitForLoad(container);

      // Count: one call for the initial load.
      verify(mockRepo.fetchWeather(any)).called(1);

      // Slow refresh.
      when(mockRepo.fetchWeather(any)).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        return weather;
      });

      final notifier = container.read(weatherNotifierProvider.notifier);
      // First refresh — proceeds.
      final first = notifier.refresh();
      // Second refresh while first is in-flight — should be no-op.
      await notifier.refresh();
      await first;

      // Exactly one slow fetchWeather should have been made.
      verify(mockRepo.fetchWeather(any)).called(1);
      container.dispose();
    });
  });

  group('WeatherNotifier — loadWeatherForLocation', () {
    test('success updates state to WeatherSuccess with new location', () async {
      when(mockRepo.getCachedWeather()).thenAnswer((_) async => null);
      when(mockRepo.fetchWeather(any)).thenAnswer((_) async => makeWeather());

      final container = makeContainer(mockRepo);
      await waitForLoad(container);

      const newLoc = LocationModel(
        id: 2,
        name: 'Paris',
        latitude: 48.85,
        longitude: 2.35,
        country: 'France',
      );
      final parisWeather = WeatherModel(
        location: newLoc,
        temperature: 25.0,
        apparentTemperature: 23.0,
        humidity: 55,
        weatherCode: 2,
        windSpeed: 8.0,
        precipitation: 0.0,
        isDay: true,
        observationTime: '2025-01-01T14:00',
        fetchedAt: DateTime.now(),
      );

      when(mockRepo.fetchWeather(any)).thenAnswer((_) async => parisWeather);
      await container
          .read(weatherNotifierProvider.notifier)
          .loadWeatherForLocation(newLoc);

      final state = container.read(weatherNotifierProvider);
      expect(state, isA<WeatherSuccess>());
      expect((state as WeatherSuccess).weather.location.name, 'Paris');
      container.dispose();
    });
  });
}
