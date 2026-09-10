import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/menu_category.dart';
import '../models/menu_item.dart';
import '../models/restaurant_table.dart';

class AppConfig {
  final int cutoffHour;
  final int cutoffMinute;
  final bool soundEnabled;
  final List<RestaurantTable> tables;
  final List<MenuCategory> menu;

  AppConfig({
    required this.cutoffHour,
    required this.cutoffMinute,
    required this.soundEnabled,
    required this.tables,
    required this.menu,
  });

  Map<String, dynamic> toJson() => {
        'cutoffHour': cutoffHour,
        'cutoffMinute': cutoffMinute,
        'soundEnabled': soundEnabled,
        'tables': tables.map((t) => {'id': t.id, 'name': t.name}).toList(),
        'menu': menu
            .map((c) => {
                  'name': c.name,
                  'items': c.items
                      .map((i) => {'id': i.id, 'name': i.name, 'price': i.price})
                      .toList(),
                })
            .toList(),
      };

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      cutoffHour: json['cutoffHour'] as int? ?? 4,
      cutoffMinute: json['cutoffMinute'] as int? ?? 0,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      tables: (json['tables'] as List)
          .map((t) => RestaurantTable(id: t['id'] as String, name: t['name'] as String))
          .toList(),
      menu: (json['menu'] as List)
          .map((c) => MenuCategory(
                name: c['name'] as String,
                items: (c['items'] as List)
                    .map((i) => MenuItem(
                          id: i['id'] as String,
                          name: i['name'] as String,
                          price: (i['price'] as num).toDouble(),
                        ))
                    .toList(),
              ))
          .toList(),
    );
  }
}

class ConfigRepository {
  Future<File> _file() async {
    final docs = await getApplicationDocumentsDirectory();
    return File('${docs.path}/config.json');
  }

  Future<AppConfig?> load() async {
    final file = await _file();
    if (!await file.exists()) return null;
    try {
      final content = await file.readAsString();
      return AppConfig.fromJson(jsonDecode(content) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(AppConfig config) async {
    final file = await _file();
    await file.writeAsString(jsonEncode(config.toJson()));
  }
}
