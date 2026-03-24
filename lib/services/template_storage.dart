import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/template_model.dart';

class TemplateStorage {
  static const String _key = 'announce_templates';

  static Future<List<TemplateModel>> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return [];
    final List<dynamic> list = jsonDecode(jsonStr) as List<dynamic>;
    return list
        .map((e) => TemplateModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> save(TemplateModel template) async {
    final templates = await loadAll();
    templates.add(template);
    await _persist(templates);
  }

  static Future<void> update(TemplateModel updated) async {
    final templates = await loadAll();
    final index = templates.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      templates[index] = updated;
    } else {
      templates.add(updated);
    }
    await _persist(templates);
  }

  static Future<void> delete(String id) async {
    final templates = await loadAll();
    templates.removeWhere((t) => t.id == id);
    await _persist(templates);
  }

  static Future<void> _persist(List<TemplateModel> templates) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(templates.map((t) => t.toJson()).toList()));
  }
}
