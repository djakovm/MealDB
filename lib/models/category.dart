class Category {
  final String id;
  final String name;
  final String thumb;
  final String description;

  Category({
    required this.id,
    required this.name,
    required this.thumb,
    required this.description,
  });

  factory Category.fromJson(Map<String, dynamic> j) {
    return Category(
      id: (j['idCategory'] ?? '').toString(),
      name: (j['strCategory'] ?? '').toString(),
      thumb: (j['strCategoryThumb'] ?? '').toString(),
      description: (j['strCategoryDescription'] ?? '').toString(),
    );
  }
}
