import 'package:flutter/material.dart';

import '../models/category.dart';
import '../services/mealdb_api.dart';
import '../widgets/network_image_card.dart';
import '../widgets/search_field.dart';
import 'favorites_screen.dart';
import 'meal_detail_screen.dart';
import 'meals_by_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _api = MealDbApi();
  final _search = TextEditingController();
  late Future<List<Category>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _api.getCategories();
    _search.addListener(() {
      if (_query != _search.text) setState(() => _query = _search.text);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _openRandom() async {
    final meal = await _api.getRandomMeal();
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => MealDetailScreen(mealId: meal.id)));
  }

  void _openFavorites() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FavoritesScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal categories'),
        actions: [
          IconButton(
            onPressed: _openFavorites,
            icon: const Icon(Icons.favorite_outline),
            tooltip: 'Favorites',
          ),
          IconButton(
            onPressed: _openRandom,
            icon: const Icon(Icons.shuffle),
            tooltip: 'Random recipe',
          ),
        ],
      ),
      body: FutureBuilder<List<Category>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          final all = snap.data ?? [];
          final q = _query.trim().toLowerCase();
          final filtered = q.isEmpty ? all : all.where((c) => c.name.toLowerCase().contains(q)).toList();

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                SearchField(
                  controller: _search,
                  hint: 'Search categories...',
                  onClear: () => _search.clear(),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final c = filtered[i];
                      final desc = c.description.replaceAll('\r', '').replaceAll('\n', ' ').trim();
                      final shortDesc = desc.length > 120 ? '${desc.substring(0, 120)}…' : desc;

                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MealsByCategoryScreen(categoryName: c.name),
                            ),
                          );
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 92,
                                  child: NetworkImageCard(
                                    url: c.thumb,
                                    height: 92,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        c.name,
                                        style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        shortDesc.isEmpty ? 'No description.' : shortDesc,
                                        style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
