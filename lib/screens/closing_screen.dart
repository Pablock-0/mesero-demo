import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/sale_record.dart';
import '../state/app_state.dart';
import '../utils/business_date.dart';
import '../utils/money.dart';
import '../utils/report_builder.dart';

class ClosingScreen extends StatefulWidget {
  const ClosingScreen({super.key});

  @override
  State<ClosingScreen> createState() => _ClosingScreenState();
}

class _ClosingScreenState extends State<ClosingScreen> {
  List<DateTime> _availableDays = [];
  DateTime? _selectedDay;
  List<SaleRecord> _sales = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final appState = context.read<AppState>();
    final days = await appState.salesRepository.availableDays();
    setState(() {
      _availableDays = days;
      _selectedDay = days.isNotEmpty ? days.first : null;
      _loading = false;
    });
    if (_selectedDay != null) {
      await _loadDay(_selectedDay!);
    }
  }

  Future<void> _loadDay(DateTime day) async {
    final appState = context.read<AppState>();
    final sales = await appState.salesRepository.loadDay(day);
    if (!mounted) return;
    setState(() {
      _selectedDay = day;
      _sales = sales;
    });
  }

  Future<void> _pickDay() async {
    final picked = await showDialog<DateTime>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Elegir fecha'),
        children: [
          for (final day in _availableDays)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(dialogContext, day),
              child: Text(formatDateDisplay(day)),
            ),
        ],
      ),
    );
    if (picked != null) {
      await _loadDay(picked);
    }
  }

  Future<void> _offerDownload(
    String content, {
    required String baseName,
    required String extension,
    required MimeType mimeType,
  }) async {
    final action = await showModalBottomSheet<String>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Enviar por WhatsApp o correo'),
              onTap: () => Navigator.pop(sheetContext, 'share'),
            ),
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: const Text('Guardar en el dispositivo'),
              onTap: () => Navigator.pop(sheetContext, 'save'),
            ),
          ],
        ),
      ),
    );
    if (action == null || !mounted) return;

    if (action == 'share') {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$baseName.$extension');
      await file.writeAsString(content);
      final result = await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          result.status == ShareResultStatus.success ? 'Enviado' : 'Envío cancelado',
        ),
      ));
    } else {
      final path = await FileSaver.instance.saveAs(
        name: baseName,
        bytes: Uint8List.fromList(utf8.encode(content)),
        fileExtension: extension,
        mimeType: mimeType,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(path != null ? 'Guardado en el dispositivo' : 'Guardado cancelado'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cierre de caja')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_selectedDay == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cierre de caja')),
        body: const Center(child: Text('Aún no hay ventas registradas')),
      );
    }

    final summary = DaySummary.from(_sales);
    final day = _selectedDay!;

    return Scaffold(
      appBar: AppBar(title: const Text('Cierre de caja')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.calendar_today),
            title: Text(formatDateDisplay(day)),
            trailing: _availableDays.length > 1
                ? TextButton(onPressed: _pickDay, child: const Text('Cambiar'))
                : null,
          ),
          const Divider(),
          Text('Resumen', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Dinero en caja (efectivo)', value: formatMoney(summary.efectivoTotal)),
          _SummaryRow(label: 'Ventas con tarjeta', value: formatMoney(summary.tarjetaTotal)),
          _SummaryRow(label: 'Total del día', value: formatMoney(summary.totalGeneral), bold: true),
          _SummaryRow(label: 'Propinas totales', value: formatMoney(summary.propinasTotal)),
          const SizedBox(height: 16),
          Text('Stock vendido', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          if (summary.stockVendido.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Sin ventas'))
          else
            for (final entry in summary.stockVendido.entries)
              _SummaryRow(label: entry.key, value: '${entry.value}'),
          const SizedBox(height: 16),
          Text('Detalle de ventas', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          if (_sales.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Sin ventas'))
          else
            for (final sale in _sales)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('${sale.tableName} — ${formatTime(sale.timestamp)}'),
                subtitle: Text(sale.items.map((l) => '${l.quantity}x ${l.name}').join(', ')),
                trailing: Text('${formatMoney(sale.total)}\n${sale.paymentMethod}', textAlign: TextAlign.right),
                isThreeLine: true,
              ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _offerDownload(
                    buildTxtReport(day, _sales),
                    baseName: 'cierre_${formatDateKey(day)}',
                    extension: 'txt',
                    mimeType: MimeType.text,
                  ),
                  icon: const Icon(Icons.description),
                  label: const Text('Descargar en texto'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _offerDownload(
                    buildCsvReport(day, _sales),
                    baseName: 'cierre_${formatDateKey(day)}',
                    extension: 'csv',
                    mimeType: MimeType.csv,
                  ),
                  icon: const Icon(Icons.table_chart),
                  label: const Text('Descargar en csv'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    final style = bold
        ? Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
