import 'package:flutter_test/flutter_test.dart';
import 'package:weatherly/features/weather/data/models/weather_model.dart';
import 'package:weatherly/features/weather/data/models/location_model.dart';

void main() {
  group('LocationModel', () {
    final sampleJson = {
      'id': 1,
      'name': 'Berlin',
      'latitude': 52.52,
      'longitude': 13.41,
      'country': 'Germany',
      'admin1': 'Berlin',
      'country_code': 'DE',
    };

    test('fromJson parses all fields correctly', () {
      final location = LocationModel.fromJson(sampleJson);
      expect(location.id, 1);
      expect(location.name, 'Berlin');
      expect(location.latitude, 52.52);
      expect(location.longitude, 13.41);
      expect(location.country, 'Germany');
      expect(location.admin1, 'Berlin');
      expect(location.countryCode, 'DE');
    });

    test('toJson round-trips correctly', () {
      final original = LocationModel.fromJson(sampleJson);
      final json = original.toJson();
      final restored = LocationModel.fromJson(json);
      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.latitude, original.latitude);
    });

    test('subtitle includes admin1 and country', () {
      final location = LocationModel.fromJson(sampleJson);
      expect(location.subtitle, 'Berlin, Germany');
    });

    test('subtitle handles missing admin1', () {
      final json = {...sampleJson, 'admin1': null};
      final location = LocationModel.fromJson(json);
      expect(location.subtitle, 'Germany');
    });

    test('equality is based on id', () {
      final a = LocationModel.fromJson(sampleJson);
      final b = LocationModel.fromJson({...sampleJson, 'name': 'Other'});
      expect(a, equals(b)); // Same id → equal
    });
  });

  group('WeatherModel', () {
    late LocationModel location;

    setUp(() {
      location = const LocationModel(
        id: 1,
        name: 'Berlin',
        latitude: 52.52,
        longitude: 13.41,
        country: 'Germany',
      );
    });

    final sampleApiJson = {
      'current': {
        'time': '2025-09-24T12:00',
        'temperature_2m': 20.5,
        'apparent_temperature': 18.0,
        'relative_humidity_2m': 65,
        'weather_code': 1,
        'wind_speed_10m': 15.2,
        'precipitation': 0.0,
        'is_day': 1,
        'surface_pressure': 1013.0,
        'visibility': 10000.0,
      },
    };

    test('fromApiJson parses all fields correctly', () {
      final model = WeatherModel.fromApiJson(sampleApiJson, location);
      expect(model.temperature, 20.5);
      expect(model.apparentTemperature, 18.0);
      expect(model.humidity, 65);
      expect(model.weatherCode, 1);
      expect(model.windSpeed, 15.2);
      expect(model.precipitation, 0.0);
      expect(model.isDay, isTrue);
      expect(model.surfacePressure, 1013.0);
      expect(model.visibility, 10000.0);
      expect(model.observationTime, '2025-09-24T12:00');
      expect(model.location.name, 'Berlin');
    });

    test('fromApiJson throws FormatException on missing current field', () {
      expect(
        () => WeatherModel.fromApiJson({}, location),
        throwsA(isA<FormatException>()),
      );
    });

    test('fromApiJson handles is_day = 0 as false', () {
      final json = {
        'current': {
          ...sampleApiJson['current'] as Map<String, dynamic>,
          'is_day': 0,
        },
      };
      final model = WeatherModel.fromApiJson(json, location);
      expect(model.isDay, isFalse);
    });

    group('Cache serialization', () {
      test('toCacheJson → fromCacheJson round-trips correctly', () {
        final original = WeatherModel.fromApiJson(sampleApiJson, location);
        final json = original.toCacheJson();
        final restored = WeatherModel.fromCacheJson(json);

        expect(restored, isNotNull);
        expect(restored!.temperature, original.temperature);
        expect(restored.humidity, original.humidity);
        expect(restored.weatherCode, original.weatherCode);
        expect(restored.location.name, 'Berlin');
      });

      test('fromCacheJson returns null for null input', () {
        expect(WeatherModel.fromCacheJson(null), isNull);
      });

      test('fromCacheJson returns null for empty string', () {
        expect(WeatherModel.fromCacheJson(''), isNull);
      });

      test('fromCacheJson returns null for corrupt JSON', () {
        expect(WeatherModel.fromCacheJson('{bad json{{{{'), isNull);
      });

      test('fromCacheJson returns null for valid JSON missing fields', () {
        // Valid JSON but wrong structure — should not crash.
        expect(WeatherModel.fromCacheJson('{"foo": "bar"}'), isNull);
      });
    });

    group('copyWith', () {
      test('copyWith preserves unmodified fields', () {
        final original = WeatherModel.fromApiJson(sampleApiJson, location);
        final copied = original.copyWith(temperature: 99.9);
        expect(copied.temperature, 99.9);
        expect(copied.humidity, original.humidity);
        expect(copied.location, original.location);
      });
    });
  });
}
