import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import 'chart_sample_data.dart';
import 'chart_spec.dart';

/// Genera los 32 gráficos (20 básicos + 12 avanzados) construidos con
/// la librería `fl_chart`.
List<ChartSpec> buildFlChartGallery(ChartSampleData data) {
  final days = data.countByDay;
  final avgMag = data.avgMagnitudeByDay;
  final avgDepth = data.avgDepthByDay;
  final dist = data.magnitudeDistribution;
  final totalDist = dist.values.fold<int>(0, (a, b) => a + b);
  final scatter = data.depthVsMagnitudeScatter;
  final regions = data.topRegions(5);
  final radar = data.radarByRegion(regions.map((e) => e.key).take(2).toList());

  List<BarChartGroupData> simpleBars(Color color, {bool rounded = false}) => [
        for (int i = 0; i < days.length; i++)
          BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: days[i].value.toDouble(),
              color: color,
              width: 14,
              borderRadius: rounded ? BorderRadius.circular(6) : BorderRadius.zero,
            ),
          ]),
      ];

  Widget dayAxisBar(List<BarChartGroupData> groups, {Color? gridColor}) {
    return BarChart(BarChartData(
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, m) {
              final idx = v.toInt();
              if (idx < 0 || idx >= days.length) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(DateFormatter.shortDay(days[idx].key), style: const TextStyle(fontSize: 9)),
              );
            },
          ),
        ),
      ),
      barGroups: groups,
    ));
  }

  LineChartData lineData(List<LineChartBarData> bars, {bool showGrid = false}) {
    return LineChartData(
      gridData: FlGridData(show: showGrid),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, m) {
              final idx = v.toInt();
              if (idx < 0 || idx >= avgMag.length) return const SizedBox.shrink();
              return Text(DateFormatter.shortDay(avgMag[idx].key), style: const TextStyle(fontSize: 9));
            },
          ),
        ),
      ),
      lineBarsData: bars,
    );
  }

  List<FlSpot> spotsFrom(List<MapEntry<dynamic, double>> series) =>
      [for (int i = 0; i < series.length; i++) FlSpot(i.toDouble(), series[i].value)];

  final magnitudeSpots = spotsFrom(avgMag);
  final depthSpots = spotsFrom(avgDepth);

  final basics = <ChartSpec>[
    ChartSpec(
      title: '1. Barras — Sismos por día',
      description: 'BarChart simple: conteo diario de sismos.',
      advanced: false,
      builder: (_) => dayAxisBar(simpleBars(AppColors.primary)),
    ),
    ChartSpec(
      title: '2. Barras con bordes redondeados y color cálido',
      description: 'Mismo dataset, estilo visual distinto (cornerRadius).',
      advanced: false,
      builder: (_) => dayAxisBar(simpleBars(AppColors.magMedHigh, rounded: true)),
    ),
    ChartSpec(
      title: '3. Barras agrupadas por día/noche',
      description: 'BarChartGroupData con 2 barras por grupo (simulado).',
      advanced: false,
      builder: (_) => BarChart(BarChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        barGroups: [
          for (int i = 0; i < days.length; i++)
            BarChartGroupData(x: i, barRods: [
              BarChartRodData(toY: (days[i].value * 0.6), color: AppColors.primary, width: 7),
              BarChartRodData(toY: (days[i].value * 0.4), color: AppColors.magMed, width: 7),
            ]),
        ],
      )),
    ),
    ChartSpec(
      title: '4. Barras apiladas por rango de magnitud',
      description: 'Cada barra suma los 4 rangos de magnitud en un solo día representativo.',
      advanced: false,
      builder: (_) => BarChart(BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(toY: totalDist.toDouble(), rodStackItems: [
              BarChartRodStackItem(0, (dist['< 3.0'] ?? 0).toDouble(), AppColors.magLow),
              BarChartRodStackItem((dist['< 3.0'] ?? 0).toDouble(),
                  (dist['< 3.0'] ?? 0) + (dist['3.0 - 3.9'] ?? 0) + .0, AppColors.magMed),
              BarChartRodStackItem(
                  (dist['< 3.0'] ?? 0) + (dist['3.0 - 3.9'] ?? 0) + .0,
                  (dist['< 3.0'] ?? 0) + (dist['3.0 - 3.9'] ?? 0) + (dist['4.0 - 5.9'] ?? 0) + .0,
                  AppColors.magMedHigh),
              BarChartRodStackItem(
                  (dist['< 3.0'] ?? 0) + (dist['3.0 - 3.9'] ?? 0) + (dist['4.0 - 5.9'] ?? 0) + .0,
                  totalDist.toDouble(),
                  AppColors.magHigh),
            ], width: 40),
          ]),
        ],
      )),
    ),
    ChartSpec(
      title: '5. Barras horizontales (top regiones)',
      description: 'BarChart rotado con RotatedBox para simular orientación horizontal.',
      advanced: false,
      builder: (_) => RotatedBox(
        quarterTurns: 3,
        child: BarChart(BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (int i = 0; i < regions.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: regions[i].value.toDouble(), color: AppColors.primary, width: 16),
              ]),
          ],
        )),
      ),
    ),
    ChartSpec(
      title: '6. Línea — Magnitud promedio por día',
      description: 'LineChart simple con una sola serie.',
      advanced: false,
      builder: (_) => LineChart(lineData([
        LineChartBarData(spots: magnitudeSpots, color: AppColors.primary, barWidth: 3, dotData: const FlDotData(show: false)),
      ])),
    ),
    ChartSpec(
      title: '7. Línea con puntos visibles',
      description: 'dotData habilitado para resaltar cada valor diario.',
      advanced: false,
      builder: (_) => LineChart(lineData([
        LineChartBarData(spots: magnitudeSpots, color: AppColors.magMedHigh, barWidth: 2, dotData: const FlDotData(show: true)),
      ])),
    ),
    ChartSpec(
      title: '8. Línea curva suave (isCurved)',
      description: 'Interpolación suavizada entre puntos.',
      advanced: false,
      builder: (_) => LineChart(lineData([
        LineChartBarData(spots: magnitudeSpots, isCurved: true, color: AppColors.magLow, barWidth: 3, dotData: const FlDotData(show: false)),
      ])),
    ),
    ChartSpec(
      title: '9. Línea con área rellena',
      description: 'belowBarData pinta el área bajo la curva.',
      advanced: false,
      builder: (_) => LineChart(lineData([
        LineChartBarData(
          spots: magnitudeSpots,
          isCurved: true,
          color: AppColors.primary,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.2)),
        ),
      ])),
    ),
    ChartSpec(
      title: '10. Multilínea — Magnitud vs Profundidad (normalizada)',
      description: 'Dos LineChartBarData en el mismo gráfico.',
      advanced: false,
      builder: (_) => LineChart(lineData([
        LineChartBarData(spots: magnitudeSpots, color: AppColors.primary, barWidth: 2, dotData: const FlDotData(show: false)),
        LineChartBarData(
          spots: [for (int i = 0; i < depthSpots.length; i++) FlSpot(i.toDouble(), depthSpots[i].y / 20)],
          color: AppColors.magMedHigh,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
      ])),
    ),
    ChartSpec(
      title: '11. Línea punteada (dashArray)',
      description: 'Estilo de línea discontinua.',
      advanced: false,
      builder: (_) => LineChart(lineData([
        LineChartBarData(spots: magnitudeSpots, color: AppColors.textSecondary, barWidth: 2, dashArray: [6, 4], dotData: const FlDotData(show: false)),
      ])),
    ),
    ChartSpec(
      title: '12. Circular — Distribución por magnitud',
      description: 'PieChart clásico con 4 secciones.',
      advanced: false,
      builder: (_) => PieChart(PieChartData(sections: [
        PieChartSectionData(value: (dist['>= 6.0'] ?? 0).toDouble(), color: AppColors.magHigh, title: '≥6.0'),
        PieChartSectionData(value: (dist['4.0 - 5.9'] ?? 0).toDouble(), color: AppColors.magMedHigh, title: '4-5.9'),
        PieChartSectionData(value: (dist['3.0 - 3.9'] ?? 0).toDouble(), color: AppColors.magMed, title: '3-3.9'),
        PieChartSectionData(value: (dist['< 3.0'] ?? 0).toDouble(), color: AppColors.magLow, title: '<3.0'),
      ])),
    ),
    ChartSpec(
      title: '13. Dona (centerSpaceRadius)',
      description: 'Mismo dataset en formato dona.',
      advanced: false,
      builder: (_) => PieChart(PieChartData(centerSpaceRadius: 40, sections: [
        PieChartSectionData(value: (dist['>= 6.0'] ?? 0).toDouble(), color: AppColors.magHigh, showTitle: false),
        PieChartSectionData(value: (dist['4.0 - 5.9'] ?? 0).toDouble(), color: AppColors.magMedHigh, showTitle: false),
        PieChartSectionData(value: (dist['3.0 - 3.9'] ?? 0).toDouble(), color: AppColors.magMed, showTitle: false),
        PieChartSectionData(value: (dist['< 3.0'] ?? 0).toDouble(), color: AppColors.magLow, showTitle: false),
      ])),
    ),
    ChartSpec(
      title: '14. Circular con etiquetas de porcentaje',
      description: 'title muestra el % de cada sección.',
      advanced: false,
      builder: (_) => PieChart(PieChartData(sections: [
        for (final e in dist.entries)
          PieChartSectionData(
            value: e.value.toDouble(),
            color: AppColors.colorForMagnitude(e.key.startsWith('>=') ? 6.5 : e.key.startsWith('4') ? 4.5 : e.key.startsWith('3') ? 3.5 : 1.0),
            title: totalDist == 0 ? '0%' : '${(e.value / totalDist * 100).toStringAsFixed(0)}%',
            titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
          ),
      ])),
    ),
    ChartSpec(
      title: '15. Circular con sección resaltada',
      description: 'Una sección con radio mayor simula estar "explotada".',
      advanced: false,
      builder: (_) => PieChart(PieChartData(sections: [
        PieChartSectionData(value: (dist['>= 6.0'] ?? 0).toDouble(), color: AppColors.magHigh, radius: 70, title: ''),
        PieChartSectionData(value: (dist['4.0 - 5.9'] ?? 0).toDouble(), color: AppColors.magMedHigh, radius: 55, title: ''),
        PieChartSectionData(value: (dist['3.0 - 3.9'] ?? 0).toDouble(), color: AppColors.magMed, radius: 55, title: ''),
        PieChartSectionData(value: (dist['< 3.0'] ?? 0).toDouble(), color: AppColors.magLow, radius: 55, title: ''),
      ])),
    ),
    ChartSpec(
      title: '16. Dispersión — Profundidad vs Magnitud',
      description: 'ScatterChart con un punto por sismo.',
      advanced: false,
      builder: (_) => ScatterChart(ScatterChartData(
        scatterSpots: [for (final p in scatter) ScatterSpot(p.x, p.y, dotPainter: FlDotCirclePainter(color: AppColors.primary, radius: 3))],
      )),
    ),
    ChartSpec(
      title: '17. Dispersión coloreada por rango de magnitud',
      description: 'Color del punto según severidad.',
      advanced: false,
      builder: (_) => ScatterChart(ScatterChartData(
        scatterSpots: [
          for (final p in scatter)
            ScatterSpot(p.x, p.y, dotPainter: FlDotCirclePainter(color: AppColors.colorForMagnitude(p.x), radius: 4))
        ],
      )),
    ),
    ChartSpec(
      title: '18. Radar — Comparación entre 2 regiones',
      description: 'RadarChart con 2 datasets (5 métricas normalizadas).',
      advanced: false,
      builder: (_) => RadarChart(RadarChartData(
        radarShape: RadarShape.polygon,
        dataSets: [
          for (final entry in radar.entries)
            RadarDataSet(
              fillColor: (radar.keys.toList().indexOf(entry.key) == 0 ? AppColors.primary : AppColors.magMedHigh).withValues(alpha: 0.3),
              borderColor: radar.keys.toList().indexOf(entry.key) == 0 ? AppColors.primary : AppColors.magMedHigh,
              entryRadius: 2,
              dataEntries: [for (final v in entry.value) RadarEntry(value: v)],
            ),
        ],
      )),
    ),
    ChartSpec(
      title: '19. Radar de una sola región',
      description: 'Un único RadarDataSet.',
      advanced: false,
      builder: (_) => RadarChart(RadarChartData(
        dataSets: [
          RadarDataSet(
            fillColor: AppColors.primary.withValues(alpha: 0.35),
            borderColor: AppColors.primary,
            dataEntries: [
              for (final v in
              (radar.values.isNotEmpty
                  ? radar.values.first
                  : [50.0, 50.0, 50.0, 50.0, 50.0]))
                RadarEntry(value: v.toDouble()),
            ],
          ),
        ],
      )),
    ),
    ChartSpec(
      title: '20. Mini línea tipo "sparkline"',
      description: 'LineChart sin ejes, pensado para tarjetas compactas.',
      advanced: false,
      builder: (_) => LineChart(LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        lineBarsData: [
          LineChartBarData(spots: magnitudeSpots, isCurved: true, color: AppColors.magLow, barWidth: 2, dotData: const FlDotData(show: false)),
        ],
      )),
    ),
  ];

  final advancedList = <ChartSpec>[
    ChartSpec(
      title: '21. Barras 100% apiladas',
      description: 'Cada rango de magnitud como proporción del total (0-100%).',
      advanced: true,
      builder: (_) {
        double acc = 0;
        final items = <BarChartRodStackItem>[];
        for (final e in dist.entries) {
          final pct = totalDist == 0 ? 0.0 : e.value / totalDist * 100;
          items.add(BarChartRodStackItem(acc, acc + pct,
              AppColors.colorForMagnitude(e.key.startsWith('>=') ? 6.5 : e.key.startsWith('4') ? 4.5 : e.key.startsWith('3') ? 3.5 : 1.0)));
          acc += pct;
        }
        return BarChart(BarChartData(
          maxY: 100,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 100, rodStackItems: items, width: 50)])],
        ));
      },
    ),
    ChartSpec(
      title: '22. Combinado: barras + línea de umbral',
      description: 'Un BarChart superpuesto a un LineChart (Stack) marcando un umbral.',
      advanced: true,
      builder: (_) => Stack(children: [
        dayAxisBar(simpleBars(AppColors.primary.withValues(alpha: 0.6))),
        LineChart(LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: [for (int i = 0; i < days.length; i++) FlSpot(i.toDouble(), 15)],
              color: AppColors.magHigh,
              barWidth: 2,
              dashArray: [4, 4],
              dotData: const FlDotData(show: false),
            ),
          ],
        )),
      ]),
    ),
    ChartSpec(
      title: '23. Línea multi-serie con doble escala simulada',
      description: 'Magnitud y profundidad normalizadas para compararse en un solo eje.',
      advanced: true,
      builder: (_) => LineChart(lineData([
        LineChartBarData(spots: magnitudeSpots, color: AppColors.primary, barWidth: 2, dotData: const FlDotData(show: false)),
        LineChartBarData(
          spots: [for (int i = 0; i < depthSpots.length; i++) FlSpot(i.toDouble(), depthSpots[i].y / 15)],
          color: AppColors.magMed,
          barWidth: 2,
          dashArray: [3, 3],
          dotData: const FlDotData(show: false),
        ),
      ], showGrid: true)),
    ),
    ChartSpec(
      title: '24. Línea con gradiente de área y touch interactivo',
      description: 'belowBarData con degradado; lineTouchData habilitado (tooltip al tocar).',
      advanced: true,
      builder: (_) => LineChart(LineChartData(
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: const FlTitlesData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(getTooltipColor: (_) => AppColors.primaryDark),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: magnitudeSpots,
            isCurved: true,
            color: AppColors.primary,
            barWidth: 3,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.4), AppColors.primary.withValues(alpha: 0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter),
            ),
          ),
        ],
      )),
    ),
    ChartSpec(
      title: '25. Barras con interacción táctil (tooltip)',
      description: 'barTouchData muestra el valor exacto al presionar una barra.',
      advanced: true,
      builder: (_) => BarChart(BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(getTooltipColor: (_) => AppColors.primaryDark),
        ),
        barGroups: simpleBars(AppColors.primary, rounded: true),
      )),
    ),
    ChartSpec(
      title: '26. Circular con selección interactiva',
      description: 'pieTouchData resalta la sección tocada (radio dinámico).',
      advanced: true,
      builder: (context) => _InteractivePie(dist: dist),
    ),
    ChartSpec(
      title: '27. Radar multi-serie con relleno',
      description: 'Todas las regiones top superpuestas en un mismo radar.',
      advanced: true,
      builder: (_) {
        final all = data.radarByRegion(regions.map((e) => e.key).toList());
        final colors = [AppColors.primary, AppColors.magMedHigh, AppColors.magMed, AppColors.magLow, AppColors.magHigh];
        int i = 0;
        return RadarChart(RadarChartData(
          dataSets: [
            for (final entry in all.entries)
              RadarDataSet(
                fillColor: colors[i % colors.length].withValues(alpha: 0.15),
                borderColor: colors[i++ % colors.length],
                dataEntries: [for (final v in entry.value) RadarEntry(value: v)],
              ),
          ],
        ));
      },
    ),
    ChartSpec(
      title: '28. Dispersión tipo burbuja',
      description: 'Radio del punto proporcional a la magnitud (3ra variable).',
      advanced: true,
      builder: (_) => ScatterChart(ScatterChartData(
        scatterSpots: [
          for (final p in scatter)
            ScatterSpot(p.x, p.y, dotPainter: FlDotCirclePainter(color: AppColors.colorForMagnitude(p.x).withValues(alpha: 0.6), radius: p.size))
        ],
      )),
    ),
    ChartSpec(
      title: '29. Barras horizontales con leyenda por color',
      description: 'Top de regiones, orientación horizontal con paleta gradual.',
      advanced: true,
      builder: (_) => RotatedBox(
        quarterTurns: 3,
        child: BarChart(BarChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: [
            for (int i = 0; i < regions.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: regions[i].value.toDouble(),
                  width: 16,
                  gradient: const LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.magMedHigh,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ]),
          ],
        )),
      ),
    ),
    ChartSpec(
      title: '30. Área apilada (2 series)',
      description: 'Dos belowBarData superpuestas simulando un area chart apilado.',
      advanced: true,
      builder: (_) => LineChart(LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: magnitudeSpots,
            color: Colors.transparent,
            barWidth: 0,
            belowBarData: BarAreaData(show: true, color: AppColors.magMed.withValues(alpha: 0.5)),
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: [for (int i = 0; i < magnitudeSpots.length; i++) FlSpot(i.toDouble(), magnitudeSpots[i].y * 0.5)],
            color: Colors.transparent,
            barWidth: 0,
            belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.5)),
            dotData: const FlDotData(show: false),
          ),
        ],
      )),
    ),
    ChartSpec(
      title: '31. Combo real: Barras + Línea en el mismo lienzo',
      description: 'Conteo diario (barras) y magnitud promedio (línea) superpuestos.',
      advanced: true,
      builder: (_) => Stack(children: [
        dayAxisBar(simpleBars(AppColors.primary.withValues(alpha: 0.35))),
        LineChart(LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          minY: 0,
          maxY: 9,
          lineBarsData: [
            LineChartBarData(
              spots: [for (int i = 0; i < magnitudeSpots.length; i++) FlSpot(i.toDouble(), magnitudeSpots[i].y)],
              color: AppColors.magHigh,
              barWidth: 3,
              dotData: const FlDotData(show: true),
            ),
          ],
        )),
      ]),
    ),
    ChartSpec(
      title: '32. Dona con texto resumen central',
      description: 'PieChart + Text superpuesto en el centro (total de sismos).',
      advanced: true,
      builder: (_) => Stack(alignment: Alignment.center, children: [
        PieChart(PieChartData(centerSpaceRadius: 50, sections: [
          for (final e in dist.entries)
            PieChartSectionData(
              value: e.value.toDouble(),
              showTitle: false,
              color: AppColors.colorForMagnitude(e.key.startsWith('>=') ? 6.5 : e.key.startsWith('4') ? 4.5 : e.key.startsWith('3') ? 3.5 : 1.0),
            ),
        ])),
        Column(mainAxisSize: MainAxisSize.min, children: [
          Text('$totalDist', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const Text('sismos', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        ]),
      ]),
    ),
  ];

  return [...basics, ...advancedList];
}

class _InteractivePie extends StatefulWidget {
  final Map<String, int> dist;
  const _InteractivePie({required this.dist});

  @override
  State<_InteractivePie> createState() => _InteractivePieState();
}

class _InteractivePieState extends State<_InteractivePie> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final entries = widget.dist.entries.toList();
    return PieChart(PieChartData(
      pieTouchData: PieTouchData(
        touchCallback: (event, response) {
          setState(() {
            touchedIndex = response?.touchedSection?.touchedSectionIndex ?? -1;
          });
        },
      ),
      sections: [
        for (int i = 0; i < entries.length; i++)
          PieChartSectionData(
            value: entries[i].value.toDouble(),
            color: AppColors.colorForMagnitude(
                entries[i].key.startsWith('>=') ? 6.5 : entries[i].key.startsWith('4') ? 4.5 : entries[i].key.startsWith('3') ? 3.5 : 1.0),
            radius: touchedIndex == i ? 65 : 55,
            title: '${entries[i].value}',
            titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
          ),
      ],
    ));
  }
}
