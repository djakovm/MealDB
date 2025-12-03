class FavoriteMeal {
  final String id;
  final String name;
  final String thumb;

  FavoriteMeal({required this.id, required this.name, required this.thumb});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'thumb': thumb};

  factory FavoriteMeal.fromJson(Map<String, dynamic> j) => FavoriteMeal(
    id: (j['id'] ?? '').toString(),
    name: (j['name'] ?? '').toString(),
    thumb: (j['thumb'] ?? '').toString(),
  );
}
