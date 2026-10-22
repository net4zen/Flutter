import 'package:flutter/material.dart';

/// A simple icon wrapper that applies consistent sizing and color.
/// Used for weather condition icons throughout the app.
class WeatherIconWidget extends StatelessWidget {
  const WeatherIconWidget({
    super.key,
    required this.icon,
    this.size = 48,
    this.color,
    this.semanticLabel,
  });

  final IconData icon;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Icon(
        icon,
        size: size,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
