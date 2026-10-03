import 'package:flutter/material.dart';

/// Paleta de colores usada en todo el mockup "App Monitoreo Sísmico".
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF3D3AC4); // Morado/azul del AppBar
  static const Color primaryDark = Color(0xFF2E2B9E);
  static const Color background = Color(0xFFF4F5F9);
  static const Color surface = Colors.white;

  // Colores por rango de magnitud (coherentes con la leyenda del mapa)
  static const Color magHigh = Color(0xFFE53935); // >= 6.0
  static const Color magMedHigh = Color(0xFFFB8C00); // 4.0 - 5.9
  static const Color magMed = Color(0xFFFDD835); // 3.0 - 3.9
  static const Color magLow = Color(0xFF43A047); // < 3.0

  static const Color textPrimary = Color(0xFF1B1B1F);
  static const Color textSecondary = Color(0xFF6B6B76);
  static const Color divider = Color(0xFFE4E4EA);

  /// Devuelve el color correspondiente según la magnitud del sismo.
  static Color colorForMagnitude(double magnitude) {
    if (magnitude >= 6.0) return magHigh;
    if (magnitude >= 4.0) return magMedHigh;
    if (magnitude >= 3.0) return magMed;
    return magLow;
  }
}
