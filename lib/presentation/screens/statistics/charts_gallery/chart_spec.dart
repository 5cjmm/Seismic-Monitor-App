import 'package:flutter/material.dart';

/// Representa UN gráfico dentro de la galería: su título, una breve
/// descripción de qué datos/tipo de gráfico ilustra, si pertenece a la
/// categoría "básico" o "avanzado", y el widget que lo construye.
///
/// Todas las galerías (material_charts, candlesticks, syncfusion,
/// fl_chart) se representan como una `List<ChartSpec>` de esta clase,
/// lo que permite renderizarlas todas con el mismo widget contenedor
/// (`ChartCard` + `ChartGallerySection`) sin duplicar UI.
class ChartSpec {
  final String title;
  final String description;
  final bool advanced;
  final WidgetBuilder builder;

  const ChartSpec({
    required this.title,
    required this.description,
    required this.advanced,
    required this.builder,
  });
}
