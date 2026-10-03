import 'package:intl/intl.dart';

/// Utilidades de formateo de fecha/hora en español para toda la app.
class DateFormatter {
  DateFormatter._();

  /// Ej: "15 mayo 2024 - 08:42 AM"
  static String full(DateTime dateTime) {
    final formatter = DateFormat("d MMM yyyy - hh:mm a", 'es');
    return formatter.format(dateTime.toLocal());
  }

  /// Ej: "08:42 AM"
  static String time(DateTime dateTime) {
    return DateFormat('hh:mm a', 'es').format(dateTime.toLocal());
  }

  /// Ej: "15 may"
  static String shortDay(DateTime dateTime) {
    return DateFormat('d MMM', 'es').format(dateTime.toLocal());
  }

  /// Tiempo relativo simple: "hace 5 min", "hace 2 h", "hace 3 d"
  static String relative(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 1) return 'justo ahora';
    if (diff.inMinutes < 60) return 'hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'hace ${diff.inHours} h';
    return 'hace ${diff.inDays} d';
  }
}
