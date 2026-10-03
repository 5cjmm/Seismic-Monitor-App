import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Indicador de carga centralizado, usado en todas las pantallas mientras
/// se espera la respuesta de la API de USGS.
class LoadingWidget extends StatelessWidget {
  final String message;

  const LoadingWidget({super.key, this.message = 'Cargando datos sísmicos...'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
