import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mesero/models/sale_record.dart';
import 'package:mesero/services/sales_repository.dart';
import 'package:mesero/utils/business_date.dart';

void main() {
  late Directory tempDir;
  late SalesRepository repo;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('mesero_test_');
    repo = SalesRepository(documentsDirectoryProvider: () async => tempDir);
  });

  tearDown(() async {
    if (await tempDir.exists()) await tempDir.delete(recursive: true);
  });

  SaleRecord sale(DateTime timestamp) => SaleRecord(
        tableId: 'mesa_1',
        tableName: 'Mesa 1',
        items: const [SaleItemLine(itemId: 'a', name: 'Taco discada', unitPrice: 30, quantity: 1)],
        total: 30,
        paymentMethod: 'efectivo',
        amountPaid: 30,
        change: 0,
        tip: 0,
        timestamp: timestamp,
      );

  test('businessDateFor: una venta antes de la hora de corte pertenece al día anterior', () {
    final day = businessDateFor(DateTime(2026, 7, 26, 2, 30), cutoffHour: 4);
    expect(day, DateTime(2026, 7, 25));
  });

  test('businessDateFor: una venta después de la hora de corte pertenece al día actual', () {
    final day = businessDateFor(DateTime(2026, 7, 26, 10, 0), cutoffHour: 4);
    expect(day, DateTime(2026, 7, 26));
  });

  test('recordSale antes del corte se guarda en el archivo del día de negocio anterior', () async {
    await repo.recordSale(sale(DateTime(2026, 7, 26, 2, 30)), cutoffHour: 4);

    final salesOfPrevDay = await repo.loadDay(DateTime(2026, 7, 25));
    final salesOfCalendarDay = await repo.loadDay(DateTime(2026, 7, 26));

    expect(salesOfPrevDay, hasLength(1));
    expect(salesOfCalendarDay, isEmpty);
  });

  test('purgeOldDays conserva solo los 10 días más recientes', () async {
    for (var i = 0; i < 12; i++) {
      final day = DateTime(2026, 7, 1).add(Duration(days: i));
      await repo.recordSale(sale(day.add(const Duration(hours: 12))), cutoffHour: 0);
    }

    var days = await repo.availableDays();
    expect(days, hasLength(12));

    await repo.purgeOldDays(keep: 10);

    days = await repo.availableDays();
    expect(days, hasLength(10));
    // Se conservan los 10 más recientes (12 y 11 de julio quedan fuera).
    expect(days.contains(DateTime(2026, 7, 1)), isFalse);
    expect(days.contains(DateTime(2026, 7, 2)), isFalse);
    expect(days.contains(DateTime(2026, 7, 12)), isTrue);
  });
}
