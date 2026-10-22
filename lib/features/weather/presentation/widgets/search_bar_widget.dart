import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/search_notifier.dart';
import '../providers/weather_notifier.dart';
import '../../data/models/location_model.dart';

/// Self-contained search widget with text field, suggestion list, and states.
///
/// Manages its own focus and delegates state changes to [SearchNotifier].
/// When the user selects a city, calls [onLocationSelected] and closes itself.
class SearchBarWidget extends ConsumerStatefulWidget {
  const SearchBarWidget({
    super.key,
    required this.onLocationSelected,
    required this.onClose,
  });

  final ValueChanged<LocationModel> onLocationSelected;
  final VoidCallback onClose;

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus when the search bar appears.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleClose() {
    ref.read(searchNotifierProvider.notifier).clear();
    widget.onClose();
  }

  void _handleLocationSelected(LocationModel location) {
    _focusNode.unfocus();
    ref.read(searchNotifierProvider.notifier).clear();
    ref.read(weatherNotifierProvider.notifier).loadWeatherForLocation(location);
    widget.onLocationSelected(location);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Search field ──────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                onChanged: (q) =>
                    ref.read(searchNotifierProvider.notifier).onQueryChanged(q),
                onSubmitted: (q) =>
                    ref.read(searchNotifierProvider.notifier).onSubmit(q),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search city...',
                  prefixIcon: searchState is SearchLoading
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: colorScheme.primary,
                            ),
                          ),
                        )
                      : const Icon(Icons.search_rounded),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          tooltip: 'Clear search',
                          onPressed: () {
                            _controller.clear();
                            ref
                                .read(searchNotifierProvider.notifier)
                                .onQueryChanged('');
                            _focusNode.requestFocus();
                          },
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 8),
            TextButton(onPressed: _handleClose, child: const Text('Cancel')),
          ],
        ),
        const SizedBox(height: 8),

        // ── Search results ────────────────────────────────────────────────────
        _buildSearchResult(context, searchState),
      ],
    );
  }

  Widget _buildSearchResult(BuildContext context, SearchState searchState) {
    if (searchState is SearchIdle) return const SizedBox.shrink();
    if (searchState is SearchLoading) return const _SearchLoadingIndicator();
    if (searchState is SearchEmpty) return _SearchEmptyState();
    if (searchState is SearchError) {
      return _SearchErrorState(message: searchState.message);
    }
    if (searchState is SearchSuccess) {
      return _SearchResultsList(
        results: searchState.results,
        onSelected: _handleLocationSelected,
      );
    }
    return const SizedBox.shrink();
  }
}

class _SearchLoadingIndicator extends StatelessWidget {
  const _SearchLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text('Searching…', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.location_off_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.onSurface.withAlpha(80),
            ),
            const SizedBox(height: 8),
            Text(
              "Couldn't find that city.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(160),
              ),
            ),
            Text(
              'Try a different location.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchErrorState extends StatelessWidget {
  const _SearchErrorState({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: Theme.of(context).colorScheme.error),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResultsList extends StatelessWidget {
  const _SearchResultsList({required this.results, required this.onSelected});

  final List<LocationModel> results;
  final ValueChanged<LocationModel> onSelected;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: results.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (_, index) {
            final loc = results[index];
            return ListTile(
              leading: const Icon(Icons.location_on_rounded),
              title: Text(
                loc.name,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              subtitle: loc.subtitle.isNotEmpty
                  ? Text(
                      loc.subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                    )
                  : null,
              onTap: () => onSelected(loc),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
            );
          },
        ),
      ),
    );
  }
}
