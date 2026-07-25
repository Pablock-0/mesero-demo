import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/sale_record.dart';
import '../utils/business_date.dart';

class SalesRepository {
  final Future<Directory> Function() _documentsDirectoryProvider;
  Directory? _ventasDir;

  SalesRepository({Future<Directory> Function()? documentsDirectoryProvider})
      : _documentsDirectoryProvider = documentsDirectoryProvider ?? getApplicationDocumentsDirectory;

  Future<Directory> _dir() async {
    if (_ventasDir != null) return _ventasDir!;
    final docs = await _documentsDirectoryProvider();
    final dir = Directory('${docs.path}/ventas');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    _ventasDir = dir;
    return dir;
  }

  Future<File> _fileForDay(DateTime day) async {
    final dir = await _dir();
    return File('${dir.path}/ventas_${formatDateKey(day)}.jsonl');
  }

  Future<void> recordSale(SaleRecord sale, {required int cutoffHour, int cutoffMinute = 0}) async {
    final day = businessDateFor(sale.timestamp, cutoffHour: cutoffHour, cutoffMinute: cutoffMinute);
    final file = await _fileForDay(day);
    await file.writeAsString('${jsonEncode(sale.toJson())}\n', mode: FileMode.append);
  }

  Future<List<SaleRecord>> loadDay(DateTime day) async {
    final file = await _fileForDay(day);
    if (!await file.exists()) return [];
    final lines = await file.readAsLines();
    return lines
        .where((l) => l.trim().isNotEmpty)
        .map((l) => SaleRecord.fromJson(jsonDecode(l) as Map<String, dynamic>))
        .toList();
  }

  Future<List<DateTime>> availableDays() async {
    final dir = await _dir();
    if (!await dir.exists()) return [];
    final days = <DateTime>[];
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final name = entity.uri.pathSegments.last;
      final match = RegExp(r'^ventas_(\d{4}-\d{2}-\d{2})\.jsonl$').firstMatch(name);
      if (match == null) continue;
      final parsed = parseDateKey(match.group(1)!);
      if (parsed != null) days.add(parsed);
    }
    days.sort((a, b) => b.compareTo(a));
    return days;
  }

  Future<void> deleteDay(DateTime day) async {
    final file = await _fileForDay(day);
    if (await file.exists()) await file.delete();
  }

  /// Conserva solo los [keep] días más recientes con ventas registradas y
  /// borra el resto, para no saturar el almacenamiento del celular.
  Future<void> purgeOldDays({int keep = 10}) async {
    final days = await availableDays(); // ya vienen ordenados del más reciente al más viejo
    if (days.length <= keep) return;
    for (final day in days.skip(keep)) {
      await deleteDay(day);
    }
  }
}
