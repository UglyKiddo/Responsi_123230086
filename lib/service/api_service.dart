import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal_model.dart';

class ApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  static Future<List<Meal>> fetchMealsByCategory(String category) async {
    try {
      final url = Uri.parse('$_baseUrl/filter.php?c=$category');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] == null) {
          return [];
        }
        final List meals = data['meals'];
        return meals.map((e) => Meal.fromJson(e)).toList();
      } else {
        throw Exception('Gagal memuat data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  static Future<Meal> fetchMealDetail(String mealId) async {
    try {
      final url = Uri.parse('$_baseUrl/lookup.php?i=$mealId');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] == null || data['meals'].isEmpty) {
          throw Exception('Meal not found');
        }
        return Meal.fromJson(data['meals'][0]);
      } else {
        throw Exception('Gagal memuat detail: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}