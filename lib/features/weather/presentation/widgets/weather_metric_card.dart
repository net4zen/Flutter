import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

/// A single metric card (humidity, wind, precipitation, pressure, etc.).
class WeatherMetricCard extends StatelessWidget {
  const WeatherMetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final String value;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final appColors = context.appColors;

    return Semantics(
      label: semanticLabel ?? '$label: $value',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: appColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: textTheme.labelMedium?.copyWith(
                    color: appColors.subtleText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
