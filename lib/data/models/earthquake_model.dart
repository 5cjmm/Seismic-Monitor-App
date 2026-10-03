/// Modelo de dominio que representa un sismo, mapeado desde una
/// "feature" del GeoJSON entregado por la API de USGS.
///
/// Formato de referencia:
/// https://earthquake.usgs.gov/earthquake/feed/v1.0/geojson_detail.php
class Earthquake {
  final String id;
  final double magnitude;
  final String place;
  final DateTime time;
  final DateTime? updated;
  final String? magType;
  final double? depthKm;
  final double latitude;
  final double longitude;
  final String? alert;
  final String status;
  final int tsunami; // 0 = no, 1 = posible
  final int sig; // índice de significancia (0-1000)
  final String? eventType;
  final int felt; // reportes de personas ("felt")
  final String url;

  const Earthquake({
    required this.id,
    required this.magnitude,
    required this.place,
    required this.time,
    required this.latitude,
    required this.longitude,
    this.updated,
    this.magType,
    this.depthKm,
    this.alert,
    this.status = 'automatic',
    this.tsunami = 0,
    this.sig = 0,
    this.eventType,
    this.felt = 0,
    this.url = '',
  });

  factory Earthquake.fromGeoJson(Map<String, dynamic> feature) {
    final properties = feature['properties'] as Map<String, dynamic>? ?? {};
    final geometry = feature['geometry'] as Map<String, dynamic>? ?? {};
    final coordinates = (geometry['coordinates'] as List?) ?? [0, 0, 0];

    return Earthquake(
      id: feature['id']?.toString() ?? '',
      magnitude: (properties['mag'] as num?)?.toDouble() ?? 0.0,
      place: properties['place']?.toString() ?? 'Ubicación desconocida',
      time: DateTime.fromMillisecondsSinceEpoch(
        (properties['time'] as num?)?.toInt() ?? 0,
      ),
      updated: properties['updated'] != null
          ? DateTime.fromMillisecondsSinceEpoch(
              (properties['updated'] as num).toInt(),
            )
          : null,
      magType: properties['magType']?.toString(),
      depthKm: coordinates.length > 2
          ? (coordinates[2] as num?)?.toDouble()
          : null,
      longitude: (coordinates.isNotEmpty
              ? (coordinates[0] as num?)?.toDouble()
              : null) ??
          0.0,
      latitude: (coordinates.length > 1
              ? (coordinates[1] as num?)?.toDouble()
              : null) ??
          0.0,
      alert: properties['alert']?.toString(),
      status: properties['status']?.toString() ?? 'automatic',
      tsunami: (properties['tsunami'] as num?)?.toInt() ?? 0,
      sig: (properties['sig'] as num?)?.toInt() ?? 0,
      eventType: properties['type']?.toString(),
      felt: (properties['felt'] as num?)?.toInt() ?? 0,
      url: properties['url']?.toString() ?? '',
    );
  }

  /// Intenta extraer un "país/región" aproximado a partir del texto libre
  /// de `place`, que normalmente viene como "62 km al S de Acapulco, México".
  String get approximateCountryOrRegion {
    final parts = place.split(',');
    return parts.length > 1 ? parts.last.trim() : place.trim();
  }
}
