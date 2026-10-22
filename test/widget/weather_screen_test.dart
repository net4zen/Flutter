import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:weatherly/core/errors/app_exception.dart';
import 'package:weatherly/features/weather/data/models/location_model.dart';
import 'package:weatherly/features/weather/data/models/weather_model.dart';
import 'package:weatherly/features/weather/data/repositories/weather_repository.dart';
import 'package:weatherly/features/weather/presentation/providers/weather_notifier.dart';
import 'package:weatherly/features/weather/presentation/screens/weather_screen.dart';
import 'package:weatherly/features/weather/presentation/widgets/weather_loading_widget.dart';
import 'package:weatherly/features/weather/presentation/widgets/weather_error_widget.dart';
import 'package:weatherly/app/theme/app_theme.dart';

@GenerateMocks([WeatherRepository])
import 'weather_screen_test.mocks.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────

const _testLocation = LocationModel(
  id: 1,
  name: 'TestCity',
  latitude: 0,
  longitude: 0,
  country: 'TestCountry',
);

WeatherModel _makeWeather() => WeatherModel(
  location: _testLocation,
  temperature: 22.0,
  apparentTemperature: 20.0,
  humidity: 55,
  weatherCode: 0,
  windSpeed: 12.0,
  precipitation: 0.0,
  isDay: true,
  observationTime: '2025-01-01T12:00',
  fetchedAt: DateTime(2025, 1, 1, 12),
);

/// Wraps [WeatherScreen] with the providers overridden to inject [mockRepo].
Widget _buildApp(MockWeatherRepository mockRepo) {
  return ProviderScope(
    overrides: [weatherRepositoryProvider.overrideWithValue(mockRepo)],
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: const WeatherScreen(),
    ),
  );
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  late MockWeatherRepository mockRepo;

  setUp(() {
    mockRepo = MockWeatherRepository();
  });

  group('WeatherScreen — loading state', () {
    testWidgets('shows loading widget while initial fetch is in progress', (
      tester,
    ) async {
      when(mockRepo.getCachedWeather()).thenAnswer((_) async => null);
      // Return a future that never completes during this test by using a
      // Completer — avoids the pending-timer assertion from the test binding.
      when(mockRepo.fetchWeather(any))
          .thenAnswer((_) => Completer<WeatherModel>().future);

      await tester.pumpWidget(_buildApp(mockRepo));
      // Pump once so the microtask fires but the fetch hasn't resolved.
      await tester.pump();

      expect(find.byType(WeatherLoadingWidget), findsOneWidget);
    });
  });

  group('WeatherScreen — success state', () {
    testWidgets('displays weather data when fetch succeeds', (tester) async {
      final weather = _makeWeather();
      when(mockRepo.getCachedWeather()).thenAnswer((_) async => null);
      when(mockRepo.fetchWeather(any)).thenAnswer((_) async => weather);

      await tester.pumpWidget(_buildApp(mockRepo));
      // Let async settle.
      await tester.pumpAndSettle();

      // Temperature should appear.
      expect(find.textContaining('22°C'), findsWidgets);
      // City name in header or app bar.
      expect(find.textContaining('TestCity'), findsWidgets);
    });

    testWidgets('refresh button is present', (tester) async {
      final weather = _makeWeather();
      when(mockRepo.getCachedWeather()).thenAnswer((_) async => null);
      when(mockRepo.fetchWeather(any)).thenAnswer((_) async => weather);

      await tester.pumpWidget(_buildApp(mockRepo));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh_rounded), findsOneWidget);
    });

    testWidgets('search icon is present', (tester) async {
      final weather = _makeWeather();
      when(mockRepo.getCachedWeather()).thenAnswer((_) async => null);
      when(mockRepo.fetchWeather(any)).thenAnswer((_) async => weather);

      await tester.pumpWidget(_buildApp(mockRepo));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });
  });

  group('WeatherScreen — error state (no data)', () {
    testWidgets('shows error widget when initial fetch fails', (tester) async {
      when(mockRepo.getCachedWeather()).thenAnswer((_) async => null);
      when(mockRepo.fetchWeather(any)).thenThrow(const NoInternetException());

      await tester.pumpWidget(_buildApp(mockRepo));
      await tester.pumpAndSettle();

      expect(find.byType(WeatherErrorWidget), findsOneWidget);
    });

    testWidgets('error widget contains a retry button', (tester) async {
      when(mockRepo.getCachedWeather()).thenAnswer((_) async => null);
      when(mockRepo.fetchWeather(any)).thenThrow(const ServerException());

      await tester.pumpWidget(_buildApp(mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Try Again'), findsOneWidget);
    });
  });

  group('WeatherScreen — refresh failure keeps existing data (CRITICAL)', () {
    testWidgets('existing weather remains visible after refresh failure', (
      tester,
    ) async {
      final weather = _makeWeather();
      // Initial load succeeds.
      when(mockRepo.getCachedWeather()).thenAnswer((_) async => null);
      when(mockRepo.fetchWeather(any)).thenAnswer((_) async => weather);

      await tester.pumpWidget(_buildApp(mockRepo));
      await tester.pumpAndSettle();

      // Verify we have weather data on screen.
      expect(find.textContaining('22°C'), findsWidgets);

      // Now make refresh fail.
      when(mockRepo.fetchWeather(any)).thenThrow(const TimeoutException());

      // Tap refresh button.
      await tester.tap(find.byIcon(Icons.refresh_rounded));
      await tester.pumpAndSettle();

      // Weather data must STILL be visible.
      expect(find.textContaining('22°C'), findsWidgets);
      // No full-screen error widget should have replaced the data.
      expect(find.byType(WeatherErrorWidget), findsNothing);
      // SnackBar should appear.
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  group('WeatherScreen — search interaction', () {
    testWidgets('tapping search icon shows search field', (tester) async {
      final weather = _makeWeather();
      when(mockRepo.getCachedWeather()).thenAnswer((_) async => null);
      when(mockRepo.fetchWeather(any)).thenAnswer((_) async => weather);

      await tester.pumpWidget(_buildApp(mockRepo));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('tapping cancel hides search field', (tester) async {
      final weather = _makeWeather();
      when(mockRepo.getCachedWeather()).thenAnswer((_) async => null);
      when(mockRepo.fetchWeather(any)).thenAnswer((_) async => weather);

      await tester.pumpWidget(_buildApp(mockRepo));
      await tester.pumpAndSettle();

      // Open search.
      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pump();
      expect(find.byType(TextField), findsOneWidget);

      // Cancel.
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
    });
  });
}
