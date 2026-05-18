import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/meal_model.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorites';

  static Future<List<Meal>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> favoritesJson =
        prefs.getStringList(_favoritesKey) ?? [];

    return favoritesJson
        .map((item) => Meal.fromJson(jsonDecode(item)))
        .toList();
  }

  static Future<void> addFavorite(Meal meal) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> favoritesJson =
        prefs.getStringList(_favoritesKey) ?? [];

    final exists = favoritesJson.any((item) {
      final data = Meal.fromJson(jsonDecode(item));
      return data.idMeal == meal.idMeal;
    });

    if (!exists) {
      favoritesJson.add(jsonEncode(meal.toJson()));
      await prefs.setStringList(_favoritesKey, favoritesJson);
    }
  }

  static Future<void> removeFavorite(String mealId) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> favoritesJson =
        prefs.getStringList(_favoritesKey) ?? [];

    favoritesJson.removeWhere((item) {
      final data = Meal.fromJson(jsonDecode(item));
      return data.idMeal == mealId;
    });

    await prefs.setStringList(_favoritesKey, favoritesJson);
  }

  static Future<bool> isFavorite(String mealId) async {
    final favorites = await getFavorites();

    return favorites.any((meal) => meal.idMeal == mealId);
  }

  static Future<bool> toggleFavorite(Meal meal) async {
    final isFav = await isFavorite(meal.idMeal);

    if (isFav) {
      await removeFavorite(meal.idMeal);
      return false;
    } else {
      await addFavorite(meal);
      return true;
    }
  }
}