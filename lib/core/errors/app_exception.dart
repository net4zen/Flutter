/// Typed exception hierarchy for Weatherly.
///
/// All network and business errors are mapped to one of these types before
/// reaching the presentation layer. UI code only catches [AppException]
/// subtypes and never sees raw [DioException] or socket details.
sealed class AppException implements Exception {
  const AppException(this.message);

  /// User-facing message — safe to display directly in the UI.
  final String message;

  @override
  String toString() => 'AppException($message)';
}

/// Device has no internet connectivity.
class NoInternetException extends AppException {
  const NoInternetException()
    : super("You're offline. Showing your last available weather data.");
}

/// The request did not complete within the allowed timeout.
class TimeoutException extends AppException {
  const TimeoutException()
    : super(
        'The request timed out. Please check your connection and try again.',
      );
}

/// HTTP 429 — API rate limit exceeded.
class RateLimitException extends AppException {
  const RateLimitException()
    : super('Weather service is busy. Please wait a moment and try again.');
}

/// HTTP 4xx (other than 429) or 5xx from the server.
class ServerException extends AppException {
  const ServerException([String? detail])
    : super(
        detail ?? 'Weather service is temporarily unavailable. Please try again later.',
      );
}

/// The JSON response was malformed or missing expected fields.
class ParseException extends AppException {
  const ParseException()
    : super(
        'Received unexpected data from the weather service. Please try again.',
      );
}

/// City search returned no matching results.
class NoCityResultsException extends AppException {
  const NoCityResultsException()
    : super("Couldn't find that city. Try a different location.");
}

/// Location permission was denied by the user.
class LocationPermissionDeniedException extends AppException {
  const LocationPermissionDeniedException()
    : super(
        'Location permission was denied. Please grant it in Settings to use GPS.',
      );
}

/// Location permission was permanently denied (requires Settings visit).
class LocationPermissionPermanentlyDeniedException extends AppException {
  const LocationPermissionPermanentlyDeniedException()
    : super(
        'Location permission is permanently denied. Enable it in your device Settings.',
      );
}

/// Location services (GPS) are disabled on the device.
class LocationServicesDisabledException extends AppException {
  const LocationServicesDisabledException()
    : super(
        'Location services are disabled. Please enable GPS in your device Settings.',
      );
}

/// GPS lookup failed for an unexpected reason.
class LocationLookupException extends AppException {
  const LocationLookupException()
    : super('Unable to determine your current location. Please try again.');
}

/// Catch-all for unexpected errors.
class UnknownException extends AppException {
  const UnknownException([String? detail])
    : super(detail ?? 'Something went wrong. Please try again.');
}
