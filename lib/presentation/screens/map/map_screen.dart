import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/earthquake_provider.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../detail/earthquake_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  static const _defaultCenter = LatLng(10, -75); // Centrado en LatAm/Caribe
  double _zoom = 3.2;

  void _zoomBy(double delta) {
    _zoom = (_zoom + delta).clamp(1.0, 16.0);
    _mapController.move(_mapController.camera.center, _zoom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa'),
        leading: const BackButton(),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      body: Consumer<EarthquakeProvider>(
        builder: (context, provider, _) {
          if (provider.status == ViewStatus.loading &&
              provider.allEarthquakes.isEmpty) {
            return const LoadingWidget(message: 'Cargando mapa sísmico...');
          }
          if (provider.status == ViewStatus.error &&
              provider.allEarthquakes.isEmpty) {
            return ErrorStateWidget(
              message: provider.errorMessage,
              onRetry: provider.loadEarthquakes,
            );
          }

          final earthquakes = provider.allEarthquakes;

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _defaultCenter,
                  initialZoom: _zoom,
                  minZoom: 1,
                  maxZoom: 16,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.seismic_monitor_app',
                  ),
                  MarkerLayer(
                    markers: earthquakes.map((eq) {
                      final color = AppColors.colorForMagnitude(eq.magnitude);
                      final radius = 10 + (eq.magnitude.clamp(0, 8)) * 2.2;
                      return Marker(
                        point: LatLng(eq.latitude, eq.longitude),
                        width: radius,
                        height: radius,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => EarthquakeDetailScreen(earthquake: eq),
                            ),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.65),
                              shape: BoxShape.circle,
                              border: Border.all(color: color, width: 1.5),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Positioned(left: 16, bottom: 16, child: _Legend()),
              Positioned(
                right: 16,
                bottom: 16,
                child: Column(
                  children: [
                    _MapFab(icon: Icons.my_location, onTap: () {
                      _mapController.move(_defaultCenter, _zoom);
                    }),
                    const SizedBox(height: 10),
                    _MapFab(icon: Icons.add, onTap: () => _zoomBy(1)),
                    const SizedBox(height: 10),
                    _MapFab(icon: Icons.remove, onTap: () => _zoomBy(-1)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MapFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _MapFab({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: icon.toString(),
      onPressed: onTap,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.primary,
      child: Icon(icon),
    );
  }
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = [
      ('≥ 6.0', AppColors.magHigh),
      ('4.0 - 5.9', AppColors.magMedHigh),
      ('3.0 - 3.9', AppColors.magMed),
      ('< 3.0', AppColors.magLow),
    ];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(blurRadius: 6, color: Colors.black26)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Magnitud', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 6),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: item.$2, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(item.$1, style: const TextStyle(fontSize: 11)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
