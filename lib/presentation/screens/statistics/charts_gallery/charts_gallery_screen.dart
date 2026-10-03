import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/earthquake_provider.dart';
import '../../../widgets/loading_widget.dart';
import 'candlesticks_gallery.dart';
import 'chart_gallery_widgets.dart';
import 'chart_sample_data.dart';
import 'chart_spec.dart';
import 'fl_chart_gallery.dart';
import 'material_charts_gallery.dart';
import 'syncfusion_gallery.dart';

/// Pantalla del "Taller de Gráficos en Flutter": 4 librerías x
/// (20 gráficos básicos + 12 avanzados) = 128 gráficos en total,
/// organizados en pestañas para que la navegación sea manejable.
class ChartsGalleryScreen extends StatelessWidget {
  const ChartsGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EarthquakeProvider>(
      builder: (context, provider, _) {
        if (provider.status == ViewStatus.loading && provider.allEarthquakes.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Galería de gráficos')),
            body: const LoadingWidget(message: 'Preparando datasets...'),
          );
        }

        final sample = ChartSampleData(provider.allEarthquakes);

        return DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Galería de gráficos'),
              bottom: const TabBar(
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(text: 'material_charts'),
                  Tab(text: 'candlesticks'),
                  Tab(text: 'Syncfusion'),
                  Tab(text: 'fl_chart'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _LibraryTabs(specs: buildMaterialChartsGallery(sample)),
                _LibraryTabs(specs: buildCandlesticksGallery(sample)),
                _LibraryTabs(specs: buildSyncfusionGallery(sample)),
                _LibraryTabs(specs: buildFlChartGallery(sample)),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Sub-pestañas "Básicos (20)" / "Avanzados (12)" dentro de cada librería.
class _LibraryTabs extends StatelessWidget {
  final List<ChartSpec> specs;

  const _LibraryTabs({required this.specs});

  @override
  Widget build(BuildContext context) {
    final basics = specs.where((s) => !s.advanced).toList();
    final advanced = specs.where((s) => s.advanced).toList();

    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Container(
            color: Theme.of(context).scaffoldBackgroundColor,
            child: TabBar(
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Básicos (${basics.length})'),
                Tab(text: 'Avanzados (${advanced.length})'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                ChartGallerySection(specs: basics),
                ChartGallerySection(specs: advanced),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
