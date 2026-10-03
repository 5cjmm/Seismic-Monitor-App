import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'chart_spec.dart';

/// Tarjeta individual que envuelve un gráfico con su título y
/// descripción. Reutilizada por las 4 librerías.
class ChartCard extends StatelessWidget {
  final ChartSpec spec;
  final int index;

  const ChartCard({super.key, required this.spec, required this.index});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: spec.advanced
                        ? AppColors.magHigh.withValues(alpha: 0.15)
                        : AppColors.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$index',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: spec.advanced ? AppColors.magHigh : AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    spec.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              spec.description,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 240,
              child: Builder(builder: spec.builder),
            ),
          ],
        ),
      ),
    );
  }
}

/// Lista perezosa (ListView.builder) de todos los gráficos de una
/// categoría (básicos o avanzados) para una librería.
class ChartGallerySection extends StatelessWidget {
  final List<ChartSpec> specs;

  const ChartGallerySection({super.key, required this.specs});

  @override
  Widget build(BuildContext context) {
    if (specs.isEmpty) {
      return const Center(child: Text('Sin gráficos en esta categoría.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: specs.length,
      itemBuilder: (context, i) => ChartCard(spec: specs[i], index: i + 1),
    );
  }
}
