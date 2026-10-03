import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';
import '../../data/models/earthquake_model.dart';
import '../../data/repositories/earthquake_repository.dart';

enum ViewStatus { initial, loading, success, error }

/// Filtros disponibles en la pantalla "Listas" (chips del mockup:
/// Hoy | Magnitud 3.0+ | Todo el mundo).
enum QuickFilter { today, magnitude30Plus, worldwide }

/// Provider (ChangeNotifier) que orquesta el estado de sismos consumido
/// por Home, Mapa, Listas, Detalle y Estadísticas.
class EarthquakeProvider extends ChangeNotifier {
  final EarthquakeRepository _repository;

  EarthquakeProvider({EarthquakeRepository? repository})
      : _repository = repository ?? EarthquakeRepository();

  ViewStatus _status = ViewStatus.initial;
  String _errorMessage = '';
  List<Earthquake> _earthquakes = [];
  QuickFilter _activeFilter = QuickFilter.today;
  DateTime? _lastUpdated;

  ViewStatus get status => _status;
  String get errorMessage => _errorMessage;
  QuickFilter get activeFilter => _activeFilter;
  DateTime? get lastUpdated => _lastUpdated;
  bool get isLoading => _status == ViewStatus.loading;

  /// Lista completa sin filtrar (para mapa y estadísticas).
  List<Earthquake> get allEarthquakes => List.unmodifiable(_earthquakes);

  /// Lista aplicando el filtro rápido activo, ordenada por fecha desc.
  List<Earthquake> get filteredEarthquakes {
    final list = switch (_activeFilter) {
      QuickFilter.today => _earthquakes,
      QuickFilter.magnitude30Plus =>
        _earthquakes.where((e) => e.magnitude >= 3.0).toList(),
      QuickFilter.worldwide => _earthquakes,
    };
    final sorted = [...list]..sort((a, b) => b.time.compareTo(a.time));
    return sorted;
  }

  List<Earthquake> get recentTop5 => filteredEarthquakes.take(5).toList();

  // ----- Métricas para las tarjetas de Inicio y Estadísticas -----

  int get totalCount => _earthquakes.length;

  double get maxMagnitude {
    if (_earthquakes.isEmpty) return 0;
    return _earthquakes.map((e) => e.magnitude).reduce((a, b) => a > b ? a : b);
  }

  int get affectedRegionsCount {
    return _earthquakes.map((e) => e.approximateCountryOrRegion).toSet().length;
  }

  double get averageDepthKm {
    final withDepth = _earthquakes.where((e) => e.depthKm != null).toList();
    if (withDepth.isEmpty) return 0;
    final sum = withDepth.fold<double>(0, (acc, e) => acc + (e.depthKm ?? 0));
    return sum / withDepth.length;
  }

  /// Distribución por rango de magnitud, usada en el donut chart.
  Map<String, int> get magnitudeDistribution {
    final buckets = {'>= 6.0': 0, '4.0 - 5.9': 0, '3.0 - 3.9': 0, '< 3.0': 0};
    for (final e in _earthquakes) {
      if (e.magnitude >= 6.0) {
        buckets['>= 6.0'] = buckets['>= 6.0']! + 1;
      } else if (e.magnitude >= 4.0) {
        buckets['4.0 - 5.9'] = buckets['4.0 - 5.9']! + 1;
      } else if (e.magnitude >= 3.0) {
        buckets['3.0 - 3.9'] = buckets['3.0 - 3.9']! + 1;
      } else {
        buckets['< 3.0'] = buckets['< 3.0']! + 1;
      }
    }
    return buckets;
  }

  /// Conteo de sismos por día, usado en el bar chart de Estadísticas.
  Map<DateTime, int> get earthquakesPerDay {
    final Map<DateTime, int> map = {};
    for (final e in _earthquakes) {
      final day = DateTime(e.time.year, e.time.month, e.time.day);
      map[day] = (map[day] ?? 0) + 1;
    }
    final sortedKeys = map.keys.toList()..sort();
    return {for (final k in sortedKeys) k: map[k]!};
  }

  void setFilter(QuickFilter filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  Future<void> loadEarthquakes({String period = ApiConstants.periodWeek}) async {
    _status = ViewStatus.loading;
    notifyListeners();

    try {
      final result = await _repository.getEarthquakes(
        magnitude: ApiConstants.allMagnitudes,
        period: period,
      );
      _earthquakes = result;
      _lastUpdated = DateTime.now();
      _status = ViewStatus.success;
    } catch (e) {
      _errorMessage = e.toString();
      _status = ViewStatus.error;
    }
    notifyListeners();
  }

  Future<void> refresh() => loadEarthquakes();

  Earthquake? byId(String id) => _repository.findById(_earthquakes, id);
}
