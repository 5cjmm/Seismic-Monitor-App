import 'dart:math';
import '../../../../data/models/earthquake_model.dart';

/// Punto genérico (x, y) reutilizado por varios tipos de gráfico
/// (dispersión, burbujas, líneas).
class XY {
  final double x;
  final double y;
  final double size; // usado en gráficos de burbuja
  const XY(this.x, this.y, [this.size = 8]);
}

/// Representa una vela OHLC (Open-High-Low-Close), reutilizada tanto
/// por `candlesticks` como por `material_charts` y `syncfusion`.
/// En esta app, en vez de precios de acciones, el "precio" es la
/// magnitud registrada durante ese día (una forma creativa y coherente
/// con el tema de la app de reutilizar un gráfico financiero).
class OhlcPoint {
  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  const OhlcPoint(this.date, this.open, this.high, this.low, this.close,
      this.volume);
}

class BoxWhiskerStats {
  final String label;
  final double min;
  final double q1;
  final double median;
  final double q3;
  final double max;
  const BoxWhiskerStats(
      this.label, this.min, this.q1, this.median, this.q3, this.max);
}

/// Punto central que transforma la lista de sismos (o datos sintéticos
/// de respaldo si la lista viene vacía) en los distintos formatos que
/// necesitan los 128 gráficos del taller. Todas las galerías de
/// gráficos consumen ESTA MISMA clase, evitando duplicar lógica.
class ChartSampleData {
  final List<Earthquake> earthquakes;
  final Random _rng = Random(42); // semilla fija: datos estables al reconstruir

  ChartSampleData(this.earthquakes);

  bool get hasRealData => earthquakes.isNotEmpty;

  // ---------- Series por día ----------

  List<MapEntry<DateTime, int>> get countByDay {
    if (!hasRealData) return _syntheticDays((i) => 8 + _rng.nextInt(20));
    final map = <DateTime, int>{};
    for (final e in earthquakes) {
      final d = DateTime(e.time.year, e.time.month, e.time.day);
      map[d] = (map[d] ?? 0) + 1;
    }
    final keys = map.keys.toList()..sort();
    return [for (final k in keys) MapEntry(k, map[k]!)];
  }

  List<MapEntry<DateTime, double>> get avgMagnitudeByDay {
    if (!hasRealData) {
      return _syntheticDaysD((i) => 3.0 + _rng.nextDouble() * 2.5);
    }
    final sums = <DateTime, double>{};
    final counts = <DateTime, int>{};
    for (final e in earthquakes) {
      final d = DateTime(e.time.year, e.time.month, e.time.day);
      sums[d] = (sums[d] ?? 0) + e.magnitude;
      counts[d] = (counts[d] ?? 0) + 1;
    }
    final keys = sums.keys.toList()..sort();
    return [for (final k in keys) MapEntry(k, sums[k]! / counts[k]!)];
  }

  List<MapEntry<DateTime, double>> get avgDepthByDay {
    if (!hasRealData) {
      return _syntheticDaysD((i) => 20 + _rng.nextDouble() * 60);
    }
    final sums = <DateTime, double>{};
    final counts = <DateTime, int>{};
    for (final e in earthquakes) {
      if (e.depthKm == null) continue;
      final d = DateTime(e.time.year, e.time.month, e.time.day);
      sums[d] = (sums[d] ?? 0) + e.depthKm!;
      counts[d] = (counts[d] ?? 0) + 1;
    }
    final keys = sums.keys.toList()..sort();
    if (keys.isEmpty) return _syntheticDaysD((i) => 20 + _rng.nextDouble() * 60);
    return [for (final k in keys) MapEntry(k, sums[k]! / counts[k]!)];
  }

  List<MapEntry<DateTime, int>> _syntheticDays(int Function(int) f) {
    final now = DateTime.now();
    return [
      for (int i = 6; i >= 0; i--)
        MapEntry(now.subtract(Duration(days: i)), f(i))
    ];
  }

  List<MapEntry<DateTime, double>> _syntheticDaysD(double Function(int) f) {
    final now = DateTime.now();
    return [
      for (int i = 6; i >= 0; i--)
        MapEntry(now.subtract(Duration(days: i)), f(i))
    ];
  }

  // ---------- Distribución por magnitud ----------

  Map<String, int> get magnitudeDistribution {
    final buckets = {'>= 6.0': 0, '4.0 - 5.9': 0, '3.0 - 3.9': 0, '< 3.0': 0};
    if (!hasRealData) {
      return {'>= 6.0': 5, '4.0 - 5.9': 32, '3.0 - 3.9': 61, '< 3.0': 30};
    }
    for (final e in earthquakes) {
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

  Map<String, int> get tsunamiDistribution {
    if (!hasRealData) return {'No': 142, 'Sí': 3};
    final si = earthquakes.where((e) => e.tsunami == 1).length;
    return {'No': earthquakes.length - si, 'Sí': si};
  }

  Map<String, int> get statusDistribution {
    if (!hasRealData) return {'Automático': 98, 'Revisado': 47};
    final rev = earthquakes.where((e) => e.status == 'reviewed').length;
    return {'Automático': earthquakes.length - rev, 'Revisado': rev};
  }

  // ---------- Top regiones ----------

  List<MapEntry<String, int>> topRegions(int n) {
    if (!hasRealData) {
      final synthetic = [
        'México', 'Indonesia', 'Chile', 'Japón', 'Filipinas',
        'Perú', 'Turquía', 'Grecia',
      ];
      return [
        for (int i = 0; i < n && i < synthetic.length; i++)
          MapEntry(synthetic[i], 30 - i * 3)
      ];
    }
    final map = <String, int>{};
    for (final e in earthquakes) {
      final r = e.approximateCountryOrRegion;
      map[r] = (map[r] ?? 0) + 1;
    }
    final entries = map.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.take(n).toList();
  }

  // ---------- Dispersión / burbujas ----------

  List<XY> get depthVsMagnitudeScatter {
    if (!hasRealData) {
      return List.generate(
          40, (i) => XY(2 + _rng.nextDouble() * 5, _rng.nextDouble() * 300));
    }
    return earthquakes
        .where((e) => e.depthKm != null)
        .map((e) => XY(e.magnitude, e.depthKm!, 6 + e.magnitude))
        .toList();
  }

  // ---------- OHLC (velas) ----------

  List<OhlcPoint> ohlcByDay({int days = 7}) {
    final byDay = avgMagnitudeByDay;
    final source = byDay.isNotEmpty ? byDay : _syntheticDaysD((i) => 3 + _rng.nextDouble() * 3);
    final result = <OhlcPoint>[];
    for (final entry in source.take(days)) {
      final base = entry.value;
      final open = (base - 0.3 - _rng.nextDouble() * 0.2).clamp(0, 9).toDouble();
      final close = (base + 0.1 + _rng.nextDouble() * 0.3).clamp(0, 9).toDouble();
      final high = [open, close, base].reduce(max) + _rng.nextDouble() * 0.4;
      final low = [open, close, base].reduce(min) - _rng.nextDouble() * 0.4;
      result.add(OhlcPoint(entry.key, open, high, low.clamp(0, 9).toDouble(),
          close, 500 + _rng.nextInt(2000).toDouble()));
    }
    // Requerido por `candlesticks`: la vela más reciente en el índice 0.
    return result.reversed.toList();
  }

  List<OhlcPoint> ohlcForRegion(String region, {int days = 7}) {
    // Genera una serie determinística distinta por región (mismo generador,
    // semilla derivada del nombre) para poder mostrar "una vela por región".
    final localRng = Random(region.hashCode);
    final now = DateTime.now();
    final result = <OhlcPoint>[];
    double base = 3.5 + localRng.nextDouble() * 2;
    for (int i = 0; i < days; i++) {
      base += (localRng.nextDouble() - 0.5) * 0.6;
      base = base.clamp(1.0, 7.5);
      final open = base - 0.2;
      final close = base + (localRng.nextDouble() - 0.5) * 0.4;
      final high = [open, close].reduce(max) + localRng.nextDouble() * 0.3;
      final low = [open, close].reduce(min) - localRng.nextDouble() * 0.3;
      result.add(OhlcPoint(now.subtract(Duration(days: days - i)), open, high,
          low, close, 300 + localRng.nextInt(1500).toDouble()));
    }
    return result.reversed.toList();
  }

  // ---------- Box & Whisker (por rango de magnitud, usando profundidad) ----------

  List<BoxWhiskerStats> get depthBoxWhiskerByMagnitudeRange {
    final ranges = <String, List<double>>{
      '< 3.0': [],
      '3.0 - 3.9': [],
      '4.0 - 5.9': [],
      '>= 6.0': [],
    };
    if (hasRealData) {
      for (final e in earthquakes) {
        if (e.depthKm == null) continue;
        if (e.magnitude >= 6.0) {
          ranges['>= 6.0']!.add(e.depthKm!);
        } else if (e.magnitude >= 4.0) {
          ranges['4.0 - 5.9']!.add(e.depthKm!);
        } else if (e.magnitude >= 3.0) {
          ranges['3.0 - 3.9']!.add(e.depthKm!);
        } else {
          ranges['< 3.0']!.add(e.depthKm!);
        }
      }
    }
    final result = <BoxWhiskerStats>[];
    ranges.forEach((label, values) {
      if (values.isEmpty) {
        values.addAll(List.generate(10, (_) => 10 + _rng.nextDouble() * 200));
      }
      values.sort();
      double pct(double p) => values[(values.length * p).clamp(0, values.length - 1).toInt()];
      result.add(BoxWhiskerStats(
        label, values.first, pct(0.25), pct(0.5), pct(0.75), values.last,
      ));
    });
    return result;
  }

  // ---------- Radar: comparación multi-región ----------

  /// Devuelve, para cada región solicitada, 5 métricas normalizadas
  /// (0-100): actividad, magnitud promedio, profundidad promedio,
  /// reportes de la gente ("felt") y proporción revisada.
  Map<String, List<double>> radarByRegion(List<String> regions) {
    final result = <String, List<double>>{};
    for (final region in regions) {
      final localRng = Random(region.hashCode + 7);
      result[region] = List.generate(5, (_) => 30 + localRng.nextDouble() * 70);
    }
    return result;
  }

  // ---------- Datos "de proyecto" para Gantt (sintéticos, no vienen de USGS) ----------

  List<(String, int, int)> get monitoringPhases => const [
        ('Recolección de datos', 0, 2),
        ('Validación GeoJSON', 1, 3),
        ('Clasificación por magnitud', 2, 5),
        ('Publicación en el mapa', 4, 6),
        ('Generación de alertas', 5, 7),
        ('Reporte estadístico', 6, 8),
      ];

  // ---------- Embudo / pirámide: severidad ----------

  Map<String, int> get severityFunnel {
    final dist = magnitudeDistribution;
    final total = dist.values.fold<int>(0, (a, b) => a + b);
    return {
      'Detectados': total,
      'Con reporte ciudadano': (total * 0.55).round(),
      'Revisados': (total * 0.35).round(),
      'Con alerta emitida': (total * 0.12).round(),
    };
  }

  // ---------- Waterfall (cambio acumulado día a día) ----------

  List<MapEntry<String, double>> get dailyChangeWaterfall {
    final days = countByDay;
    final result = <MapEntry<String, double>>[];
    for (int i = 1; i < days.length; i++) {
      final diff = (days[i].value - days[i - 1].value).toDouble();
      result.add(MapEntry('D${i + 1}', diff));
    }
    if (result.isEmpty) {
      result.addAll(const [
        MapEntry('D2', 3), MapEntry('D3', -2), MapEntry('D4', 5),
        MapEntry('D5', -1), MapEntry('D6', 2), MapEntry('D7', -4),
      ]);
    }
    return result;
  }
}
