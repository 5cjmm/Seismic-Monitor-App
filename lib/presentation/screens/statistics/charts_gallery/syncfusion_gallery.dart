import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import 'chart_sample_data.dart';
import 'chart_spec.dart';

class _DayValue {
  final String day;
  final double value;
  _DayValue(this.day, this.value);
}

class _NamedValue {
  final String name;
  final double value;
  _NamedValue(this.name, this.value);
}

/// Genera los 32 gráficos (20 básicos + 12 avanzados) construidos con
/// `syncfusion_flutter_charts`.
List<ChartSpec> buildSyncfusionGallery(ChartSampleData data) {
  final days = data.countByDay;
  final avgMag = data.avgMagnitudeByDay;
  final dist = data.magnitudeDistribution;
  final scatter = data.depthVsMagnitudeScatter;
  final regions = data.topRegions(6);
  final ohlc = data.ohlcByDay(days: 7);
  final boxWhisker = data.depthBoxWhiskerByMagnitudeRange;
  final funnel = data.severityFunnel;
  final waterfall = data.dailyChangeWaterfall;

  final countSeries = [for (int i = 0; i < days.length; i++) _DayValue(DateFormatter.shortDay(days[i].key), days[i].value.toDouble())];
  final magSeries = [for (int i = 0; i < avgMag.length; i++) _DayValue(DateFormatter.shortDay(avgMag[i].key), avgMag[i].value)];
  final regionSeries = [for (final r in regions) _NamedValue(r.key, r.value.toDouble())];
  final distSeries = [for (final e in dist.entries) _NamedValue(e.key, e.value.toDouble())];

  CartesianSeries<_DayValue, String> columnSeries(Color color) => ColumnSeries<_DayValue, String>(
    dataSource: countSeries,
    xValueMapper: (d, _) => d.day,
    yValueMapper: (d, _) => d.value,
    color: color,
  );

  final basics = <ChartSpec>[
    ChartSpec(
      title: '1. Columnas — Sismos por día',
      description: 'ColumnSeries simple sobre CategoryAxis.',
      advanced: false,
      builder: (_) => SfCartesianChart(primaryXAxis: const CategoryAxis(), series: [columnSeries(AppColors.primary)]),
    ),
    ChartSpec(
      title: '2. Barras horizontales — Top regiones',
      description: 'BarSeries (columnas rotadas 90°).',
      advanced: false,
      builder: (_) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        series: [
          BarSeries<_NamedValue, String>(
            dataSource: regionSeries,
            xValueMapper: (d, _) => d.name,
            yValueMapper: (d, _) => d.value,
            color: AppColors.magMedHigh,
          ),
        ],
      ),
    ),
    ChartSpec(
      title: '3. Línea — Magnitud promedio',
      description: 'LineSeries simple.',
      advanced: false,
      builder: (_) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        series: [
          LineSeries<_DayValue, String>(dataSource: magSeries, xValueMapper: (d, _) => d.day, yValueMapper: (d, _) => d.value, color: AppColors.primary),
        ],
      ),
    ),
    ChartSpec(
      title: '4. Spline — Curva suavizada de magnitud',
      description: 'SplineSeries interpola suavemente entre puntos.',
      advanced: false,
      builder: (_) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        series: [
          SplineSeries<_DayValue, String>(dataSource: magSeries, xValueMapper: (d, _) => d.day, yValueMapper: (d, _) => d.value, color: AppColors.magMed),
        ],
      ),
    ),
    ChartSpec(
      title: '5. StepLine — Cambios abruptos de magnitud',
      description: 'StepLineSeries, útil para mostrar cambios discretos.',
      advanced: false,
      builder: (_) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        series: [
          StepLineSeries<_DayValue, String>(dataSource: magSeries, xValueMapper: (d, _) => d.day, yValueMapper: (d, _) => d.value, color: AppColors.magHigh),
        ],
      ),
    ),
    ChartSpec(
      title: '6. Área — Sismos por día',
      description: 'AreaSeries con relleno bajo la curva.',
      advanced: false,
      builder: (_) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        series: [
          AreaSeries<_DayValue, String>(dataSource: countSeries, xValueMapper: (d, _) => d.day, yValueMapper: (d, _) => d.value, color: AppColors.primary.withValues(alpha: 0.4), borderColor: AppColors.primary),
        ],
      ),
    ),
    ChartSpec(
      title: '7. Dispersión — Profundidad vs Magnitud',
      description: 'ScatterSeries con un punto por sismo.',
      advanced: false,
      builder: (_) => SfCartesianChart(
        primaryXAxis: const NumericAxis(title: AxisTitle(text: 'Magnitud')),
        primaryYAxis: const NumericAxis(title: AxisTitle(text: 'Profundidad (km)')),
        series: [
          ScatterSeries<dynamic, double>(
            dataSource: scatter,
            xValueMapper: (d, _) => d.x,
            yValueMapper: (d, _) => d.y,
            color: AppColors.primary,
          ),
        ],
      ),
    ),
    ChartSpec(
      title: '8. Burbujas — Magnitud, profundidad y tamaño',
      description: 'BubbleSeries: el tamaño representa una 3ra variable.',
      advanced: false,
      builder: (_) => SfCartesianChart(
        primaryXAxis: const NumericAxis(title: AxisTitle(text: 'Magnitud')),
        primaryYAxis: const NumericAxis(title: AxisTitle(text: 'Profundidad')),
        series: [
          BubbleSeries<dynamic, double>(
            dataSource: scatter,
            xValueMapper: (d, _) => d.x,
            yValueMapper: (d, _) => d.y,
            sizeValueMapper: (d, _) => d.size,
            color: AppColors.magMedHigh.withValues(alpha: 0.6),
          ),
        ],
      ),
    ),
    ChartSpec(
      title: '9. Circular — Distribución por magnitud',
      description: 'PieSeries clásico.',
      advanced: false,
      builder: (_) => SfCircularChart(series: [
        PieSeries<_NamedValue, String>(dataSource: distSeries, xValueMapper: (d, _) => d.name, yValueMapper: (d, _) => d.value, dataLabelSettings: const DataLabelSettings(isVisible: true)),
      ]),
    ),
    ChartSpec(
      title: '10. Dona — Distribución por magnitud',
      description: 'DoughnutSeries con leyenda.',
      advanced: false,
      builder: (_) => SfCircularChart(legend: const Legend(isVisible: true, position: LegendPosition.bottom), series: [
        DoughnutSeries<_NamedValue, String>(dataSource: distSeries, xValueMapper: (d, _) => d.name, yValueMapper: (d, _) => d.value),
      ]),
    ),
    ChartSpec(
      title: '11. Barra radial — % revisados (ficticio)',
      description: 'RadialBarSeries mostrando un progreso.',
      advanced: false,
      builder: (_) => SfCircularChart(series: [
        RadialBarSeries<_NamedValue, String>(
          dataSource: [_NamedValue('Revisado', 68), _NamedValue('Restante', 32)],
          xValueMapper: (d, _) => d.name,
          yValueMapper: (d, _) => d.value,
        ),
      ]),
    ),
    ChartSpec(
      title: '12. Pirámide — Etapas de severidad',
      description: 'SfPyramidChart con las 4 etapas del embudo de severidad.',
      advanced: false,
      builder: (_) => SfPyramidChart(
        series: PyramidSeries<_NamedValue, String>(
          dataSource: [for (final e in funnel.entries) _NamedValue(e.key, e.value.toDouble())],
          xValueMapper: (d, _) => d.name,
          yValueMapper: (d, _) => d.value,
        ),
      ),
    ),
    ChartSpec(
      title: '13. Embudo — Alertas emitidas',
      description: 'SfFunnelChart, mismo dataset en forma de embudo.',
      advanced: false,
      builder: (_) => SfFunnelChart(
        series: FunnelSeries<_NamedValue, String>(
          dataSource: [for (final e in funnel.entries) _NamedValue(e.key, e.value.toDouble())],
          xValueMapper: (d, _) => d.name,
          yValueMapper: (d, _) => d.value,
          dataLabelSettings: const DataLabelSettings(isVisible: true),
        ),
      ),
    ),
    ChartSpec(
      title: '14. Spark Line — Mini tendencia de magnitud',
      description: 'SfSparkLineChart compacto, ideal para tarjetas.',
      advanced: false,
      builder: (_) => SfSparkLineChart(data: [for (final m in avgMag) m.value], color: AppColors.primary),
    ),
    ChartSpec(
      title: '15. Spark Bar — Mini conteo diario',
      description: 'SfSparkBarChart compacto.',
      advanced: false,
      builder: (_) => SfSparkBarChart(data: [for (final d in days) d.value.toDouble()], color: AppColors.magMedHigh),
    ),
    ChartSpec(
      title: '16. Spark Area — Mini tendencia de profundidad',
      description: 'SfSparkAreaChart compacto.',
      advanced: false,
      builder: (_) => SfSparkAreaChart(data: [for (final d in data.avgDepthByDay) d.value], color: AppColors.magLow),
    ),
    ChartSpec(
      title: '17. Spark Win/Loss — Cambios diarios (ficticio)',
      description: 'SfSparkWinLossChart: sube/baja respecto al día anterior.',
      advanced: false,
      builder: (_) => SfSparkWinLossChart(data: [for (final w in waterfall) w.value]),
    ),
    ChartSpec(
      title: '18. Columnas con etiquetas de datos',
      description: 'dataLabelSettings visible sobre cada columna.',
      advanced: false,
      builder: (_) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        series: [
          ColumnSeries<_DayValue, String>(
            dataSource: countSeries,
            xValueMapper: (d, _) => d.day,
            yValueMapper: (d, _) => d.value,
            color: AppColors.primary,
            dataLabelSettings: const DataLabelSettings(isVisible: true),
          ),
        ],
      ),
    ),
    ChartSpec(
      title: '19. Línea con marcadores',
      description: 'markerSettings visibles en cada punto.',
      advanced: false,
      builder: (_) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        series: [
          LineSeries<_DayValue, String>(
            dataSource: magSeries,
            xValueMapper: (d, _) => d.day,
            yValueMapper: (d, _) => d.value,
            color: AppColors.magMedHigh,
            markerSettings: const MarkerSettings(isVisible: true),
          ),
        ],
      ),
    ),
    ChartSpec(
      title: '20. Dona con tooltip habilitado',
      description: 'tooltipBehavior muestra el valor exacto al tocar.',
      advanced: false,
      builder: (_) => SfCircularChart(
        tooltipBehavior: TooltipBehavior(enable: true),
        series: [
          DoughnutSeries<_NamedValue, String>(dataSource: distSeries, xValueMapper: (d, _) => d.name, yValueMapper: (d, _) => d.value, enableTooltip: true),
        ],
      ),
    ),
  ];

  final advancedList = <ChartSpec>[
    ChartSpec(
      title: '21. Columnas apiladas por rango de magnitud',
      description: 'StackedColumnSeries: 4 series (una por rango) apiladas por día.',
      advanced: true,
      builder: (_) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        series: [
          StackedColumnSeries<_DayValue, String>(dataSource: countSeries, xValueMapper: (d, _) => d.day, yValueMapper: (d, _) => d.value * 0.5, color: AppColors.magLow, name: '<3.0'),
          StackedColumnSeries<_DayValue, String>(dataSource: countSeries, xValueMapper: (d, _) => d.day, yValueMapper: (d, _) => d.value * 0.3, color: AppColors.magMed, name: '3.0-3.9'),
          StackedColumnSeries<_DayValue, String>(dataSource: countSeries, xValueMapper: (d, _) => d.day, yValueMapper: (d, _) => d.value * 0.15, color: AppColors.magMedHigh, name: '4.0-5.9'),
          StackedColumnSeries<_DayValue, String>(dataSource: countSeries, xValueMapper: (d, _) => d.day, yValueMapper: (d, _) => d.value * 0.05, color: AppColors.magHigh, name: '>=6.0'),
        ],
      ),
    ),
    ChartSpec(
      title: '22. Columnas 100% apiladas',
      description: 'StackedColumn100Series: proporciones normalizadas a 100%.',
      advanced: true,
      builder: (_) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        series: [
          StackedColumn100Series<_DayValue, String>(dataSource: countSeries, xValueMapper: (d, _) => d.day, yValueMapper: (d, _) => d.value * 0.5, color: AppColors.magLow),
          StackedColumn100Series<_DayValue, String>(dataSource: countSeries, xValueMapper: (d, _) => d.day, yValueMapper: (d, _) => d.value * 0.3, color: AppColors.magMed),
          StackedColumn100Series<_DayValue, String>(dataSource: countSeries, xValueMapper: (d, _) => d.day, yValueMapper: (d, _) => d.value * 0.2, color: AppColors.magHigh),
        ],
      ),
    ),
    ChartSpec(
      title: '23. Cascada (Waterfall) — Cambio diario de actividad',
      description: 'WaterfallSeries muestra incrementos/decrementos día a día.',
      advanced: true,
      builder: (_) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        series: [
          WaterfallSeries<MapEntry<String, double>, String>(
            dataSource: waterfall,
            xValueMapper: (d, _) => d.key,
            yValueMapper: (d, _) => d.value,
            intermediateSumPredicate: (d, _) => false,
            totalSumPredicate: (d, _) => false,
          ),
        ],
      ),
    ),
    ChartSpec(
      title: '24. Velas (Candle) — Magnitud diaria en formato OHLC',
      description: 'CandleSeries: apertura/máximo/mínimo/cierre de la magnitud por día.',
      advanced: true,
      builder: (_) => SfCartesianChart(
        primaryXAxis: const DateTimeAxis(),
        series: [
          CandleSeries<dynamic, DateTime>(
            dataSource: ohlc,
            xValueMapper: (d, _) => d.date,
            lowValueMapper: (d, _) => d.low,
            highValueMapper: (d, _) => d.high,
            openValueMapper: (d, _) => d.open,
            closeValueMapper: (d, _) => d.close,
          ),
        ],
      ),
    ),
    ChartSpec(
      title: '25. Hilo — Rango alto/bajo de magnitud',
      description: 'HiloSeries: variante simplificada sin cuerpo de vela.',
      advanced: true,
      builder: (_) => SfCartesianChart(
        primaryXAxis: const DateTimeAxis(),
        series: [
          HiloSeries<dynamic, DateTime>(
            dataSource: ohlc,
            xValueMapper: (d, _) => d.date,
            lowValueMapper: (d, _) => d.low,
            highValueMapper: (d, _) => d.high,
          ),
        ],
      ),
    ),
    ChartSpec(
      title: '26. Caja y bigotes — Profundidad por rango de magnitud',
      description: 'BoxAndWhiskerSeries: dispersión de profundidad en cada rango.',
      advanced: true,
      builder: (_) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        series: [
          BoxAndWhiskerSeries<dynamic, String>(
            dataSource: boxWhisker,
            xValueMapper: (d, _) => d.label,
            // BoxAndWhiskerSeries calcula mín/máx/cuartiles/mediana a partir
            // de una lista de valores "crudos" (no acepta cada estadístico
            // por separado). Le pasamos los 5 valores resumen como si fueran
            // la muestra, para que el boxplot recree una forma equivalente.
            yValueMapper: (d, _) => [d.min, d.q1, d.median, d.q3, d.max],
          ),
        ],
      ),
    ),
    ChartSpec(
      title: '27. Combinación — Columnas + Línea',
      description: 'Un ColumnSeries y un LineSeries en el mismo SfCartesianChart.',
      advanced: true,
      builder: (_) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        series: [
          columnSeries(AppColors.primary.withValues(alpha: 0.5)),
          LineSeries<_DayValue, String>(dataSource: magSeries, xValueMapper: (d, _) => d.day, yValueMapper: (d, _) => d.value * 5, color: AppColors.magHigh, width: 3),
        ],
      ),
    ),
    ChartSpec(
      title: '28. Doble eje Y — Conteo vs Magnitud',
      description: 'primaryYAxis y un axisName secundario con escalas independientes.',
      advanced: true,
      builder: (_) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        primaryYAxis: const NumericAxis(name: 'conteo'),
        axes: const [NumericAxis(name: 'magnitud', opposedPosition: true)],
        series: [
          ColumnSeries<_DayValue, String>(dataSource: countSeries, xValueMapper: (d, _) => d.day, yValueMapper: (d, _) => d.value, yAxisName: 'conteo', color: AppColors.primary.withValues(alpha: 0.6)),
          LineSeries<_DayValue, String>(dataSource: magSeries, xValueMapper: (d, _) => d.day, yValueMapper: (d, _) => d.value, yAxisName: 'magnitud', color: AppColors.magHigh, width: 3),
        ],
      ),
    ),
    ChartSpec(
      title: '29. Zoom y desplazamiento (pinch/pan)',
      description: 'ZoomPanBehavior habilita zoom táctil y arrastre sobre la serie.',
      advanced: true,
      builder: (_) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        zoomPanBehavior: ZoomPanBehavior(enablePinching: true, enablePanning: true, enableDoubleTapZooming: true),
        series: [columnSeries(AppColors.magMedHigh)],
      ),
    ),
    ChartSpec(
      title: '30. Crosshair y Trackball interactivos',
      description: 'Al arrastrar el dedo, muestra una línea guía y el valor exacto.',
      advanced: true,
      builder: (_) => SfCartesianChart(
        primaryXAxis: const CategoryAxis(),
        crosshairBehavior: CrosshairBehavior(enable: true),
        trackballBehavior: TrackballBehavior(enable: true),
        series: [
          LineSeries<_DayValue, String>(dataSource: magSeries, xValueMapper: (d, _) => d.day, yValueMapper: (d, _) => d.value, color: AppColors.primary),
        ],
      ),
    ),
    ChartSpec(
      title: '31. Barras radiales múltiples — Comparación de regiones',
      description: 'RadialBarSeries con más de 2 categorías (top 4 regiones).',
      advanced: true,
      builder: (_) => SfCircularChart(
        legend: const Legend(isVisible: true),
        series: [
          RadialBarSeries<_NamedValue, String>(
            dataSource: regionSeries.take(4).toList(),
            xValueMapper: (d, _) => d.name,
            yValueMapper: (d, _) => d.value,
            maximumValue: (regionSeries.isNotEmpty ? regionSeries.first.value : 30) + 5,
          ),
        ],
      ),
    ),
    ChartSpec(
      title: '32. Dona con explode animado al tocar',
      description: 'explode + explodeAll: la sección tocada se separa del resto.',
      advanced: true,
      builder: (_) => SfCircularChart(
        series: [
          DoughnutSeries<_NamedValue, String>(
            dataSource: distSeries,
            xValueMapper: (d, _) => d.name,
            yValueMapper: (d, _) => d.value,
            explode: true,
            explodeIndex: 0,
            animationDuration: 900,
          ),
        ],
      ),
    ),
  ];

  return [...basics, ...advancedList];
}