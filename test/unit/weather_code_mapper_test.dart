import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weatherly/core/utils/weather_code_mapper.dart';

void main() {
  group('WeatherCodeMapper', () {
    group('fromCode - day conditions', () {
      test('code 0 → Clear Sky with sunny icon', () {
        final info = WeatherCodeMapper.fromCode(0, isDay: true);
        expect(info.condition, 'Clear Sky');
        expect(info.icon, Icons.wb_sunny_rounded);
      });

      test('code 0 night → Clear Night with moon icon', () {
        final info = WeatherCodeMapper.fromCode(0, isDay: false);
        expect(info.condition, 'Clear Night');
        expect(info.icon, Icons.nightlight_round);
      });

      test('code 2 → Partly Cloudy', () {
        final info = WeatherCodeMapper.fromCode(2);
        expect(info.condition, 'Partly Cloudy');
      });

      test('code 3 → Overcast', () {
        final info = WeatherCodeMapper.fromCode(3);
        expect(info.condition, 'Overcast');
        expect(info.icon, Icons.cloud_rounded);
      });

      test('code 45 → Foggy', () {
        final info = WeatherCodeMapper.fromCode(45);
        expect(info.condition, 'Foggy');
        expect(info.icon, Icons.foggy);
      });

      test('code 48 → Foggy (depositing rime fog)', () {
        final info = WeatherCodeMapper.fromCode(48);
        expect(info.condition, 'Foggy');
      });

      test('code 51 → Light Drizzle', () {
        final info = WeatherCodeMapper.fromCode(51);
        expect(info.condition, 'Light Drizzle');
      });

      test('code 61 → Light Rain', () {
        final info = WeatherCodeMapper.fromCode(61);
        expect(info.condition, 'Light Rain');
        expect(info.icon, Icons.water_drop_outlined);
      });

      test('code 63 → Rain', () {
        final info = WeatherCodeMapper.fromCode(63);
        expect(info.condition, 'Rain');
      });

      test('code 65 → Heavy Rain', () {
        final info = WeatherCodeMapper.fromCode(65);
        expect(info.condition, 'Heavy Rain');
        expect(info.icon, Icons.water_drop_rounded);
      });

      test('code 71 → Light Snow', () {
        final info = WeatherCodeMapper.fromCode(71);
        expect(info.condition, 'Light Snow');
        expect(info.icon, Icons.cloudy_snowing);
      });

      test('code 80 → Light Showers', () {
        final info = WeatherCodeMapper.fromCode(80);
        expect(info.condition, 'Light Showers');
        expect(info.icon, Icons.shower_rounded);
      });

      test('code 95 → Thunderstorm', () {
        final info = WeatherCodeMapper.fromCode(95);
        expect(info.condition, 'Thunderstorm');
        expect(info.icon, Icons.thunderstorm_rounded);
      });

      test('code 96 → Thunderstorm with Hail', () {
        final info = WeatherCodeMapper.fromCode(96);
        expect(info.condition, 'Thunderstorm with Hail');
      });

      test('code 66 → Light Freezing Rain', () {
        final info = WeatherCodeMapper.fromCode(66);
        expect(info.condition, 'Light Freezing Rain');
        expect(info.icon, Icons.ac_unit_rounded);
      });

      test('unknown code → Unknown with fallback icon', () {
        final info = WeatherCodeMapper.fromCode(999);
        expect(info.condition, 'Unknown');
        expect(info.icon, Icons.help_outline_rounded);
      });
    });

    group('gradientForCode', () {
      test('clear day returns blue gradient', () {
        final gradient = WeatherCodeMapper.gradientForCode(0, isDay: true);
        expect(gradient.length, 2);
        expect(gradient[0], const Color(0xFF1B6CA8));
      });

      test('night returns dark gradient regardless of code', () {
        final gradient = WeatherCodeMapper.gradientForCode(0, isDay: false);
        expect(gradient[0], const Color(0xFF0D1B2A));
      });

      test('thunderstorm returns dark gradient', () {
        final gradient = WeatherCodeMapper.gradientForCode(95, isDay: true);
        expect(gradient[0], const Color(0xFF212121));
      });
    });

    group('WeatherInfo properties', () {
      test('all mapped codes have non-empty condition and description', () {
        final testCodes = [
          0,
          1,
          2,
          3,
          45,
          48,
          51,
          53,
          55,
          56,
          57,
          61,
          63,
          65,
          66,
          67,
          71,
          73,
          75,
          77,
          80,
          81,
          82,
          85,
          86,
          95,
          96,
          99,
        ];
        for (final code in testCodes) {
          final info = WeatherCodeMapper.fromCode(code);
          expect(
            info.condition.isNotEmpty,
            isTrue,
            reason: 'Code $code should have a condition',
          );
          expect(
            info.description.isNotEmpty,
            isTrue,
            reason: 'Code $code should have a description',
          );
        }
      });
    });
  });
}
