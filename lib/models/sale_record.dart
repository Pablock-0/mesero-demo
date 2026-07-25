class SaleItemLine {
  final String itemId;
  final String name;
  final double unitPrice;
  final int quantity;

  const SaleItemLine({
    required this.itemId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineTotal => unitPrice * quantity;

  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'name': name,
        'unitPrice': unitPrice,
        'quantity': quantity,
      };

  factory SaleItemLine.fromJson(Map<String, dynamic> json) => SaleItemLine(
        itemId: json['itemId'] as String,
        name: json['name'] as String,
        unitPrice: (json['unitPrice'] as num).toDouble(),
        quantity: json['quantity'] as int,
      );
}

class SaleRecord {
  final String tableId;
  final String tableName;
  final List<SaleItemLine> items;
  final double total;
  final String paymentMethod; // 'efectivo' | 'tarjeta'
  final double? amountPaid;
  final double? change;
  final double tip;
  final DateTime timestamp;

  const SaleRecord({
    required this.tableId,
    required this.tableName,
    required this.items,
    required this.total,
    required this.paymentMethod,
    this.amountPaid,
    this.change,
    required this.tip,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'tableId': tableId,
        'tableName': tableName,
        'items': items.map((e) => e.toJson()).toList(),
        'total': total,
        'paymentMethod': paymentMethod,
        'amountPaid': amountPaid,
        'change': change,
        'tip': tip,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SaleRecord.fromJson(Map<String, dynamic> json) => SaleRecord(
        tableId: json['tableId'] as String,
        tableName: json['tableName'] as String,
        items: (json['items'] as List)
            .map((e) => SaleItemLine.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: (json['total'] as num).toDouble(),
        paymentMethod: json['paymentMethod'] as String,
        amountPaid: (json['amountPaid'] as num?)?.toDouble(),
        change: (json['change'] as num?)?.toDouble(),
        tip: (json['tip'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp'] as String),
      );
}
