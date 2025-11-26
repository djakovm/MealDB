import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/category.dart';
import '../models/meal_detail.dart';
import '../models/meal_summary.dart';

class MealDbApi {
  static const _base = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Category>> getCategories() async {
    final res = await http.get(Uri.parse('$_base/categories.php'));
    if (res.statusCode != 200) throw Exception('Failed to load categories');
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (json['categories'] as List<dynamic>? ?? []);
    return list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<MealSummary>> getMealsByCategory(String category) async {
    final res = await http.get(Uri.parse('$_base/filter.php?c=${Uri.encodeComponent(category)}'));
    if (res.statusCode != 200) throw Exception('Failed to load meals');
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (json['meals'] as List<dynamic>? ?? []);
    return list.map((e) => MealSummary.fromJsonFilter(e as Map<String, dynamic>)).toList();
  }

  Future<List<MealSummary>> searchMealsByName(String query) async {
    final res = await http.get(Uri.parse('$_base/search.php?s=${Uri.encodeComponent(query)}'));
    if (res.statusCode != 200) throw Exception('Failed to search meals');
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (json['meals'] as List<dynamic>?);
    if (list == null) return [];
    return list.map((e) => MealSummary.fromJsonSearch(e as Map<String, dynamic>)).toList();
  }

  Future<MealDetail> getMealDetail(String id) async {
    final res = await http.get(Uri.parse('$_base/lookup.php?i=${Uri.encodeComponent(id)}'));
    if (res.statusCode != 200) throw Exception('Failed to load meal detail');
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (json['meals'] as List<dynamic>? ?? []);
    if (list.isEmpty) throw Exception('Meal not found');
    return MealDetail.fromJson(list.first as Map<String, dynamic>);
  }

  Future<MealDetail> getRandomMeal() async {
    final res = await http.get(Uri.parse('$_base/random.php'));
    if (res.statusCode != 200) throw Exception('Failed to load random meal');
    final json = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (json['meals'] as List<dynamic>? ?? []);
    if (list.isEmpty) throw Exception('Meal not found');
    return MealDetail.fromJson(list.first as Map<String, dynamic>);
  }
}
