import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/earthquake_model.dart';
import '../../providers/earthquake_provider.dart';
import '../../widgets/earthquake_list_tile.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../detail/earthquake_detail_screen.dart';

class EarthquakeListScreen extends StatefulWidget {
  const EarthquakeListScreen({super.key});

  @override
  State<EarthquakeListScreen> createState() => _EarthquakeListScreenState();
}

class _EarthquakeListScreenState extends State<EarthquakeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  bool _searching = false;

  List<Earthquake> _applySearch(List<Earthquake> source) {
    if (_query.trim().isEmpty) return source;
    final q = _query.toLowerCase();
    return source.where((e) => e.place.toLowerCase().contains(q)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Buscar por ubicación...',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _query = v),
              )
            : const Text('Lista de terremotos'),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () => setState(() {
              _searching = !_searching;
              if (!_searching) {
                _query = '';
                _searchController.clear();
              }
            }),
          ),
        ],
      ),
      body: Consumer<EarthquakeProvider>(
        builder: (context, provider, _) {
          if (provider.status == ViewStatus.loading &&
              provider.allEarthquakes.isEmpty) {
            return const LoadingWidget();
          }
          if (provider.status == ViewStatus.error &&
              provider.allEarthquakes.isEmpty) {
            return ErrorStateWidget(
              message: provider.errorMessage,
              onRetry: provider.loadEarthquakes,
            );
          }

          final results = _applySearch(provider.filteredEarthquakes);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChipItem(
                        label: 'Hoy',
                        selected: provider.activeFilter == QuickFilter.today,
                        onTap: () => provider.setFilter(QuickFilter.today),
                      ),
                      const SizedBox(width: 8),
                      _FilterChipItem(
                        label: 'Magnitud 3.0+',
                        selected: provider.activeFilter == QuickFilter.magnitude30Plus,
                        onTap: () => provider.setFilter(QuickFilter.magnitude30Plus),
                      ),
                      const SizedBox(width: 8),
                      _FilterChipItem(
                        label: 'Todo el mundo',
                        selected: provider.activeFilter == QuickFilter.worldwide,
                        onTap: () => provider.setFilter(QuickFilter.worldwide),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: results.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay resultados para tu búsqueda o filtros.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: provider.refresh,
                        child: ListView.builder(
                          itemCount: results.length,
                          itemBuilder: (context, i) => EarthquakeListTile(
                            earthquake: results[i],
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EarthquakeDetailScreen(earthquake: results[i]),
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFilterSheet(context),
        child: const Icon(Icons.filter_alt),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Filtros avanzados', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              SizedBox(height: 12),
              Text(
                'Ajusta la magnitud mínima y región por defecto desde la pantalla de Ajustes.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChipItem({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(color: selected ? Colors.white : AppColors.textPrimary),
    );
  }
}
