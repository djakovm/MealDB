import 'package:flutter/material.dart';

import '../models/meal_summary.dart';
import '../services/mealdb_api.dart';
import '../widgets/network_image_card.dart';
import '../widgets/search_field.dart';
import 'meal_detail_screen.dart';

class MealsByCategoryScreen extends StatefulWidget {
  final String categoryName;

  const MealsByCategoryScreen({super.key, required this.categoryName});

  @override
  State<MealsByCategoryScreen> createState() => _MealsByCategoryScreenState();
}

class _MealsByCategoryScreenState extends State<MealsByCategoryScreen> {
  final _api = MealDbApi();
  final _search = TextEditingController();

  late Future<List<MealSummary>> _future;
  List<MealSummary> _base = [];
  List<MealSummary> _shown = [];
  String _query = '';
  bool _remoteSearching = false;

  @override
  void initState() {
    super.initState();
    _future = _api.getMealsByCategory(widget.categoryName).then((list) {
      _base = list;
      _shown = list;
      return list;
    });
    _search.addListener(() async {
      final next = _search.text;
      if (next == _query) return;
      _query = next;
      await _applySearch();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _applySearch() async {
    final q = _query.trim();
    if (q.isEmpty) {
      setState(() => _shown = _base);
      return;
    }

    setState(() => _remoteSearching = true);
    try {
      final results = await _api.searchMealsByName(q);
      final cat = widget.categoryName.toLowerCase();
      final filtered = results
          .where((m) => (m.category ?? '').toLowerCase() == cat)
          .toList();
      setState(() => _shown = filtered);
    } catch (_) {
      final local = _base.where((m) => m.name.toLowerCase().contains(q.toLowerCase())).toList();
      setState(() => _shown = local);
    } finally {
      if (mounted) setState(() => _remoteSearching = false);
    }
  }

  Future<void> _openRandom() async {
    final meal = await _api.getRandomMeal();
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => MealDetailScreen(mealId: meal.id)));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
        actions: [
          IconButton(
            onPressed: _openRandom,
            icon: const Icon(Icons.shuffle),
            tooltip: 'Random recipe',
          ),
        ],
      ),
      body: FutureBuilder<List<MealSummary>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SearchField(
                        controller: _search,
                        hint: 'Search meals in this category...',
                        onClear: () => _search.clear(),
                      ),
                    ),
                    if (_remoteSearching) ...[
                      const SizedBox(width: 10),
                      const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _shown.isEmpty
                      ? Center(
                    child: Text(
                      'No meals found.',
                      style: t.textTheme.bodyLarge?.copyWith(color: t.colorScheme.onSurfaceVariant),
                    ),
                  )
                      : GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.82,
                    ),
                    itemCount: _shown.length,
                    itemBuilder: (context, i) {
                      final m = _shown[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => MealDetailScreen(mealId: m.id)),
                          );
                        },
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              NetworkImageCard(
                                url: m.thumb,
                                height: 128,
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Text(
                                  m.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
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
