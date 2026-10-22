import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/errors/app_exception.dart';

// ─── Location state ───────────────────────────────────────────────────────────

sealed class LocationState {
  const LocationState();
}

class LocationIdle extends LocationState {
  const LocationIdle();
}

class LocationLoading extends LocationState {
  const LocationLoading();
}

class LocationSuccess extends LocationState {
  const LocationSuccess({required this.latitude, required this.longitude});
  final double latitude;
  final double longitude;
}

class LocationError extends LocationState {
  const LocationError(this.exception);
  final AppException exception;
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final locationNotifierProvider =
    NotifierProvider<LocationNotifier, LocationState>(LocationNotifier.new);

// ─── Notifier ─────────────────────────────────────────────────────────────────

/// Handles GPS permission requests and coordinate retrieval.
///
/// Location is an optional feature. If permission is denied the app
/// continues functioning with manual city search.
class LocationNotifier extends Notifier<LocationState> {
  @override
  LocationState build() => const LocationIdle();

  /// Requests GPS permission and fetches the current position.
  /// Maps all Geolocator failures to typed [AppException] subtypes.
  Future<void> requestLocation() async {
    if (state is LocationLoading) return; // Prevent double-tap.
    state = const LocationLoading();

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = const LocationError(LocationServicesDisabledException());
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = const LocationError(LocationPermissionDeniedException());
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = const LocationError(
          LocationPermissionPermanentlyDeniedException(),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 10),
        ),
      );

      state = LocationSuccess(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on LocationServiceDisabledException {
      state = const LocationError(LocationServicesDisabledException());
    } catch (_) {
      state = const LocationError(LocationLookupException());
    }
  }

  /// Resets to idle so the button is available again.
  void reset() {
    state = const LocationIdle();
  }
}
