import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/earthquake_model.dart';
import '../../widgets/magnitude_badge.dart';

class EarthquakeDetailScreen extends StatelessWidget {
  final Earthquake earthquake;

  const EarthquakeDetailScreen({super.key, required this.earthquake});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Detalle del terremoto'),
          actions: [
            IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          ],
          bottom: const TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: [
              Tab(text: 'INFORMACIÓN'),
              Tab(text: 'MAPA'),
            ],
          ),
        ),
        body: Column(
          children: [
            _HeaderSummary(earthquake: earthquake),
            Expanded(
              child: TabBarView(
                children: [
                  _InfoTab(earthquake: earthquake),
                  _MapTab(earthquake: earthquake),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSummary extends StatelessWidget {
  final Earthquake earthquake;
  const _HeaderSummary({required this.earthquake});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MagnitudeBadge(magnitude: earthquake.magnitude, size: 56),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  earthquake.place,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '${DateFormatter.full(earthquake.time)} (Hora local)',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTab extends StatelessWidget {
  final Earthquake earthquake;
  const _InfoTab({required this.earthquake});

  @override
  Widget build(BuildContext context) {
    final rows = <(IconData, String, String)>[
      (Icons.speed, 'Magnitud', '${earthquake.magnitude} ${earthquake.magType ?? ''}'),
      (Icons.vertical_align_bottom, 'Profundidad',
          earthquake.depthKm != null ? '${earthquake.depthKm!.toStringAsFixed(0)} km' : 'N/D'),
      (Icons.explore, 'Coordenadas',
          '${earthquake.latitude.toStringAsFixed(2)}°, ${earthquake.longitude.toStringAsFixed(2)}°'),
      (Icons.location_on, 'Ubicación', earthquake.place),
      (Icons.access_time, 'Hora', DateFormatter.full(earthquake.time)),
      (Icons.category, 'Tipo de evento', earthquake.eventType ?? 'earthquake'),
      (Icons.verified, 'Estado', earthquake.status == 'reviewed' ? 'Revisado' : 'Automático'),
      (Icons.groups, 'Reportes de personas', '${earthquake.felt}'),
      (Icons.warning_amber, 'Posible tsunami', earthquake.tsunami == 1 ? 'Sí' : 'No'),
    ];

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: rows.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final (icon, label, value) = rows[i];
        return ListTile(
          leading: Icon(icon, color: AppColors.primary, size: 20),
          title: Text(label, style: const TextStyle(fontSize: 14)),
          trailing: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        );
      },
    );
  }
}

class _MapTab extends StatelessWidget {
  final Earthquake earthquake;
  const _MapTab({required this.earthquake});

  @override
  Widget build(BuildContext context) {
    final point = LatLng(earthquake.latitude, earthquake.longitude);
    return FlutterMap(
      options: MapOptions(initialCenter: point, initialZoom: 6),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.seismic_monitor_app',
        ),
        MarkerLayer(markers: [
          Marker(
            point: point,
            width: 40,
            height: 40,
            child: Icon(
              Icons.location_on,
              color: AppColors.colorForMagnitude(earthquake.magnitude),
              size: 40,
            ),
          ),
        ]),
      ],
    );
  }
}
