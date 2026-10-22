import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../features/location/presentation/providers/location_notifier.dart';
import '../providers/weather_notifier.dart';

/// GPS "Use my location" button.
///
/// Handles its own loading/error states via [LocationNotifier] and
/// fires [WeatherNotifier.loadWeatherForCoordinates] on success.
class LocationButtonWidget extends ConsumerWidget {
  const LocationButtonWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationState = ref.watch(locationNotifierProvider);

    // React to state changes: on success, load weather; on error, show snackbar.
    ref.listen(locationNotifierProvider, (prev, next) {
      if (next is LocationSuccess) {
        ref
            .read(weatherNotifierProvider.notifier)
            .loadWeatherForCoordinates(next.latitude, next.longitude);
        ref.read(locationNotifierProvider.notifier).reset();
      } else if (next is LocationError) {
        final messenger = ScaffoldMessenger.of(context);
        messenger.hideCurrentSnackBar();
        messenger.showSnackBar(
          SnackBar(
            content: Text(next.exception.message),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        ref.read(locationNotifierProvider.notifier).reset();
      }
    });

    final isLoading = locationState is LocationLoading;

    return Tooltip(
      message: 'Use current location',
      child: IconButton(
        icon: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              )
            : const Icon(Icons.my_location_rounded),
        onPressed: isLoading
            ? null
            : () =>
                  ref.read(locationNotifierProvider.notifier).requestLocation(),
      ),
    );
  }
}
