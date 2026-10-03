import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_formatter.dart';
import '../../data/models/earthquake_model.dart';
import 'magnitude_badge.dart';

/// ListTile con leading (badge de magnitud) y trailing (chevron), usado
/// tanto en "Terremotos recientes" (Inicio) como en "Lista de terremotos".
class EarthquakeListTile extends StatelessWidget {
  final Earthquake earthquake;
  final VoidCallback? onTap;

  const EarthquakeListTile({super.key, required this.earthquake, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: MagnitudeBadge(magnitude: earthquake.magnitude),
      title: Text(
        earthquake.place,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        '${DateFormatter.full(earthquake.time)}'
        '${earthquake.depthKm != null ? '\nProfundidad: ${earthquake.depthKm!.toStringAsFixed(0)} km' : ''}',
        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      ),
      isThreeLine: earthquake.depthKm != null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
    );
  }
}
