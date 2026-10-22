import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/location_model.dart';
import '../../data/repositories/weather_repository.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/app_exception.dart';
import 'weather_notifier.dart';

// ─── Search state ─────────────────────────────────────────────────────────────

/// Models the search field UI state.
sealed class SearchState {
  const SearchState();
}

class SearchIdle extends SearchState {
  const SearchIdle();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchSuccess extends SearchState {
  const SearchSuccess(this.results);
  final List<LocationModel> results;
}

class SearchEmpty extends SearchState {
  const SearchEmpty();
}

class SearchError extends SearchState {
  const SearchError(this.message);
  final String message;
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final searchNotifierProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);

// ─── Notifier ─────────────────────────────────────────────────────────────────

/// Manages the city search experience with debouncing.
///
/// Debounces keystrokes to avoid firing a geocoding API request on every
/// character. Cancels in-flight searches when the query changes.
class SearchNotifier extends Notifier<SearchState> {
  Timer? _debounceTimer;
  String _lastQuery = '';

  @override
  SearchState build() {
    // Cancel timer on dispose.
    ref.onDispose(() => _debounceTimer?.cancel());
    return const SearchIdle();
  }

  WeatherRepository get _repository => ref.read(weatherRepositoryProvider);

  /// Called whenever the search field text changes.
  void onQueryChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().length < AppConstants.minSearchLength) {
      state = const SearchIdle();
      _lastQuery = '';
      return;
    }

    if (query.trim() == _lastQuery) return;

    state = const SearchLoading();

    _debounceTimer = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () => _performSearch(query.trim()),
    );
  }

  /// Immediately searches without waiting for debounce (keyboard submit).
  Future<void> onSubmit(String query) async {
    _debounceTimer?.cancel();
    if (query.trim().length < AppConstants.minSearchLength) {
      state = const SearchIdle();
      return;
    }
    await _performSearch(query.trim());
  }

  Future<void> _performSearch(String query) async {
    _lastQuery = query;
    if (state is! SearchLoading) state = const SearchLoading();

    try {
      final results = await _repository.searchLocations(query);
      state = results.isEmpty ? const SearchEmpty() : SearchSuccess(results);
    } on AppException catch (e) {
      state = SearchError(e.message);
    } catch (_) {
      state = const SearchError('Search failed. Please try again.');
    }
  }

  /// Clears the search state when the field is dismissed.
  void clear() {
    _debounceTimer?.cancel();
    _lastQuery = '';
    state = const SearchIdle();
  }
}
