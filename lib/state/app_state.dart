import 'package:flutter/foundation.dart';

import '../data/default_menu.dart';
import '../models/menu_category.dart';
import '../models/menu_item.dart';
import '../models/restaurant_table.dart';
import '../models/sale_record.dart';
import '../services/config_repository.dart';
import '../services/sales_repository.dart';
import '../services/sound_service.dart';

class AppState extends ChangeNotifier {
  final ConfigRepository _configRepository;
  final SalesRepository salesRepository;

  List<RestaurantTable> tables = List.generate(
    7,
    (i) => RestaurantTable(id: 'mesa_${i + 1}', name: 'Mesa ${i + 1}'),
  );

  List<MenuCategory> menu = buildDefaultMenu();

  int cutoffHour = 4;
  int cutoffMinute = 0;

  bool _soundEnabled = false;
  bool get soundEnabled => _soundEnabled;
  set soundEnabled(bool value) {
    _soundEnabled = value;
    SoundService.instance.enabled = value;
    _persist();
    notifyListeners();
  }

  // tableId -> (itemId -> cantidad)
  final Map<String, Map<String, int>> _orders = {};

  AppState({ConfigRepository? configRepository, SalesRepository? salesRepository})
      : _configRepository = configRepository ?? ConfigRepository(),
        salesRepository = salesRepository ?? SalesRepository();

  Future<void> load() async {
    final config = await _configRepository.load();
    if (config != null) {
      tables = config.tables;
      menu = config.menu;
      cutoffHour = config.cutoffHour;
      cutoffMinute = config.cutoffMinute;
      _soundEnabled = config.soundEnabled;
      SoundService.instance.enabled = config.soundEnabled;
      notifyListeners();
    }
    await salesRepository.purgeOldDays(keep: 10);
  }

  Future<void> _persist() async {
    await _configRepository.save(AppConfig(
      cutoffHour: cutoffHour,
      cutoffMinute: cutoffMinute,
      soundEnabled: _soundEnabled,
      tables: tables,
      menu: menu,
    ));
  }

  MenuItem? findMenuItem(String itemId) {
    for (final category in menu) {
      for (final item in category.items) {
        if (item.id == itemId) return item;
      }
    }
    return null;
  }

  int quantityOf(String tableId, String itemId) {
    return _orders[tableId]?[itemId] ?? 0;
  }

  Map<String, int> orderFor(String tableId) {
    return Map.unmodifiable(_orders[tableId] ?? const {});
  }

  bool hasOrder(String tableId) {
    final order = _orders[tableId];
    return order != null && order.values.any((qty) => qty > 0);
  }

  List<SaleItemLine> lineItemsFor(String tableId) {
    final order = _orders[tableId];
    if (order == null) return [];
    final lines = <SaleItemLine>[];
    for (final entry in order.entries) {
      final item = findMenuItem(entry.key);
      if (item == null || entry.value <= 0) continue;
      lines.add(SaleItemLine(
        itemId: item.id,
        name: item.name,
        unitPrice: item.price,
        quantity: entry.value,
      ));
    }
    return lines;
  }

  double totalFor(String tableId) {
    var total = 0.0;
    for (final line in lineItemsFor(tableId)) {
      total += line.lineTotal;
    }
    return total;
  }

  void incrementItem(String tableId, String itemId) {
    final order = _orders.putIfAbsent(tableId, () => {});
    order[itemId] = (order[itemId] ?? 0) + 1;
    notifyListeners();
  }

  void decrementItem(String tableId, String itemId) {
    final order = _orders[tableId];
    if (order == null) return;
    final current = order[itemId] ?? 0;
    if (current <= 1) {
      order.remove(itemId);
    } else {
      order[itemId] = current - 1;
    }
    notifyListeners();
  }

  void clearOrder(String tableId) {
    _orders.remove(tableId);
    notifyListeners();
  }

  Future<void> completeSale({
    required String tableId,
    required String paymentMethod,
    double? amountPaid,
    double? change,
    required double tip,
  }) async {
    final table = tables.firstWhere((t) => t.id == tableId);
    final sale = SaleRecord(
      tableId: tableId,
      tableName: table.name,
      items: lineItemsFor(tableId),
      total: totalFor(tableId),
      paymentMethod: paymentMethod,
      amountPaid: amountPaid,
      change: change,
      tip: tip,
      timestamp: DateTime.now(),
    );
    await salesRepository.recordSale(sale, cutoffHour: cutoffHour, cutoffMinute: cutoffMinute);
    clearOrder(tableId);
  }

  // --- Edición de mesas (Fase 4) ---

  void addTable() {
    final n = tables.length + 1;
    tables = [...tables, RestaurantTable(id: 'mesa_${DateTime.now().microsecondsSinceEpoch}', name: 'Mesa $n')];
    _persist();
    notifyListeners();
  }

  void removeTable(String tableId) {
    tables = tables.where((t) => t.id != tableId).toList();
    _orders.remove(tableId);
    _persist();
    notifyListeners();
  }

  void renameTable(String tableId, String newName) {
    final table = tables.firstWhere((t) => t.id == tableId);
    table.name = newName;
    _persist();
    notifyListeners();
  }

  // --- Edición de menú (Fase 4) ---

  void addCategory(String name) {
    menu = [...menu, MenuCategory(name: name, items: [])];
    _persist();
    notifyListeners();
  }

  void removeCategory(String categoryName) {
    menu = menu.where((c) => c.name != categoryName).toList();
    _persist();
    notifyListeners();
  }

  void renameCategory(String oldName, String newName) {
    menu = menu.map((c) {
      if (c.name != oldName) return c;
      return MenuCategory(name: newName, items: c.items);
    }).toList();
    _persist();
    notifyListeners();
  }

  void addMenuItem(String categoryName, String name, double price) {
    final id = 'item_${DateTime.now().microsecondsSinceEpoch}';
    menu = menu.map((c) {
      if (c.name != categoryName) return c;
      return MenuCategory(name: c.name, items: [...c.items, MenuItem(id: id, name: name, price: price)]);
    }).toList();
    _persist();
    notifyListeners();
  }

  void updateMenuItem(String itemId, {String? name, double? price}) {
    menu = menu.map((c) {
      return MenuCategory(
        name: c.name,
        items: c.items.map((i) {
          if (i.id != itemId) return i;
          return MenuItem(id: i.id, name: name ?? i.name, price: price ?? i.price);
        }).toList(),
      );
    }).toList();
    _persist();
    notifyListeners();
  }

  void removeMenuItem(String itemId) {
    menu = menu.map((c) {
      return MenuCategory(name: c.name, items: c.items.where((i) => i.id != itemId).toList());
    }).toList();
    _persist();
    notifyListeners();
  }

  void setCutoff(int hour, int minute) {
    cutoffHour = hour;
    cutoffMinute = minute;
    _persist();
    notifyListeners();
  }
}
