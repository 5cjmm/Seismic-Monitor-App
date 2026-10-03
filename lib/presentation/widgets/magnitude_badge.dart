import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Círculo de color con el número de magnitud, como en las listas y
/// en el detalle del terremoto ("5.2" en rojo, "3.2" en amarillo, etc).
class MagnitudeBadge extends StatelessWidget {
  final double magnitude;
  final double size;

  const MagnitudeBadge({super.key, required this.magnitude, this.size = 44});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.colorForMagnitude(magnitude);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Text(
        magnitude.toStringAsFixed(1),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.32,
        ),
      ),
    );
  }
}
