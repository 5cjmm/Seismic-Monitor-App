import '../models/earthquake_model.dart';
import '../services/usgs_api_service.dart';

/// El Repository es la única puerta de entrada a los datos de sismos
/// para la capa de presentación. Hoy usa la API de USGS, pero podría
/// combinarse con una caché local (Hive/SQLite) sin tocar la UI.
class EarthquakeRepository {
  final UsgsApiService _apiService;

  EarthquakeRepository({UsgsApiService? apiService})
      : _apiService = apiService ?? UsgsApiService();

  Future<List<Earthquake>> getEarthquakes({
    required String magnitude,
    required String period,
  }) {
    return _apiService.fetchEarthquakes(magnitude: magnitude, period: period);
  }

  /// Un único sismo por id, buscado dentro de una lista ya cargada.
  /// Evita otra llamada de red cuando venimos desde la lista/mapa.
  Earthquake? findById(List<Earthquake> source, String id) {
    try {
      return source.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}
