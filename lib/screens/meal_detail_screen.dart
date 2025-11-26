import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/meal_detail.dart';
import '../services/mealdb_api.dart';
import '../widgets/network_image_card.dart';

class MealDetailScreen extends StatefulWidget {
  final String mealId;

  const MealDetailScreen({super.key, required this.mealId});

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final _api = MealDbApi();
  late Future<MealDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.getMealDetail(widget.mealId);
  }

  Future<void> _openYoutube(String url) async {
    final u = Uri.tryParse(url);
    if (u == null) return;
    await launchUrl(u, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Recipe')),
      body: FutureBuilder<MealDetail>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final m = snap.data!;

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              Hero(
                tag: 'meal_${m.id}',
                child: Card(
                  clipBehavior: Clip.antiAlias,
                  child: NetworkImageCard(
                    url: m.thumb,
                    height: 220,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                m.name,
                style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
              ),
              if ((m.category ?? '').isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  m.category!,
                  style: t.textTheme.bodyMedium?.copyWith(color: t.colorScheme.onSurfaceVariant),
                ),
              ],
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ingredients', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      ...m.ingredients.map((x) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('•  '),
                            Expanded(child: Text(x.label)),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Instructions', style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      Text(m.instructions.isEmpty ? 'No instructions.' : m.instructions),
                      if ((m.youtube ?? '').isNotEmpty) ...[
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: () => _openYoutube(m.youtube!),
                          icon: const Icon(Icons.play_circle_outline),
                          label: const Text('Open YouTube'),
                        )
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
