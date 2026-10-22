import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../errors/app_exception.dart';

/// Configured [Dio] instance factory for the weather forecast API.
///
/// Encapsulates all Dio setup: base URL, timeouts, and error mapping.
/// Widgets and repositories interact only with [AppException] — they never
/// import Dio directly.
class DioClient {
  DioClient._();

  /// Creates a Dio client pointed at the Open-Meteo forecast API.
  static Dio createForecastClient() {
    return _buildClient(ApiConstants.forecastBaseUrl);
  }

  /// Creates a Dio client pointed at the Open-Meteo geocoding API.
  static Dio createGeocodingClient() {
    return _buildClient(ApiConstants.geocodingBaseUrl);
  }

  static Dio _buildClient(String baseUrl) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );
    return dio;
  }

  /// Maps a raw [DioException] or any other exception to a typed [AppException].
  ///
  /// Call this in catch blocks inside data sources so that the repository and
  /// presentation layers never see Dio internals.
  static AppException mapException(Object error) {
    if (error is AppException) return error;

    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return const TimeoutException();

        case DioExceptionType.connectionError:
          // Covers SocketException (no network) and similar.
          return const NoInternetException();

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 429) return const RateLimitException();
          if (statusCode != null && statusCode >= 400) {
            return const ServerException();
          }
          return const ServerException();

        case DioExceptionType.cancel:
          return const UnknownException('Request was cancelled.');

        case DioExceptionType.badCertificate:
          return const ServerException('SSL certificate error.');

        case DioExceptionType.transformTimeout:
          return const TimeoutException();

        case DioExceptionType.unknown:
          final inner = error.error;
          // DioExceptionType.unknown wraps SocketException on no internet
          if (inner != null && inner.toString().contains('SocketException')) {
            return const NoInternetException();
          }
          return const UnknownException();
      }
    }

    return const UnknownException();
  }
}
