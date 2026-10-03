// Este archivo venía con la plantilla por defecto de `flutter create`
// (el "counter app" de ejemplo, con MyApp, un ícono '+' y un contador).
// Esta app no tiene nada de eso: el widget raíz se llama
// `SeismicMonitorApp` (definido en lib/main.dart) y no existe un
// contador ni un botón '+'. Por eso fallaba: `MyApp` no está definido
// y las expectativas ('0', '1', Icons.add) nunca se van a cumplir.
//
// Lo dejamos como una prueba de humo (smoke test) simple: solo verifica
// que la app arranca sin lanzar excepciones y que la pantalla principal
// (MainShell, con su barra de navegación inferior) se muestra.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:seismic_monitor_app/main.dart';

void main() {
  testWidgets('SeismicMonitorApp arranca y muestra la navegación principal',
          (WidgetTester tester) async {
        // Construye la app raíz real del proyecto.
        await tester.pumpWidget(const SeismicMonitorApp());
        await tester.pump();

        // Debe existir un MaterialApp (confirma que SeismicMonitorApp se
        // construyó sin errores) y la barra de navegación inferior con las
        // 5 pestañas (Inicio, Mapa, Listas, Estadísticas, Ajustes).
        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.byType(NavigationBar), findsOneWidget);
      });
}