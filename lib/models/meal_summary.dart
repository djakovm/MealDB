class MealSummary {
  final String id;
  final String name;
  final String thumb;
  final String? category;

  MealSummary({
    required this.id,
    required this.name,
    required this.thumb,
    this.category,
  });

  factory MealSummary.fromJsonFilter(Map<String, dynamic> j) {
    return MealSummary(
      id: (j['idMeal'] ?? '').toString(),
      name: (j['strMeal'] ?? '').toString(),
      thumb: (j['strMealThumb'] ?? '').toString(),
      category: null,
    );
  }

  factory MealSummary.fromJsonSearch(Map<String, dynamic> j) {
    return MealSummary(
      id: (j['idMeal'] ?? '').toString(),
      name: (j['strMeal'] ?? '').toString(),
      thumb: (j['strMealThumb'] ?? '').toString(),
      category: (j['strCategory'] ?? '')?.toString(),
    );
  }
}
