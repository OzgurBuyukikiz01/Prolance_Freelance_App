import 'dart:convert';

import 'package:flutter/services.dart';

/// Loads [assets/data/category_skills.json] keyed by post-job category names.
class SkillsCatalogService {
  SkillsCatalogService._();

  static final SkillsCatalogService instance = SkillsCatalogService._();

  Map<String, List<String>>? _map;

  Future<void> ensureLoaded() async {
    if (_map != null) return;
    final raw =
        await rootBundle.loadString('assets/data/category_skills.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    _map = decoded.map(
      (k, v) => MapEntry(k, List<String>.from(v as List<dynamic>)),
    );
  }

  bool get isLoaded => _map != null;

  List<String> skillsForCategory(String category) {
    final m = _map;
    if (m == null) return [];
    return List<String>.from(m[category] ?? const []);
  }

  /// Every distinct skill across all categories (sorted case-insensitively).
  List<String> allSkillsUnique() {
    final m = _map;
    if (m == null) return [];
    final seen = <String>{};
    for (final list in m.values) {
      seen.addAll(list);
    }
    final list = seen.toList();
    list.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return list;
  }

  /// Substring search across the whole catalog (for manual skill pick).
  List<String> searchSkills(String query, {int limit = 48}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return allSkillsUnique()
        .where((s) => s.toLowerCase().contains(q))
        .take(limit)
        .toList();
  }

  /// Keyword-aware suggestions from description text (same category only).
  List<String> suggestFromDescription(String description, String category) {
    final catSkills = skillsForCategory(category);
    if (catSkills.isEmpty || description.trim().isEmpty) return [];
    final lower = description.toLowerCase();
    final hits = catSkills
        .where((s) => lower.contains(s.toLowerCase()))
        .take(8)
        .toList();
    return hits;
  }
}
