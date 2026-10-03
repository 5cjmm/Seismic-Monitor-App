import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/earthquake_provider.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_widget.dart';
import 'charts_gallery/charts_gallery_screen.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_today), onPressed: () {}),
        ],
      ),
      body: Consumer<EarthquakeProvider>(
        builder: (context, provider, _) {
          if (provider.status == ViewStatus.loading &&
              provider.allEarthquakes.isEmpty) {
            return const LoadingWidget(message: 'Calculando estadísticas...');
          }
          if (provider.status == ViewStatus.error &&
              provider.allEarthquakes.isEmpty) {
            return ErrorStateWidget(
              message: provider.errorMessage,
              onRetry: provider.loadEarthquakes,
            );
          }

          final perDay = provider.earthquakesPerDay;
          final distribution = provider.magnitudeDistribution;
          final total = distribution.values.fold<int>(0, (a, b) => a + b);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _GalleryEntryCard(onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ChartsGalleryScreen()),
              )),
              const SizedBox(height: 16),
              const Text('Últimos 7 días', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Terremotos por día', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 180,
                        child: perDay.isEmpty
                            ? const Center(child: Text('Sin datos'))
                            : BarChart(
                                BarChartData(
                                  gridData: const FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  titlesData: FlTitlesData(
                                    leftTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(
                                        sideTitles: SideTitles(showTitles: false)),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (value, meta) {
                                          final days = perDay.keys.toList();
                                          final idx = value.toInt();
                                          if (idx < 0 || idx >= days.length) {
                                            return const SizedBox.shrink();
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: Text(
                                              DateFormatter.shortDay(days[idx]),
                                              style: const TextStyle(fontSize: 10),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                  barGroups: [
                                    for (var i = 0; i < perDay.length; i++)
                                      BarChartGroupData(x: i, barRods: [
                                        BarChartRodData(
                                          toY: perDay.values.elementAt(i).toDouble(),
                                          color: AppColors.primary,
                                          width: 16,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                      ]),
                                  ],
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Distribución por magnitud', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          SizedBox(
                            width: 130,
                            height: 130,
                            child: total == 0
                                ? const Center(child: Text('Sin datos'))
                                : PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 32,
                                      sections: [
                                        _section('≥ 6.0', distribution['>= 6.0']!, total, AppColors.magHigh),
                                        _section('4.0-5.9', distribution['4.0 - 5.9']!, total, AppColors.magMedHigh),
                                        _section('3.0-3.9', distribution['3.0 - 3.9']!, total, AppColors.magMed),
                                        _section('< 3.0', distribution['< 3.0']!, total, AppColors.magLow),
                                      ],
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _legendRow('≥ 6.0', distribution['>= 6.0']!, total, AppColors.magHigh),
                                _legendRow('4.0 – 5.9', distribution['4.0 - 5.9']!, total, AppColors.magMedHigh),
                                _legendRow('3.0 – 3.9', distribution['3.0 - 3.9']!, total, AppColors.magMed),
                                _legendRow('< 3.0', distribution['< 3.0']!, total, AppColors.magLow),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Profundidad promedio', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        '${provider.averageDepthKm.toStringAsFixed(0)} km',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  PieChartSectionData _section(String label, int value, int total, Color color) {
    final pct = total == 0 ? 0 : (value / total * 100);
    return PieChartSectionData(
      value: value.toDouble(),
      color: color,
      title: '${pct.toStringAsFixed(0)}%',
      radius: 30,
      titleStyle: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
    );
  }

  Widget _legendRow(String label, int value, int total, Color color) {
    final pct = total == 0 ? 0 : (value / total * 100);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12))),
          Text('$value (${pct.toStringAsFixed(0)}%)',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Tarjeta destacada que enlaza a la Galería de Gráficos del Taller
/// (128 gráficos: 4 librerías x 20 básicos + 12 avanzados).
class _GalleryEntryCard extends StatelessWidget {
  final VoidCallback onTap;
  const _GalleryEntryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.grid_view_rounded, color: Colors.white, size: 30),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Galería de gráficos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  SizedBox(height: 2),
                  Text('material_charts · candlesticks · Syncfusion · fl_chart',
                      style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}
