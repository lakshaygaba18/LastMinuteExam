import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExamStorageService {
  static const String _key = "saved_exams";
  static final _supabase = Supabase.instance.client;

  // Save exam — locally + cloud if logged in
  static Future<void> saveExam(Map data, String title) async {
    final exam = {
      "title": title,
      "createdAt": DateTime.now().toIso8601String(),
      "data": data,
    };

    // Always save locally
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];
    saved.insert(0, jsonEncode(exam));
    await prefs.setStringList(_key, saved);

    // Also save to Supabase if logged in
    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('saved_exams').insert({
          'user_id': user.id,
          'title': title,
          'created_at': DateTime.now().toIso8601String(),
          'data': jsonEncode(data),
        });
      } catch (e) {
        print('Cloud save failed: $e');
      }
    }
  }

  // Load exams — from cloud if logged in, otherwise local
  static Future<List<Map<String, dynamic>>> loadExams() async {
    final user = _supabase.auth.currentUser;

    if (user != null) {
      try {
        final response = await _supabase
            .from('saved_exams')
            .select()
            .eq('user_id', user.id)
            .order('created_at', ascending: false);

        return (response as List).map((e) {
          return {
            'title': e['title'],
            'createdAt': e['created_at'],
            'data': jsonDecode(e['data']),
            'cloud_id': e['id'],
          };
        }).toList();
      } catch (e) {
        print('Cloud load failed, using local: $e');
      }
    }

    // Fallback to local
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];
    return saved
        .map((e) => Map<String, dynamic>.from(jsonDecode(e)))
        .toList();
  }

  // Delete exam
  static Future<void> deleteExam(int index) async {
    final user = _supabase.auth.currentUser;

    if (user != null) {
      try {
        final exams = await loadExams();
        if (index >= 0 && index < exams.length) {
          final cloudId = exams[index]['cloud_id'];
          if (cloudId != null) {
            await _supabase
                .from('saved_exams')
                .delete()
                .eq('id', cloudId);
          }
        }
        return;
      } catch (e) {
        print('Cloud delete failed: $e');
      }
    }

    // Fallback to local delete
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_key) ?? [];
    if (index >= 0 && index < saved.length) {
      saved.removeAt(index);
      await prefs.setStringList(_key, saved);
    }
  }
}
