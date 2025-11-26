class IngredientLine {
  final String ingredient;
  final String measure;

  const IngredientLine(this.ingredient, this.measure);

  String get label {
    final m = measure.trim();
    if (m.isEmpty) return ingredient.trim();
    return '${ingredient.trim()} — $m';
  }
}

class MealDetail {
  final String id;
  final String name;
  final String thumb;
  final String? category;
  final String instructions;
  final String? youtube;
  final List<IngredientLine> ingredients;

  MealDetail({
    required this.id,
    required this.name,
    required this.thumb,
    required this.instructions,
    required this.ingredients,
    this.category,
    this.youtube,
  });

  factory MealDetail.fromJson(Map<String, dynamic> j) {
    String s(dynamic v) => (v ?? '').toString();
    final ingredients = <IngredientLine>[];
    for (var i = 1; i <= 20; i++) {
      final ing = s(j['strIngredient$i']).trim();
      final meas = s(j['strMeasure$i']).trim();
      if (ing.isNotEmpty) ingredients.add(IngredientLine(ing, meas));
    }
    return MealDetail(
      id: s(j['idMeal']),
      name: s(j['strMeal']),
      thumb: s(j['strMealThumb']),
      category: s(j['strCategory']).isEmpty ? null : s(j['strCategory']),
      instructions: s(j['strInstructions']),
      youtube: s(j['strYoutube']).isEmpty ? null : s(j['strYoutube']),
      ingredients: ingredients,
    );
  }
}
