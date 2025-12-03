import 'package:flutter/material.dart';
import '../services/favorites_store.dart';
import '../widgets/network_image_card.dart';
import 'meal_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: ValueListenableBuilder(
        valueListenable: FavoritesStore.instance.favorites,
        builder: (context, list, _) {
          if (list.isEmpty) {
            return Center(
              child: Text(
                'No favorites yet.',
                style: t.textTheme.bodyLarge?.copyWith(color: t.colorScheme.onSurfaceVariant),
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.82,
              ),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final m = list[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => MealDetailScreen(mealId: m.id)),
                  ),
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
          );
        },
      ),
    );
  }
}
