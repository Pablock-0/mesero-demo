/// Determina a qué "día de negocio" pertenece un momento dado, tomando en
/// cuenta la hora de corte (ej. si el corte es a las 4:00am, una venta hecha
/// a las 2:00am del día 26 todavía pertenece al día de negocio 25).
DateTime businessDateFor(DateTime moment, {required int cutoffHour, int cutoffMinute = 0}) {
  final adjusted = moment.subtract(Duration(hours: cutoffHour, minutes: cutoffMinute));
  return DateTime(adjusted.year, adjusted.month, adjusted.day);
}

String formatDateKey(DateTime day) {
  final y = day.year.toString().padLeft(4, '0');
  final m = day.month.toString().padLeft(2, '0');
  final d = day.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
}

DateTime? parseDateKey(String key) {
  final parts = key.split('-');
  if (parts.length != 3) return null;
  final y = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  final d = int.tryParse(parts[2]);
  if (y == null || m == null || d == null) return null;
  return DateTime(y, m, d);
}

String formatTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String formatDateDisplay(DateTime day) {
  const meses = [
    'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
    'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
  ];
  return '${day.day} de ${meses[day.month - 1]} de ${day.year}';
}
