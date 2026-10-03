# 📱 App Monitoreo Sísmico — Flutter + API de USGS

Aplicación que consume la API pública de **USGS (United States Geological
Survey) Earthquake Hazards Program** para mostrar terremotos en tiempo real,
materializando el mockup diseñado en la actividad.

---

## 1. Por qué esta API

- **Endpoint usado**: `https://earthquake.usgs.gov/earthquake/feed/v1.0/summary/all_week.geojson`
- Es pública, **no requiere API key**, responde en formato **GeoJSON**
  (estándar, ideal para mapas) y se actualiza en tiempo real.
- Documentación oficial: https://earthquake.usgs.gov/earthquake/feed/v1.0/geojson.php

---

## 2. Arquitectura del proyecto (organización por capas)

```
lib/
├── main.dart                     # Punto de entrada + inyección de providers
│
├── core/                         # Configuración transversal, sin lógica de negocio
│   ├── constants/
│   │   ├── api_constants.dart    # URLs y builders del feed de USGS
│   │   └── app_colors.dart       # Paleta de colores del mockup
│   ├── theme/
│   │   └── app_theme.dart        # ThemeData Material 3 centralizado
│   └── utils/
│       ├── date_formatter.dart   # Formateo de fechas en español
│       └── magnitude_utils.dart  # Clasificación de rangos de magnitud
│
├── data/                         # CAPA DE DATOS
│   ├── models/
│   │   └── earthquake_model.dart # Mapea el JSON crudo -> objeto Dart
│   ├── services/
│   │   └── usgs_api_service.dart # Único punto que hace fetch() a internet
│   └── repositories/
│       └── earthquake_repository.dart # Abstrae la fuente de datos
│
└── presentation/                 # CAPA DE PRESENTACIÓN
    ├── providers/                # CAPA DE LÓGICA / ESTADO (ChangeNotifier)
    │   ├── earthquake_provider.dart
    │   └── settings_provider.dart
    ├── screens/                  # Una carpeta por pantalla del mockup
    │   ├── main_shell.dart       # NavigationBar inferior (5 pestañas)
    │   ├── home/home_screen.dart
    │   ├── map/map_screen.dart
    │   ├── list/earthquake_list_screen.dart
    │   ├── detail/earthquake_detail_screen.dart
    │   ├── statistics/statistics_screen.dart
    │   └── settings/settings_screen.dart
    └── widgets/                  # Widgets reutilizables entre pantallas
        ├── stat_card.dart
        ├── magnitude_badge.dart
        ├── earthquake_list_tile.dart
        ├── section_header.dart
        ├── loading_widget.dart
        └── error_state_widget.dart
```

### Flujo de datos (una sola dirección)

```
UI (screens)  --escucha-->  Provider (estado)  --llama-->  Repository  --llama-->  ApiService  -->  USGS
     ^                             |
     |____________ notifyListeners() cuando cambia el estado ______________|
```

Esta separación permite, por ejemplo, cambiar la fuente de datos (agregar
caché local, otra API, datos de prueba) sin tocar ni una sola pantalla.

---

## 3. Manejo de estados de carga y error

`EarthquakeProvider` expone un `enum ViewStatus { initial, loading, success, error }`.
Cada pantalla reacciona a ese estado con:

- `LoadingWidget` → mientras se espera la respuesta HTTP.
- `ErrorStateWidget` → si falla la conexión, timeout o la API responde con error,
  con botón **Reintentar**.
- Contenido real → cuando `status == success`.

`UsgsApiService` lanza una `ApiException` propia con mensajes entendibles
(en vez de dejar pasar excepciones crudas de `http` o de parseo JSON).

---

## 4. Pantallas implementadas (según el mockup)

| Pantalla | Elementos clave |
|---|---|
| **Inicio** | Tarjeta hero, 4 StatCards (total, mayor magnitud, regiones, actualización), lista "Terremotos recientes", FAB |
| **Mapa** | `flutter_map` (OpenStreetMap, sin API key) con marcadores coloreados por magnitud, leyenda, FABs de zoom/ubicación |
| **Listas** | Chips de filtro (Hoy / Magnitud 3.0+ / Todo el mundo), búsqueda por ubicación, FAB de filtros avanzados |
| **Detalle** | Encabezado con magnitud, `TabBar` (Información / Mapa con marcador puntual) |
| **Estadísticas** | Gráfico de barras (sismos por día) y donut (distribución por magnitud) con `fl_chart`, profundidad promedio |
| **Ajustes** | Unidades, notificaciones, frecuencia de actualización, tema, filtros por defecto — persistidos con `shared_preferences` |

---

## 5. Cómo ejecutar el proyecto

Requisitos: tener **Flutter SDK** instalado (`flutter --version`).

```bash
cd seismic_monitor_app
flutter pub get
flutter run
```

Para generar un APK:

```bash
flutter build apk --release
```

> Nota: este proyecto fue generado como código fuente organizado; no fue
> compilado en este entorno (no cuenta con el SDK de Flutter ni acceso a
> pub.dev). Al ejecutar `flutter pub get` en tu máquina se descargarán las
> dependencias declaradas en `pubspec.yaml`.

---

