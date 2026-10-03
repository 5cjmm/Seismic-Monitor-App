import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../providers/earthquake_provider.dart';
import '../../widgets/earthquake_list_tile.dart';
import '../../widgets/error_state_widget.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../detail/earthquake_detail_screen.dart';
import '../main_shell.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Carga inicial de datos apenas se monta la pantalla.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EarthquakeProvider>().loadEarthquakes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<EarthquakeProvider>(
        builder: (context, provider, _) {
          if (provider.status == ViewStatus.loading &&
              provider.allEarthquakes.isEmpty) {
            return const LoadingWidget();
          }
          if (provider.status == ViewStatus.error &&
              provider.allEarthquakes.isEmpty) {
            return ErrorStateWidget(
              message: provider.errorMessage,
              onRetry: provider.loadEarthquakes,
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _HeroCard(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.4,
                    children: [
                      StatCard(
                        icon: Icons.vibration,
                        iconColor: AppColors.magHigh,
                        value: '${provider.totalCount}',
                        label: 'Terremotos hoy',
                      ),
                      StatCard(
                        icon: Icons.warning_amber_rounded,
                        iconColor: AppColors.magMedHigh,
                        value: provider.maxMagnitude.toStringAsFixed(1),
                        label: 'Mayor magnitud',
                      ),
                      StatCard(
                        icon: Icons.public,
                        iconColor: AppColors.primary,
                        value: '${provider.affectedRegionsCount}',
                        label: 'Regiones afectadas',
                      ),
                      StatCard(
                        icon: Icons.access_time,
                        iconColor: AppColors.magLow,
                        value: provider.lastUpdated != null
                            ? DateFormatter.time(provider.lastUpdated!)
                            : '--:--',
                        label: 'Actualizado',
                      ),
                    ],
                  ),
                ),
                SectionHeader(
                  title: 'Terremotos recientes',
                  actionLabel: 'Ver todos',
                  onAction: () => TabNavigator.of(context)?.goToTab(2),
                ),
                ...provider.recentTop5.map(
                  (eq) => EarthquakeListTile(
                    earthquake: eq,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => EarthquakeDetailScreen(earthquake: eq),
                      ),
                    ),
                  ),
                ),
                if (provider.recentTop5.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No se registran sismos recientes con los filtros actuales.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<EarthquakeProvider>().refresh(),
        child: const Icon(Icons.vibration),
      ),
    );
  }
}

/// Tarjeta morada "Monitoreo Sísmico - Información en tiempo real..."
class _HeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.graphic_eq, color: Colors.white, size: 28),
            SizedBox(height: 10),
            Text(
              'Monitoreo Sísmico',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Información en tiempo real de terremotos en todo el mundo',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
