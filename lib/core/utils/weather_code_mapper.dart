import 'package:flutter/material.dart';

/// Maps WMO weather codes to human-readable condition text and Material icons.
///
/// All weather-code logic is centralised here. No widget should contain
/// switch/if logic based on a weather code — call this mapper instead.
///
/// Reference: https://open-meteo.com/en/docs (WMO Weather interpretation codes)
class WeatherCodeMapper {
  WeatherCodeMapper._();

  /// Returns a [WeatherInfo] for the given WMO [code].
  /// [isDay] controls day/night icon variation where available.
  static WeatherInfo fromCode(int code, {bool isDay = true}) {
    return switch (code) {
      // Clear sky
      0 => WeatherInfo(
        condition: isDay ? 'Clear Sky' : 'Clear Night',
        icon: isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round,
        description: isDay
            ? 'Bright sunshine with clear skies'
            : 'Clear skies overnight',
      ),

      // Mainly clear
      1 => WeatherInfo(
        condition: isDay ? 'Mainly Clear' : 'Mostly Clear',
        icon: isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round,
        description: 'Mostly clear with some haze',
      ),

      // Partly cloudy
      2 => WeatherInfo(
        condition: 'Partly Cloudy',
        icon: isDay ? Icons.wb_cloudy_rounded : Icons.cloud_outlined,
        description: 'A mix of sun and clouds',
      ),

      // Overcast
      3 => WeatherInfo(
        condition: 'Overcast',
        icon: Icons.cloud_rounded,
        description: 'Completely covered by clouds',
      ),

      // Fog
      45 || 48 => WeatherInfo(
        condition: 'Foggy',
        icon: Icons.foggy,
        description: 'Low visibility due to fog',
      ),

      // Light drizzle
      51 => WeatherInfo(
        condition: 'Light Drizzle',
        icon: Icons.grain_rounded,
        description: 'Light drizzle falling',
      ),

      // Moderate drizzle
      53 => WeatherInfo(
        condition: 'Drizzle',
        icon: Icons.grain_rounded,
        description: 'Moderate drizzle',
      ),

      // Heavy drizzle
      55 => WeatherInfo(
        condition: 'Heavy Drizzle',
        icon: Icons.grain_rounded,
        description: 'Dense drizzle',
      ),

      // Light freezing drizzle
      56 => WeatherInfo(
        condition: 'Light Freezing Drizzle',
        icon: Icons.ac_unit_rounded,
        description: 'Light freezing drizzle — icy conditions possible',
      ),

      // Heavy freezing drizzle
      57 => WeatherInfo(
        condition: 'Freezing Drizzle',
        icon: Icons.ac_unit_rounded,
        description: 'Heavy freezing drizzle — icy conditions likely',
      ),

      // Slight rain
      61 => WeatherInfo(
        condition: 'Light Rain',
        icon: Icons.water_drop_outlined,
        description: 'Light rain showers',
      ),

      // Moderate rain
      63 => WeatherInfo(
        condition: 'Rain',
        icon: Icons.water_drop_rounded,
        description: 'Moderate rainfall',
      ),

      // Heavy rain
      65 => WeatherInfo(
        condition: 'Heavy Rain',
        icon: Icons.water_drop_rounded,
        description: 'Heavy and persistent rain',
      ),

      // Light freezing rain
      66 => WeatherInfo(
        condition: 'Light Freezing Rain',
        icon: Icons.ac_unit_rounded,
        description: 'Light freezing rain — slippery conditions',
      ),

      // Heavy freezing rain
      67 => WeatherInfo(
        condition: 'Freezing Rain',
        icon: Icons.ac_unit_rounded,
        description: 'Heavy freezing rain',
      ),

      // Slight snow fall
      71 => WeatherInfo(
        condition: 'Light Snow',
        icon: Icons.cloudy_snowing,
        description: 'Light snowfall',
      ),

      // Moderate snow fall
      73 => WeatherInfo(
        condition: 'Snow',
        icon: Icons.cloudy_snowing,
        description: 'Moderate snowfall',
      ),

      // Heavy snow fall
      75 => WeatherInfo(
        condition: 'Heavy Snow',
        icon: Icons.cloudy_snowing,
        description: 'Heavy snowfall',
      ),

      // Snow grains
      77 => WeatherInfo(
        condition: 'Snow Grains',
        icon: Icons.ac_unit_rounded,
        description: 'Freezing precipitation in small ice crystals',
      ),

      // Slight rain showers
      80 => WeatherInfo(
        condition: 'Light Showers',
        icon: Icons.shower_rounded,
        description: 'Light intermittent rain showers',
      ),

      // Moderate rain showers
      81 => WeatherInfo(
        condition: 'Rain Showers',
        icon: Icons.shower_rounded,
        description: 'Moderate rain showers',
      ),

      // Violent rain showers
      82 => WeatherInfo(
        condition: 'Heavy Showers',
        icon: Icons.shower_rounded,
        description: 'Violent rain showers',
      ),

      // Slight snow showers
      85 => WeatherInfo(
        condition: 'Light Snow Showers',
        icon: Icons.cloudy_snowing,
        description: 'Light snow showers',
      ),

      // Heavy snow showers
      86 => WeatherInfo(
        condition: 'Snow Showers',
        icon: Icons.cloudy_snowing,
        description: 'Heavy snow showers',
      ),

      // Thunderstorm (slight/moderate)
      95 => WeatherInfo(
        condition: 'Thunderstorm',
        icon: Icons.thunderstorm_rounded,
        description: 'Thunderstorm with lightning',
      ),

      // Thunderstorm with hail
      96 || 99 => WeatherInfo(
        condition: 'Thunderstorm with Hail',
        icon: Icons.thunderstorm_rounded,
        description: 'Severe thunderstorm with hail',
      ),

      // Unknown / future codes
      _ => WeatherInfo(
        condition: 'Unknown',
        icon: Icons.help_outline_rounded,
        description: 'Weather conditions unavailable',
      ),
    };
  }

  /// Returns a background gradient appropriate for the current weather state.
  static List<Color> gradientForCode(int code, {bool isDay = true}) {
    if (!isDay) {
      return const [Color(0xFF0D1B2A), Color(0xFF1A2E3B)];
    }
    return switch (code) {
      0 || 1 => const [Color(0xFF1B6CA8), Color(0xFF4FC3F7)],
      2 => const [Color(0xFF2C7BB6), Color(0xFF78C5E7)],
      3 => const [Color(0xFF546E7A), Color(0xFF78909C)],
      45 || 48 => const [Color(0xFF607D8B), Color(0xFF90A4AE)],
      51 || 53 || 55 => const [Color(0xFF37474F), Color(0xFF607D8B)],
      61 || 63 || 65 => const [Color(0xFF1565C0), Color(0xFF42A5F5)],
      71 || 73 || 75 || 77 => const [Color(0xFF455A64), Color(0xFF90CAF9)],
      80 || 81 || 82 => const [Color(0xFF1976D2), Color(0xFF64B5F6)],
      95 || 96 || 99 => const [Color(0xFF212121), Color(0xFF37474F)],
      _ => const [Color(0xFF1B6CA8), Color(0xFF4FC3F7)],
    };
  }
}

/// Value object representing resolved weather condition data.
class WeatherInfo {
  final String condition;
  final IconData icon;
  final String description;

  const WeatherInfo({
    required this.condition,
    required this.icon,
    required this.description,
  });
}
