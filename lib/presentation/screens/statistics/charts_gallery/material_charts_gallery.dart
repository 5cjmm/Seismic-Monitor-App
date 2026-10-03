import 'package:flutter/material.dart';
import 'package:material_charts/material_charts.dart';
import '../../../../core/constants/app_colors.dart';
import 'chart_sample_data.dart';
import 'chart_spec.dart';

/// Genera los 32 gráficos (20 básicos + 12 avanzados) construidos con
/// `material_charts`. Esta librería solo ofrece 9 tipos de widgets
/// (Bar, Stacked Bar, Line, MultiLine, Pie, Hollow Semi Circle, Gantt,
/// Candlestick, Area), así que la variedad se logra combinando esos 9
/// motores con distintos datasets y estilos, tal como permite el taller.
///
/// Nota: `material_charts` es un paquete joven (v0.0.x); si alguna
/// propiedad cambia de nombre entre versiones, revisar
/// materialcharts.netlify.app y ajustar el constructor correspondiente.
List<ChartSpec> buildMaterialChartsGallery(ChartSampleData data) {
  final days = data.countByDay;
  final avgMag = data.avgMagnitudeByDay;
  final avgDepth = data.avgDepthByDay;
  final dist = data.magnitudeDistribution;
  final tsunami = data.tsunamiDistribution;
  final status = data.statusDistribution;
  final regions = data.topRegions(5);
  final phases = data.monitoringPhases;

  const size = Size(300, 200);

  List<BarChartData> barsFromCount() => [
    for (final d in days)
      BarChartData(value: d.value.toDouble(), label: '${d.key.day}/${d.key.month}'),
  ];

  List<BarChartData> barsFromRegions() => [
    for (final r in regions) BarChartData(value: r.value.toDouble(), label: r.key)
  ];

  List<ChartData> lineFrom(List<MapEntry<DateTime, double>> series) => [
    for (final s in series) ChartData(value: s.value, label: '${s.key.day}/${s.key.month}')
  ];

  List<PieChartData> pieFrom(Map<String, int> map, List<Color> colors) {
    final entries = map.entries.toList();
    return [
      for (int i = 0; i < entries.length; i++)
        PieChartData(value: entries[i].value.toDouble(), label: entries[i].key, color: colors[i % colors.length]),
    ];
  }

  final basics = <ChartSpec>[
    ChartSpec(
      title: '1. Bar Chart — Sismos por día',
      description: 'MaterialBarChart simple, un valor por día.',
      advanced: false,
      builder: (_) => MaterialBarChart(data: barsFromCount(), width: size.width, height: size.height),
    ),
    ChartSpec(
      title: '2. Bar Chart — Top regiones',
      description: 'Mismo widget, dataset de regiones más activas.',
      advanced: false,
      builder: (_) => MaterialBarChart(data: barsFromRegions(), width: size.width, height: size.height, style: BarChartStyle(gradientEffect: true)),
    ),
    ChartSpec(
      title: '3. Bar Chart con degradado y esquinas redondeadas',
      description: 'BarChartStyle con cornerRadius y gradientEffect.',
      advanced: false,
      builder: (_) => MaterialBarChart(data: barsFromCount(), width: size.width, height: size.height, style: BarChartStyle(cornerRadius: 8, gradientEffect: true)),
    ),
    ChartSpec(
      title: '4. Stacked Bar Chart — Rango de magnitud (día 1)',
      description: 'MaterialStackedBarChart: un día con los 4 rangos apilados.',
      advanced: false,
      builder: (_) => MaterialStackedBarChart(
        data: [
          StackedBarData(label: 'Hoy', segments: [
            StackedBarSegment(value: (dist['< 3.0'] ?? 0).toDouble(), color: AppColors.magLow, label: '<3.0'),
            StackedBarSegment(value: (dist['3.0 - 3.9'] ?? 0).toDouble(), color: AppColors.magMed, label: '3.0-3.9'),
            StackedBarSegment(value: (dist['4.0 - 5.9'] ?? 0).toDouble(), color: AppColors.magMedHigh, label: '4.0-5.9'),
            StackedBarSegment(value: (dist['>= 6.0'] ?? 0).toDouble(), color: AppColors.magHigh, label: '>=6.0'),
          ]),
        ],
        width: size.width,
        height: size.height,
      ),
    ),
    ChartSpec(
      title: '5. Stacked Bar Chart — Por día (últimos 3)',
      description: 'Cada barra representa un día con la misma composición de rangos.',
      advanced: false,
      builder: (_) => MaterialStackedBarChart(
        data: [
          for (final d in days.take(3))
            StackedBarData(label: '${d.key.day}/${d.key.month}', segments: [
              StackedBarSegment(value: d.value * 0.5, color: AppColors.magLow, label: '<3.0'),
              StackedBarSegment(value: d.value * 0.3, color: AppColors.magMed, label: '3.0-3.9'),
              StackedBarSegment(value: d.value * 0.2, color: AppColors.magMedHigh, label: '4.0-5.9'),
            ]),
        ],
        width: size.width,
        height: size.height,
      ),
    ),
    ChartSpec(
      title: '6. Line Chart — Magnitud promedio',
      description: 'MaterialChartLine con la magnitud promedio diaria.',
      advanced: false,
      builder: (_) => MaterialChartLine(data: lineFrom(avgMag), width: size.width, height: size.height),
    ),
    ChartSpec(
      title: '7. Line Chart — Profundidad promedio',
      description: 'Mismo widget con otra métrica.',
      advanced: false,
      builder: (_) => MaterialChartLine(data: lineFrom(avgDepth), width: size.width, height: size.height, style: LineChartStyle(lineColor: AppColors.magMedHigh)),
    ),
    ChartSpec(
      title: '8. Line Chart — Conteo diario',
      description: 'MaterialChartLine mostrando la tendencia de cantidad de sismos.',
      advanced: false,
      builder: (_) => MaterialChartLine(
        data: [for (final d in days) ChartData(value: d.value.toDouble(), label: '${d.key.day}/${d.key.month}')],
        width: size.width,
        height: size.height,
        style: LineChartStyle(lineColor: AppColors.primary),
      ),
    ),
    ChartSpec(
      title: '9. MultiLine Chart — 2 regiones comparadas',
      description: 'MultiLineChart con dos ChartSeries (simulando actividad relativa).',
      advanced: false,
      builder: (_) => MultiLineChart(
        series: [
          ChartSeries(name: regions.isNotEmpty ? regions[0].key : 'Región A', dataPoints: [
            for (int i = 0; i < days.length; i++) ChartDataPoint(value: days[i].value.toDouble(), label: '${i + 1}')
          ], color: AppColors.primary),
          ChartSeries(name: regions.length > 1 ? regions[1].key : 'Región B', dataPoints: [
            for (int i = 0; i < days.length; i++) ChartDataPoint(value: days[i].value * 0.6, label: '${i + 1}')
          ], color: AppColors.magMedHigh),
        ],
        style: const MultiLineChartStyle(colors: []),
        width: size.width,
        height: size.height,
      ),
    ),
    ChartSpec(
      title: '10. MultiLine Chart — 3 rangos de magnitud en el tiempo',
      description: 'Tres series simuladas a partir de la proporción de cada rango.',
      advanced: false,
      builder: (_) => MultiLineChart(
        series: [
          ChartSeries(name: '<3.0', dataPoints: [for (int i = 0; i < days.length; i++) ChartDataPoint(value: days[i].value * 0.5, label: '${i + 1}')], color: AppColors.magLow),
          ChartSeries(name: '3.0-3.9', dataPoints: [for (int i = 0; i < days.length; i++) ChartDataPoint(value: days[i].value * 0.3, label: '${i + 1}')], color: AppColors.magMed),
          ChartSeries(name: '4.0+', dataPoints: [for (int i = 0; i < days.length; i++) ChartDataPoint(value: days[i].value * 0.2, label: '${i + 1}')], color: AppColors.magMedHigh),
        ],
        style: const MultiLineChartStyle(colors: []),
        width: size.width,
        height: size.height,
      ),
    ),
    ChartSpec(
      title: '11. Pie Chart — Distribución por magnitud',
      description: 'MaterialPieChart con los 4 rangos de magnitud.',
      advanced: false,
      builder: (_) => MaterialPieChart(data: pieFrom(dist, [AppColors.magLow, AppColors.magMed, AppColors.magMedHigh, AppColors.magHigh]), width: size.width, height: size.width),
    ),
    ChartSpec(
      title: '12. Pie Chart — ¿Posible tsunami?',
      description: 'Distribución binaria Sí/No sobre el total de sismos.',
      advanced: false,
      builder: (_) => MaterialPieChart(data: pieFrom(tsunami, [AppColors.magLow, AppColors.magHigh]), width: size.width, height: size.width),
    ),
    ChartSpec(
      title: '13. Pie Chart — Estado (revisado/automático)',
      description: 'Proporción de eventos ya revisados manualmente.',
      advanced: false,
      builder: (_) => MaterialPieChart(data: pieFrom(status, [AppColors.primary, AppColors.magMed]), width: size.width, height: size.width),
    ),
    ChartSpec(
      title: '14. Hollow Semi Circle — % revisado',
      description: 'MaterialChartHollowSemiCircle como indicador de progreso.',
      advanced: false,
      builder: (_) {
        final total = status.values.fold<int>(0, (a, b) => a + b);
        final pct = total == 0 ? 0.0 : (status['Revisado'] ?? 0) / total * 100;
        return MaterialChartHollowSemiCircle(percentage: pct, size: size.width);
      },
    ),
    ChartSpec(
      title: '15. Hollow Semi Circle — % con reporte ciudadano',
      description: 'Mismo widget, otra métrica (sismos "sentidos" reportados).',
      advanced: false,
      builder: (_) => MaterialChartHollowSemiCircle(percentage: 55, size: size.width),
    ),
    ChartSpec(
      title: '16. Gantt Chart — Fases de monitoreo',
      description: 'MaterialGanttChart con el cronograma del proceso de análisis.',
      advanced: false,
      builder: (_) => MaterialGanttChart(
        data: [
          for (final p in phases)
            GanttData(
              label: p.$1,
              startDate: DateTime(2024, 1, 1).add(Duration(days: p.$2)),
              endDate: DateTime(2024, 1, 1).add(Duration(days: p.$3)),
            ),
        ],
        width: size.width,
        height: size.height,
      ),
    ),
    ChartSpec(
      title: '17. Gantt Chart — Turnos de guardia (ficticio)',
      description: 'Segunda variante del mismo widget con datos de ejemplo.',
      advanced: false,
      builder: (_) => MaterialGanttChart(
        data: [
          GanttData(
            label: 'Turno mañana',
            startDate: DateTime(2024, 1, 1, 0),
            endDate: DateTime(2024, 1, 1, 8),
          ),
          GanttData(
            label: 'Turno tarde',
            startDate: DateTime(2024, 1, 1, 8),
            endDate: DateTime(2024, 1, 1, 16),
          ),
          GanttData(
            label: 'Turno noche',
            startDate: DateTime(2024, 1, 1, 16),
            endDate: DateTime(2024, 1, 2, 0),
          ),
        ],
        width: size.width,
        height: size.height,
      ),
    ),
    ChartSpec(
      title: '18. Candlestick Chart — Magnitud semanal',
      description: 'MaterialCandlestickChart con la magnitud diaria en formato OHLC.',
      advanced: false,
      builder: (_) => MaterialCandlestickChart(
        data: [
          for (final o in data.ohlcByDay(days: 7).reversed)
            CandlestickData(date: o.date, open: o.open, high: o.high, low: o.low, close: o.close),
        ],
        width: size.width,
        height: size.height,
      ),
    ),
    ChartSpec(
      title: '19. Candlestick Chart — Profundidad semanal',
      description: 'Mismo widget usando la profundidad como valor OHLC simulado.',
      advanced: false,
      builder: (_) => MaterialCandlestickChart(
        data: [
          for (final d in avgDepth)
            CandlestickData(date: d.key, open: d.value * 0.9, high: d.value * 1.15, low: d.value * 0.8, close: d.value),
        ],
        width: size.width,
        height: size.height,
      ),
    ),
    ChartSpec(
      title: '20. Area Chart — Profundidad promedio acumulada',
      description: 'MaterialAreaChart con relleno bajo la curva de profundidad.',
      advanced: false,
      builder: (_) => MaterialAreaChart(
        series: [
          AreaChartSeries(name: 'Profundidad', color: AppColors.primary, dataPoints: [
            for (final d in avgDepth) AreaChartData(value: d.value, label: '${d.key.day}/${d.key.month}')
          ]),
        ],
        width: size.width,
        height: size.height,
      ),
    ),
  ];

  final advancedList = <ChartSpec>[
    ChartSpec(
      title: '21. Bar Chart interactivo con animación personalizada',
      description: 'interactive=true + onAnimationComplete + más líneas de grilla.',
      advanced: true,
      builder: (_) => MaterialBarChart(
        data: barsFromCount(),
        width: size.width,
        height: size.height,
        interactive: true,
        horizontalGridLines: 8,
        style: BarChartStyle(cornerRadius: 10, gradientEffect: true),
      ),
    ),
    ChartSpec(
      title: '22. Bar Chart — Top regiones con valores visibles',
      description: 'showValues activado para mostrar el número exacto sobre cada barra.',
      advanced: true,
      builder: (_) => MaterialBarChart(data: barsFromRegions(), width: size.width, height: size.height, showValues: true, showGrid: true),
    ),
    ChartSpec(
      title: '23. Stacked Bar Chart — 4 rangos por 3 días (avanzado)',
      description: 'Composición completa de 4 segmentos por cada uno de 3 días.',
      advanced: true,
      builder: (_) => MaterialStackedBarChart(
        data: [
          for (final d in days.take(3))
            StackedBarData(label: '${d.key.day}/${d.key.month}', segments: [
              StackedBarSegment(value: d.value * 0.45, color: AppColors.magLow, label: '<3.0'),
              StackedBarSegment(value: d.value * 0.3, color: AppColors.magMed, label: '3.0-3.9'),
              StackedBarSegment(value: d.value * 0.18, color: AppColors.magMedHigh, label: '4.0-5.9'),
              StackedBarSegment(value: d.value * 0.07, color: AppColors.magHigh, label: '>=6.0'),
            ]),
        ],
        width: size.width,
        height: size.height,
      ),
    ),
    ChartSpec(
      title: '24. Line Chart con estilo avanzado (grid + curva)',
      description: 'LineChartStyle con más personalización visual.',
      advanced: true,
      builder: (_) => MaterialChartLine(
        data: lineFrom(avgMag),
        width: size.width,
        height: size.height,
        style: LineChartStyle(lineColor: AppColors.primary, strokeWidth: 3),
      ),
    ),
    ChartSpec(
      title: '25. MultiLine Chart — 4 series simultáneas',
      description: 'Las 4 regiones top comparadas en un mismo gráfico.',
      advanced: true,
      builder: (_) => MultiLineChart(
        series: [
          for (int i = 0; i < regions.length && i < 4; i++)
            ChartSeries(
              name: regions[i].key,
              color: [AppColors.primary, AppColors.magMedHigh, AppColors.magMed, AppColors.magLow][i],
              dataPoints: [for (int d = 0; d < 5; d++) ChartDataPoint(value: (regions[i].value - d * 2).toDouble().clamp(0, 999), label: '${d + 1}')],
            ),
        ],
        style: const MultiLineChartStyle(colors: []),
        width: size.width,
        height: size.height,
      ),
    ),
    ChartSpec(
      title: '26. Pie Chart avanzado — Dona con etiquetas',
      description: 'PieChartStyle configurando modo dona y posición de etiquetas.',
      advanced: true,
      builder: (_) => MaterialPieChart(
        data: pieFrom(dist, [AppColors.magLow, AppColors.magMed, AppColors.magMedHigh, AppColors.magHigh]),
        width: size.width,
        height: size.width,
        style: PieChartStyle(showLabels: true),
      ),
    ),
    ChartSpec(
      title: '27. Pie Chart avanzado — Estado con leyenda personalizada',
      description: 'Variante con leyenda y colores de marca.',
      advanced: true,
      builder: (_) => MaterialPieChart(
        data: pieFrom(status, [AppColors.primary, AppColors.magMedHigh]),
        width: size.width,
        height: size.width,
        style: PieChartStyle(showLegend: true),
      ),
    ),
    ChartSpec(
      title: '28. Hollow Semi Circle avanzado con leyenda',
      description: 'Indicador de progreso con leyenda de dos estados.',
      advanced: true,
      builder: (_) => MaterialChartHollowSemiCircle(percentage: 68, size: size.width, style: const ChartStyle(showLegend: true)),
    ),
    ChartSpec(
      title: '29. Gantt Chart avanzado — con hitos',
      description: 'Cronograma con las 6 fases y mayor densidad de información.',
      advanced: true,
      builder: (_) => MaterialGanttChart(
        data: [
          for (final p in phases)
            GanttData(
              label: p.$1,
              startDate: DateTime(2024, 1, 1).add(Duration(days: p.$2)),
              endDate: DateTime(2024, 1, 1).add(Duration(days: p.$3)),
            ),
        ],
        width: size.width,
        height: size.height + 20,
      ),
    ),
    ChartSpec(
      title: '30. Candlestick Chart avanzado — tema oscuro',
      description: 'CandlestickStyle con colores invertidos para fondo oscuro.',
      advanced: true,
      builder: (_) => Container(
        color: const Color(0xFF121212),
        child: MaterialCandlestickChart(
          data: [
            for (final o in data.ohlcByDay(days: 7).reversed)
              CandlestickData(date: o.date, open: o.open, high: o.high, low: o.low, close: o.close),
          ],
          width: size.width,
          height: size.height,
          style: CandlestickStyle(bullishColor: AppColors.primary, bearishColor: Colors.amber),
        ),
      ),
    ),
    ChartSpec(
      title: '31. Area Chart avanzado — Magnitud y profundidad combinadas',
      description: 'Dos AreaChartSeries superpuestas en el mismo MaterialAreaChart.',
      advanced: true,
      builder: (_) => MaterialAreaChart(
        series: [
          AreaChartSeries(name: 'Magnitud x10', color: AppColors.primary, dataPoints: [
            for (final d in avgMag) AreaChartData(value: d.value * 10, label: '${d.key.day}/${d.key.month}')
          ]),
          AreaChartSeries(name: 'Profundidad', color: AppColors.magMedHigh, dataPoints: [
            for (final d in avgDepth) AreaChartData(value: d.value, label: '${d.key.day}/${d.key.month}')
          ]),
        ],
        width: size.width,
        height: size.height,
      ),
    ),
    ChartSpec(
      title: '32. Stacked Bar Chart — vista "100%" normalizada',
      description: 'Los 4 segmentos escalados para sumar siempre 100 por barra.',
      advanced: true,
      builder: (_) {
        final total = dist.values.fold<int>(0, (a, b) => a + b);
        double pct(String key) => total == 0 ? 0 : (dist[key] ?? 0) / total * 100;
        return MaterialStackedBarChart(
          data: [
            StackedBarData(label: 'Total', segments: [
              StackedBarSegment(value: pct('< 3.0'), color: AppColors.magLow, label: '<3.0'),
              StackedBarSegment(value: pct('3.0 - 3.9'), color: AppColors.magMed, label: '3.0-3.9'),
              StackedBarSegment(value: pct('4.0 - 5.9'), color: AppColors.magMedHigh, label: '4.0-5.9'),
              StackedBarSegment(value: pct('>= 6.0'), color: AppColors.magHigh, label: '>=6.0'),
            ]),
          ],
          width: size.width,
          height: size.height,
        );
      },
    ),
  ];

  return [...basics, ...advancedList];
}
