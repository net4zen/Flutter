import 'package:flutter/material.dart';

import '../../data/models/weather_model.dart';
import '../../../../core/utils/weather_code_mapper.dart';
import 'weather_icon_widget.dart';

/// The large hero section showing temperature, condition icon, and city.
class WeatherHeaderWidget extends StatelessWidget {
  const WeatherHeaderWidget({
    super.key,
    required this.weather,
    this.isStale = false,
  });

  final WeatherModel weather;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    final info = WeatherCodeMapper.fromCode(
      weather.weatherCode,
      isDay: weather.isDay,
    );
    final gradientColors = WeatherCodeMapper.gradientForCode(
      weather.weatherCode,
      isDay: weather.isDay,
    );
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // Decorative circle
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -20,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // City name
                Text(
                  weather.location.name,
                  style: textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (weather.location.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    weather.location.subtitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withAlpha(200),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 24),
                // Icon + temperature row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    WeatherIconWidget(
                      icon: info.icon,
                      size: 72,
                      color: Colors.white,
                      semanticLabel: info.condition,
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${weather.temperature.round()}°C',
                          style: textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w300,
                            fontSize: 64,
                          ),
                        ),
                        Text(
                          'Feels like ${weather.apparentTemperature.round()}°C',
                          style: textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withAlpha(210),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Condition text
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    info.condition,
                    style: textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isStale) ...[const SizedBox(height: 8), _StaleBadge()],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StaleBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.history_rounded,
          size: 14,
          color: Colors.white.withAlpha(180),
        ),
        const SizedBox(width: 4),
        Text(
          'Cached data — refresh to update',
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: Colors.white.withAlpha(180)),
        ),
      ],
    );
  }
}
