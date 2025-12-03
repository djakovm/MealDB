import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_meal.dart';

class FavoritesStore {
  FavoritesStore._();
  static final instance = FavoritesStore._();

  static const _kKey = 'favorites_meals_v1';

  final ValueNotifier<List<FavoriteMeal>> favorites = ValueNotifier<List<FavoriteMeal>>([]);

  Future<void> init() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kKey);
    if (raw == null || raw.isEmpty) {
      favorites.value = [];
      return;
    }
    final decoded = jsonDecode(raw) as List<dynamic>;
    favorites.value = decoded.map((e) => FavoriteMeal.fromJson(e as Map<String, dynamic>)).toList();
  }

  bool isFavorite(String id) => favorites.value.any((m) => m.id == id);

  Future<void> toggle(FavoriteMeal meal) async {
    final current = [...favorites.value];
    final idx = current.indexWhere((m) => m.id == meal.id);
    if (idx >= 0) {
      current.removeAt(idx);
    } else {
      current.insert(0, meal);
    }
    favorites.value = current;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kKey, jsonEncode(current.map((e) => e.toJson()).toList()));
  }

  Future<void> remove(String id) async {
    final current = favorites.value.where((m) => m.id != id).toList();
    favorites.value = current;
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kKey, jsonEncode(current.map((e) => e.toJson()).toList()));
  }
}
