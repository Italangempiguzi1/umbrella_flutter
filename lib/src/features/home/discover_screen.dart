import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/async_value_widget.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/app_models.dart';
import '../../data/providers/app_providers.dart';
import 'content_card.dart';

class DiscoverScreen extends ConsumerStatefulWidget {
  const DiscoverScreen({super.key});

  @override
  ConsumerState<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends ConsumerState<DiscoverScreen> {
  String _query = '';
  String _type = 'all';

  final _types = const {
    'all': 'All',
    'movie': 'Movies',
    'series': 'Series',
    'documentary': 'Docs',
    'educational': 'Education',
    'premium_creator': 'Creators',
  };

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentItemsProvider);
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Discover', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900)),
                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search_rounded), hintText: 'Search movies, creators, education, series...'),
                  onChanged: (value) => setState(() => _query = value.trim().toLowerCase()),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _types.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final key = _types.keys.elementAt(index);
                      return ChoiceChip(
                        label: Text(_types[key]!),
                        selected: _type == key,
                        onSelected: (_) => setState(() => _type = key),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: AsyncValueWidget<List<ContentItem>>(
              value: content,
              data: (items) {
                final filtered = items.where((item) {
                  final matchesType = _type == 'all' || item.contentType == _type;
                  final matchesQuery = _query.isEmpty ||
                      item.title.toLowerCase().contains(_query) ||
                      item.description.toLowerCase().contains(_query) ||
                      item.creatorName.toLowerCase().contains(_query) ||
                      item.categoryName.toLowerCase().contains(_query);
                  return matchesType && matchesQuery;
                }).toList();
                if (filtered.isEmpty) return const EmptyState(title: 'Nothing found', message: 'Try a different search term or category.', icon: Icons.search_off_rounded);
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 10, 18, 100),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: .56, crossAxisSpacing: 14, mainAxisSpacing: 18),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => ContentCard(item: filtered[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
