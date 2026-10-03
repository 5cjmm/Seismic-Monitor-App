/// Constantes de configuración para el consumo de la API pública de USGS
/// (United States Geological Survey) - Earthquake Hazards Program.
///
/// Documentación oficial: https://earthquake.usgs.gov/earthquakes/feed/v1.0/geojson.php
class ApiConstants {
  ApiConstants._();

  static const String baseUrl =
      'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary';

  /// Periodos de tiempo disponibles en el feed GeoJSON de USGS.
  static const String periodHour = 'hour';
  static const String periodDay = 'day';
  static const String periodWeek = 'week';
  static const String periodMonth = 'month';

  /// Niveles de magnitud mínima disponibles como "canales" del feed.
  static const String significant = 'significant';
  static const String mag45 = '4.5';
  static const String mag25 = '2.5';
  static const String mag10 = '1.0';
  static const String allMagnitudes = 'all';

  /// Construye la URL final del feed GeoJSON.
  /// Ejemplo: all_day.geojson, 2.5_week.geojson
  static String buildFeedUrl({
    required String magnitude,
    required String period,
  }) {
    return '$baseUrl/${magnitude}_$period.geojson';
  }

  static const Duration requestTimeout = Duration(seconds: 15);
}
