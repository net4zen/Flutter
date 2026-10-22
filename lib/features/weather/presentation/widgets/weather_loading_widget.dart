import 'package:flutter/material.dart';

/// Displayed while weather data is loading for the first time (no cached data).
/// Uses a skeleton shimmer-style layout so the user understands what is loading.
class WeatherLoadingWidget extends StatefulWidget {
  const WeatherLoadingWidget({super.key});

  @override
  State<WeatherLoadingWidget> createState() => _WeatherLoadingWidgetState();
}

class _WeatherLoadingWidgetState extends State<WeatherLoadingWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _shimmer = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading weather data',
      child: AnimatedBuilder(
        animation: _shimmer,
        builder: (context, _) {
          final baseColor = Theme.of(context).colorScheme.surface;
          final shimmerColor = Theme.of(context).colorScheme.primary
              .withAlpha(20 + (_shimmer.value * 20).toInt());

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ShimmerBox(
                  width: double.infinity,
                  height: 220,
                  baseColor: baseColor,
                  shimmerColor: shimmerColor,
                  borderRadius: 24,
                ),
                const SizedBox(height: 20),
                _ShimmerBox(
                  width: 180,
                  height: 20,
                  baseColor: baseColor,
                  shimmerColor: shimmerColor,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _ShimmerBox(
                        width: double.infinity,
                        height: 90,
                        baseColor: baseColor,
                        shimmerColor: shimmerColor,
                        borderRadius: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ShimmerBox(
                        width: double.infinity,
                        height: 90,
                        baseColor: baseColor,
                        shimmerColor: shimmerColor,
                        borderRadius: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _ShimmerBox(
                        width: double.infinity,
                        height: 90,
                        baseColor: baseColor,
                        shimmerColor: shimmerColor,
                        borderRadius: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ShimmerBox(
                        width: double.infinity,
                        height: 90,
                        baseColor: baseColor,
                        shimmerColor: shimmerColor,
                        borderRadius: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  const _ShimmerBox({
    required this.width,
    required this.height,
    required this.baseColor,
    required this.shimmerColor,
    this.borderRadius = 8,
  });

  final double width;
  final double height;
  final Color baseColor;
  final Color shimmerColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Color.lerp(baseColor, shimmerColor, 0.5),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
