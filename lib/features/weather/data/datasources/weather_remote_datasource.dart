import 'package:dio/dio.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';

/// Remote data source — responsible only for making HTTP requests and parsing
/// raw JSON. No caching, no state, no UI concerns here.
class WeatherRemoteDataSource {
  WeatherRemoteDataSource({Dio? forecastClient, Dio? geocodingClient})
    : _forecastClient = forecastClient ?? DioClient.createForecastClient(),
      _geocodingClient = geocodingClient ?? DioClient.createGeocodingClient();

  final Dio _forecastClient;
  final Dio _geocodingClient;

  // ─── Weather ───────────────────────────────────────────────────────────────

  /// Fetches current weather for [latitude] / [longitude].
  ///
  /// Throws a typed [AppException] on any failure.
  Future<WeatherModel> fetchWeather(LocationModel location) async {
    const maxAttempts = 2;
    for (var attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        final response = await _forecastClient.get<Map<String, dynamic>>(
          ApiConstants.forecastPath,
          queryParameters: {
            'latitude': location.latitude,
            'longitude': location.longitude,
            'current': ApiConstants.currentVariables,
            'wind_speed_unit': 'kmh',
            'precipitation_unit': 'mm',
            'timezone': 'auto',
          },
        );

        final data = response.data;
        if (data == null) throw const ParseException();

        try {
          return WeatherModel.fromApiJson(data, location);
        } on FormatException {
          throw const ParseException();
        }
      } on AppException catch (e) {
        // Retry on transient server / timeout errors, but not on client errors.
        if (attempt < maxAttempts && (e is ServerException || e is TimeoutException)) {
          await Future<void>.delayed(const Duration(seconds: 1));
          continue;
        }
        rethrow;
      } catch (e) {
        final mapped = DioClient.mapException(e);
        if (attempt < maxAttempts &&
            (mapped is ServerException || mapped is TimeoutException)) {
          await Future<void>.delayed(const Duration(seconds: 1));
          continue;
        }
        throw mapped;
      }
    }
    // Unreachable — loop always returns or throws.
    throw const ServerException();
  }

  // ─── Geocoding ─────────────────────────────────────────────────────────────

  /// Searches for cities matching [query].
  ///
  /// Returns an empty list when the API returns no results.
  /// Throws a typed [AppException] on network / parse failures.
  Future<List<LocationModel>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await _geocodingClient.get<Map<String, dynamic>>(
        ApiConstants.geocodingPath,
        queryParameters: {
          'name': query.trim(),
          'count': ApiConstants.geocodingCount,
          'language': 'en',
          'format': 'json',
        },
      );

      final data = response.data;
      if (data == null) throw const ParseException();

      final results = data['results'];
      if (results == null || results is! List) {
        // API returns no "results" key when there are no matches.
        return [];
      }

      return results
          .whereType<Map<String, dynamic>>()
          .map(LocationModel.fromJson)
          .toList();
    } on AppException {
      rethrow;
    } catch (e) {
      throw DioClient.mapException(e);
    }
  }
}
