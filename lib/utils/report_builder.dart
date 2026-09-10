import '../models/sale_record.dart';
import 'business_date.dart';
import 'money.dart';

class DaySummary {
  final double efectivoTotal;
  final double tarjetaTotal;
  final double propinasTotal;
  final Map<String, int> stockVendido; // nombre -> cantidad

  DaySummary({
    required this.efectivoTotal,
    required this.tarjetaTotal,
    required this.propinasTotal,
    required this.stockVendido,
  });

  double get totalGeneral => efectivoTotal + tarjetaTotal;

  factory DaySummary.from(List<SaleRecord> sales) {
    var efectivo = 0.0;
    var tarjeta = 0.0;
    var propinas = 0.0;
    final stock = <String, int>{};
    for (final sale in sales) {
      if (sale.paymentMethod == 'efectivo') {
        efectivo += sale.total;
      } else {
        tarjeta += sale.total;
      }
      propinas += sale.tip;
      for (final line in sale.items) {
        stock[line.name] = (stock[line.name] ?? 0) + line.quantity;
      }
    }
    return DaySummary(
      efectivoTotal: efectivo,
      tarjetaTotal: tarjeta,
      propinasTotal: propinas,
      stockVendido: stock,
    );
  }
}

String _itemsDescription(SaleRecord sale) {
  return sale.items.map((l) => '${l.quantity}x ${l.name}').join(', ');
}

String buildTxtReport(DateTime day, List<SaleRecord> sales) {
  final summary = DaySummary.from(sales);
  final buffer = StringBuffer();
  buffer.writeln('Cierre de caja — ${formatDateDisplay(day)}');
  buffer.writeln();
  buffer.writeln('RESUMEN');
  buffer.writeln('Dinero en caja (efectivo): ${formatMoney(summary.efectivoTotal)}');
  buffer.writeln('Ventas con tarjeta: ${formatMoney(summary.tarjetaTotal)}');
  buffer.writeln('Total del día: ${formatMoney(summary.totalGeneral)}');
  buffer.writeln('Propinas totales: ${formatMoney(summary.propinasTotal)}');
  buffer.writeln();
  buffer.writeln('STOCK VENDIDO');
  if (summary.stockVendido.isEmpty) {
    buffer.writeln('(sin ventas)');
  } else {
    for (final entry in summary.stockVendido.entries) {
      buffer.writeln('${entry.key}: ${entry.value}');
    }
  }
  buffer.writeln();
  buffer.writeln('DETALLE DE VENTAS');
  if (sales.isEmpty) {
    buffer.writeln('(sin ventas)');
  } else {
    for (final sale in sales) {
      buffer.writeln(
        '${sale.tableName} | ${formatTime(sale.timestamp)} | ${_itemsDescription(sale)} | '
        'Total: ${formatMoney(sale.total)} | Propina: ${formatMoney(sale.tip)} | ${sale.paymentMethod}',
      );
    }
  }
  return buffer.toString();
}

String _csvField(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}

String buildCsvReport(DateTime day, List<SaleRecord> sales) {
  final buffer = StringBuffer();
  buffer.writeln('mesa,hora,articulos,total,propina,forma_pago');
  for (final sale in sales) {
    buffer.writeln([
      _csvField(sale.tableName),
      _csvField(formatTime(sale.timestamp)),
      _csvField(_itemsDescription(sale)),
      sale.total.toStringAsFixed(2),
      sale.tip.toStringAsFixed(2),
      _csvField(sale.paymentMethod),
    ].join(','));
  }
  return buffer.toString();
}
