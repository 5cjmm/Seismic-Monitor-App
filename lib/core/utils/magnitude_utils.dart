/// Utilidades para clasificar y describir la magnitud de un sismo.
class MagnitudeUtils {
  MagnitudeUtils._();

  static String rangeLabel(double magnitude) {
    if (magnitude >= 6.0) return '≥ 6.0';
    if (magnitude >= 4.0) return '4.0 - 5.9';
    if (magnitude >= 3.0) return '3.0 - 3.9';
    return '< 3.0';
  }

  static String severityDescription(double magnitude) {
    if (magnitude >= 7.0) return 'Mayor';
    if (magnitude >= 6.0) return 'Fuerte';
    if (magnitude >= 5.0) return 'Moderado';
    if (magnitude >= 4.0) return 'Ligero';
    if (magnitude >= 3.0) return 'Menor';
    return 'Micro';
  }
}
