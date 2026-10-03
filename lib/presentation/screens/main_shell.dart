import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'map/map_screen.dart';
import 'list/earthquake_list_screen.dart';
import 'statistics/statistics_screen.dart';
import 'settings/settings_screen.dart';

/// Contenedor que aloja las 5 pestañas del mockup y mantiene su estado
/// vivo con IndexedStack (evita recargar la API al cambiar de pestaña).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final _screens = const [
    HomeScreen(),
    MapScreen(),
    EarthquakeListScreen(),
    StatisticsScreen(),
    SettingsScreen(),
  ];

  void goToTab(int index) => setState(() => _currentIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TabNavigator(
        goToTab: goToTab,
        child: IndexedStack(index: _currentIndex, children: _screens),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.place_outlined), selectedIcon: Icon(Icons.place), label: 'Mapa'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Listas'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Estadísticas'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}

/// InheritedWidget-like helper: permite a cualquier pantalla hija navegar
/// a otra pestaña (usado por el botón "Ver todos" y el FAB de Inicio).
class TabNavigator extends InheritedWidget {
  final void Function(int) goToTab;

  const TabNavigator({super.key, required this.goToTab, required super.child});

  static TabNavigator? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<TabNavigator>();
  }

  @override
  bool updateShouldNotify(TabNavigator oldWidget) => false;
}
