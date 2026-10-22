import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/weather_notifier.dart';
import '../providers/weather_state.dart';
import '../widgets/weather_header_widget.dart';
import '../widgets/weather_metric_card.dart';
import '../widgets/weather_loading_widget.dart';
import '../widgets/weather_error_widget.dart';
import '../widgets/search_bar_widget.dart';
import '../widgets/location_button_widget.dart';
import '../../data/models/weather_model.dart';
import '../../../../app/theme/app_theme.dart';

/// The primary screen of the application.
///
/// Handles all weather state transitions and composes reusable widgets.
/// Does not contain any networking, business logic, or state management —
/// those live in [WeatherNotifier].
class WeatherScreen extends ConsumerStatefulWidget {
  const WeatherScreen({super.key});

  @override
  ConsumerState<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends ConsumerState<WeatherScreen> {
  bool _searchVisible = false;

  @override
  void initState() {
    super.initState();
    // Listen for refresh errors to surface them as non-blocking SnackBars.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupErrorListener();
    });
  }

  void _setupErrorListener() {
    ref.listenManual(weatherNotifierProvider, (prev, next) {
      // Surface refresh errors (data preserved) as SnackBars.
      if (next is WeatherRefreshError) {
        _showErrorSnackBar(next.message);
      }
      // Surface cached background-refresh errors.
      if (next is WeatherCached && next.refreshError != null) {
        _showErrorSnackBar(next.refreshError!);
      }
    });
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(child: Text(message)),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () => ref.read(weatherNotifierProvider.notifier).refresh(),
        ),
      ),
    );
  }

  void _toggleSearch() => setState(() => _searchVisible = !_searchVisible);

  void _closeSearch() => setState(() => _searchVisible = false);

  @override
  Widget build(BuildContext context) {
    final weatherState = ref.watch(weatherNotifierProvider);
    final isRefreshing = weatherState is WeatherRefreshing;
    final appColors = context.appColors;

    return Scaffold(
      backgroundColor: appColors.backgroundPage,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => ref.read(weatherNotifierProvider.notifier).refresh(),
          color: Theme.of(context).colorScheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // ── App bar ──────────────────────────────────────────────────
              SliverAppBar(
                pinned: true,
                floating: false,
                backgroundColor: appColors.backgroundPage,
                title: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _searchVisible
                      ? const SizedBox.shrink()
                      : Text(
                          _cityTitle(weatherState),
                          key: ValueKey(_cityTitle(weatherState)),
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
                ),
                actions: [
                  if (!_searchVisible) ...[
                    const LocationButtonWidget(),
                    Tooltip(
                      message: 'Search city',
                      child: IconButton(
                        icon: const Icon(Icons.search_rounded),
                        onPressed: _toggleSearch,
                      ),
                    ),
                    if (isRefreshing)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    else
                      Tooltip(
                        message: 'Refresh weather',
                        child: IconButton(
                          icon: const Icon(Icons.refresh_rounded),
                          onPressed: isRefreshing
                              ? null
                              : () => ref
                                    .read(weatherNotifierProvider.notifier)
                                    .refresh(),
                        ),
                      ),
                  ],
                ],
              ),

              // ── Search bar (conditionally visible) ──────────────────────
              if (_searchVisible)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: SearchBarWidget(
                      onLocationSelected: (_) => _closeSearch(),
                      onClose: _closeSearch,
                    ),
                  ),
                ),

              // ── Main content ─────────────────────────────────────────────
              SliverToBoxAdapter(child: _buildBody(weatherState)),
            ],
          ),
        ),
      ),
    );
  }

  String _cityTitle(WeatherState state) {
    final loc = state.locationOrNull;
    if (loc == null) return 'Weatherly';
    return loc.name;
  }

  Widget _buildBody(WeatherState state) {
    return switch (state) {
      WeatherInitialLoading() => const WeatherLoadingWidget(),
      WeatherInitialError(:final message) => WeatherErrorWidget(
        message: message,
        onRetry: () =>
            ref.read(weatherNotifierProvider.notifier).retryInitialLoad(),
      ),
      WeatherSuccess(:final weather) => _WeatherContent(
        weather: weather,
        isStale: false,
      ),
      WeatherRefreshing(:final weather) => _WeatherContent(
        weather: weather,
        isStale: false,
      ),
      WeatherRefreshError(:final weather) => _WeatherContent(
        weather: weather,
        isStale: false,
      ),
      WeatherCached(:final weather) => _WeatherContent(
        weather: weather,
        isStale: true,
      ),
    };
  }
}

// ─── Weather content ──────────────────────────────────────────────────────────

/// The full weather display — header, metrics grid, updated timestamp.
/// Extracted so it can be shown in multiple WeatherState variants.
class _WeatherContent extends StatelessWidget {
  const _WeatherContent({required this.weather, required this.isStale});

  final WeatherModel weather;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero header ─────────────────────────────────────────────────
          WeatherHeaderWidget(weather: weather, isStale: isStale),
          const SizedBox(height: 24),

          // ── Section title ───────────────────────────────────────────────
          Text(
            'Current Conditions',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),

          // ── Metrics grid ────────────────────────────────────────────────
          _MetricsGrid(weather: weather),
          const SizedBox(height: 20),

          // ── Updated timestamp ───────────────────────────────────────────
          _UpdatedTimestamp(weather: weather, isStale: isStale),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({required this.weather});
  final WeatherModel weather;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use 2 columns for narrow screens, allow wider on tablets.
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;

        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: [
            WeatherMetricCard(
              icon: Icons.water_drop_rounded,
              label: 'HUMIDITY',
              value: '${weather.humidity}%',
              semanticLabel: 'Humidity: ${weather.humidity} percent',
            ),
            WeatherMetricCard(
              icon: Icons.air_rounded,
              label: 'WIND',
              value: '${weather.windSpeed.round()} km/h',
              semanticLabel:
                  'Wind speed: ${weather.windSpeed.round()} kilometres per hour',
            ),
            WeatherMetricCard(
              icon: Icons.umbrella_rounded,
              label: 'PRECIPITATION',
              value: '${weather.precipitation} mm',
              semanticLabel:
                  'Precipitation: ${weather.precipitation} millimetres',
            ),
            if (weather.surfacePressure != null)
              WeatherMetricCard(
                icon: Icons.compress_rounded,
                label: 'PRESSURE',
                value: '${weather.surfacePressure!.round()} hPa',
                semanticLabel:
                    'Pressure: ${weather.surfacePressure!.round()} hectopascals',
              ),
            if (weather.visibility != null)
              WeatherMetricCard(
                icon: Icons.visibility_rounded,
                label: 'VISIBILITY',
                value: '${(weather.visibility! / 1000).toStringAsFixed(1)} km',
                semanticLabel:
                    'Visibility: ${(weather.visibility! / 1000).toStringAsFixed(1)} kilometres',
              ),
            WeatherMetricCard(
              icon: weather.isDay
                  ? Icons.wb_sunny_outlined
                  : Icons.nightlight_round,
              label: 'TIME OF DAY',
              value: weather.isDay ? 'Daytime' : 'Night',
              semanticLabel:
                  'Time of day: ${weather.isDay ? "daytime" : "night"}',
            ),
          ],
        );
      },
    );
  }
}

class _UpdatedTimestamp extends StatelessWidget {
  const _UpdatedTimestamp({required this.weather, required this.isStale});
  final WeatherModel weather;
  final bool isStale;

  @override
  Widget build(BuildContext context) {
    final appColors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    final formatter = DateFormat('d MMM y, HH:mm');
    final timeStr = formatter.format(weather.fetchedAt.toLocal());

    return Row(
      children: [
        Icon(
          isStale ? Icons.history_rounded : Icons.check_circle_outline_rounded,
          size: 14,
          color: appColors.subtleText,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            isStale ? 'Last updated: $timeStr (cached)' : 'Updated: $timeStr',
            style: textTheme.bodySmall?.copyWith(color: appColors.subtleText),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
