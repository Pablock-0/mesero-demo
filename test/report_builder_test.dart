import 'package:flutter_test/flutter_test.dart';
import 'package:mesero/models/sale_record.dart';
import 'package:mesero/utils/report_builder.dart';

void main() {
  final sales = [
    SaleRecord(
      tableId: 'mesa_1',
      tableName: 'Mesa 1',
      items: const [
        SaleItemLine(itemId: 'a', name: 'Taco discada', unitPrice: 30, quantity: 2),
        SaleItemLine(itemId: 'b', name: 'Coca cola', unitPrice: 30, quantity: 1),
      ],
      total: 90,
      paymentMethod: 'efectivo',
      amountPaid: 100,
      change: 10,
      tip: 9,
      timestamp: DateTime(2026, 7, 25, 13, 45),
    ),
    SaleRecord(
      tableId: 'mesa_2',
      tableName: 'Mesa 2',
      items: const [
        SaleItemLine(itemId: 'a', name: 'Taco discada', unitPrice: 30, quantity: 1),
      ],
      total: 30,
      paymentMethod: 'tarjeta',
      tip: 0,
      timestamp: DateTime(2026, 7, 25, 14, 10),
    ),
  ];

  test('DaySummary agrega efectivo, tarjeta, propinas y stock vendido', () {
    final summary = DaySummary.from(sales);
    expect(summary.efectivoTotal, 90);
    expect(summary.tarjetaTotal, 30);
    expect(summary.totalGeneral, 120);
    expect(summary.propinasTotal, 9);
    expect(summary.stockVendido['Taco discada'], 3);
    expect(summary.stockVendido['Coca cola'], 1);
  });

  test('buildCsvReport genera encabezado y una fila por venta', () {
    final csv = buildCsvReport(DateTime(2026, 7, 25), sales);
    final lines = csv.trim().split('\n');
    expect(lines.first, 'mesa,hora,articulos,total,propina,forma_pago');
    expect(lines.length, 3);
    expect(lines[1], contains('Mesa 1'));
    expect(lines[1], contains('90.00'));
  });

  test('buildTxtReport incluye resumen y detalle', () {
    final txt = buildTxtReport(DateTime(2026, 7, 25), sales);
    expect(txt, contains('Dinero en caja (efectivo): \$90'));
    expect(txt, contains('Ventas con tarjeta: \$30'));
    expect(txt, contains('Total del día: \$120'));
    expect(txt, contains('Mesa 1'));
    expect(txt, contains('Mesa 2'));
  });
}
