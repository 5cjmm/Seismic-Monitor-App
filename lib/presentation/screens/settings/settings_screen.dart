import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SettingsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return ListView(
            children: [
              const _SectionLabel('GENERAL'),
              ListTile(
                leading: const Icon(Icons.straighten, color: AppColors.primary),
                title: const Text('Unidades'),
                trailing: Text(settings.metricUnits ? 'Métrico' : 'Imperial'),
                onTap: settings.toggleUnits,
              ),
              ListTile(
                leading: const Icon(Icons.notifications_none, color: AppColors.primary),
                title: const Text('Notificaciones'),
                trailing: Switch(
                  value: settings.notificationsEnabled,
                  onChanged: (_) => settings.toggleNotifications(),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.sync, color: AppColors.primary),
                title: const Text('Actualizar datos'),
                trailing: Text('Cada ${settings.refreshMinutes} min'),
                onTap: () => _pickRefresh(context, settings),
              ),
              ListTile(
                leading: const Icon(Icons.palette_outlined, color: AppColors.primary),
                title: const Text('Tema'),
                trailing: Text(settings.darkTheme ? 'Oscuro' : 'Claro'),
                onTap: settings.toggleTheme,
              ),
              const Divider(),
              const _SectionLabel('FILTROS POR DEFECTO'),
              ListTile(
                leading: const Icon(Icons.speed, color: AppColors.primary),
                title: const Text('Magnitud mínima'),
                trailing: Text(settings.defaultMinMagnitude.toStringAsFixed(1)),
                onTap: () => _pickMinMagnitude(context, settings),
              ),
              const ListTile(
                leading: Icon(Icons.public, color: AppColors.primary),
                title: Text('Región'),
                trailing: Text('Todo el mundo'),
              ),
              const ListTile(
                leading: Icon(Icons.vertical_align_bottom, color: AppColors.primary),
                title: Text('Profundidad máxima'),
                trailing: Text('700 km'),
              ),
              const Divider(),
              const _SectionLabel('ACERCA DE'),
              const ListTile(
                leading: Icon(Icons.dns_outlined, color: AppColors.primary),
                title: Text('Fuente de datos'),
                trailing: Text('USGS Earthquake API'),
              ),
              const ListTile(
                leading: Icon(Icons.info_outline, color: AppColors.primary),
                title: Text('Versión'),
                trailing: Text('1.0.0'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _pickRefresh(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 5, 10, 30].map((m) {
            return ListTile(
              title: Text('Cada $m min'),
              onTap: () {
                settings.setRefreshMinutes(m);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _pickMinMagnitude(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1.0, 2.5, 3.0, 4.5].map((m) {
            return ListTile(
              title: Text(m.toStringAsFixed(1)),
              onTap: () {
                settings.setDefaultMinMagnitude(m);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
