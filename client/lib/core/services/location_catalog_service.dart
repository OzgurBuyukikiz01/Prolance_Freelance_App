import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

List<String> _parseLocationsJson(String raw) {
  final decoded = jsonDecode(raw) as List<dynamic>;
  final list = decoded
      .map((e) => (e as String).trim())
      .where((s) => s.isNotEmpty)
      .toList()
    ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return list;
}

/// Loads [assets/data/world_locations.json]: sorted list of "City, Country" strings.
class LocationCatalogService {
  LocationCatalogService._();

  static final LocationCatalogService instance = LocationCatalogService._();

  List<String>? _locations;

  Future<void> ensureLoaded() async {
    if (_locations != null) return;
    final raw =
        await rootBundle.loadString('assets/data/world_locations.json');
    _locations = await compute(_parseLocationsJson, raw);
  }

  bool get isLoaded => _locations != null;

  /// Case-insensitive substring filter; capped for UI performance.
  List<String> filter(String query, {int limit = 40}) {
    final list = _locations;
    if (list == null) return [];
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return list
        .where((loc) => loc.toLowerCase().contains(q))
        .take(limit)
        .toList();
  }
}
