import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String key = "favorite_questions";

  static Future<List<Map<String, dynamic>>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList(key) ?? [];

    return data
        .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
        .toList();
  }

  static Future<void> toggleFavorite(
    Map<String, dynamic> question,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final existing = prefs.getStringList(key) ?? [];

    final encoded = jsonEncode(question);

    if (existing.contains(encoded)) {
      existing.remove(encoded);
    } else {
      existing.add(encoded);
    }

    await prefs.setStringList(key, existing);
  }

  static Future<bool> isFavorite(
    Map<String, dynamic> question,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final existing = prefs.getStringList(key) ?? [];

    return existing.contains(jsonEncode(question));
  }
}