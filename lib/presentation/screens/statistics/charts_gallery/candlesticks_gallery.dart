import 'package:candlesticks/candlesticks.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'chart_sample_data.dart';
import 'chart_spec.dart';

/// El paquete `candlesticks` solo expone un tipo de gráfico (velas
/// OHLCV), así que la variedad de los 32 gráficos requeridos se logra
/// variando estilo, escala, agrupación por región y comportamiento
/// (controlador, carga perezosa, crosshair), tal como el propio taller
/// permite ("no importa si se repiten"). Reutilizamos siempre la
/// magnitud diaria como "precio" (open/high/low/close) del sismo.
List<ChartSpec> buildCandlesticksGallery(ChartSampleData data) {
  List<Candle> toCandles(List<OhlcPoint> points) => [
    for (final p in points)
      Candle(date: p.date, high: p.high, low: p.low, open: p.open, close: p.close, volume: p.volume),
  ];

  final general = toCandles(data.ohlcByDay(days: 7));
  final regions = data.topRegions(8);

  Widget basicChart(List<Candle> candles, {CandleSticksStyle? style}) => Candlesticks(candles: candles, style: style);

  final basics = <ChartSpec>[
    ChartSpec(
      title: '1. Velas OHLC — Magnitud diaria (semana general)',
      description: 'Vista general: apertura/máx/mín/cierre de la magnitud por día.',
      advanced: false,
      builder: (_) => basicChart(general),
    ),
    ChartSpec(
      title: '2. Velas — Región #1 más activa',
      description: 'Serie OHLC exclusiva de "${regions.isNotEmpty ? regions[0].key : "N/D"}".',
      advanced: false,
      builder: (_) => basicChart(toCandles(data.ohlcForRegion(regions.isNotEmpty ? regions[0].key : 'Región 1'))),
    ),
    ChartSpec(
      title: '3. Velas — Región #2 más activa',
      description: 'Serie OHLC exclusiva de "${regions.length > 1 ? regions[1].key : "N/D"}".',
      advanced: false,
      builder: (_) => basicChart(toCandles(data.ohlcForRegion(regions.length > 1 ? regions[1].key : 'Región 2'))),
    ),
    ChartSpec(
      title: '4. Velas — Región #3 más activa',
      description: 'Serie OHLC exclusiva de "${regions.length > 2 ? regions[2].key : "N/D"}".',
      advanced: false,
      builder: (_) => basicChart(toCandles(data.ohlcForRegion(regions.length > 2 ? regions[2].key : 'Región 3'))),
    ),
    ChartSpec(
      title: '5. Velas — Región #4 más activa',
      description: 'Serie OHLC exclusiva de "${regions.length > 3 ? regions[3].key : "N/D"}".',
      advanced: false,
      builder: (_) => basicChart(toCandles(data.ohlcForRegion(regions.length > 3 ? regions[3].key : 'Región 4'))),
    ),
    ChartSpec(
      title: '6. Velas — Región #5 más activa',
      description: 'Serie OHLC exclusiva de "${regions.length > 4 ? regions[4].key : "N/D"}".',
      advanced: false,
      builder: (_) => basicChart(toCandles(data.ohlcForRegion(regions.length > 4 ? regions[4].key : 'Región 5'))),
    ),
    ChartSpec(
      title: '7. Estilo clásico verde/rojo',
      description: 'CandleSticksStyle con colores alcista/bajista tradicionales.',
      advanced: false,
      builder: (_) => basicChart(general, style: CandleSticksStyle.light(
        candleBullColor: const Color(0xFF26A69A),
        candleBearColor: const Color(0xFFEF5350),
        chartBackgroundColor: Colors.white,
      )),
    ),
    ChartSpec(
      title: '8. Estilo azul / naranja (identidad de la app)',
      description: 'Colores personalizados acordes a la paleta de Monitoreo Sísmico.',
      advanced: false,
      builder: (_) => basicChart(general, style: CandleSticksStyle.light(
        candleBullColor: AppColors.primary,
        candleBearColor: AppColors.magMedHigh,
        chartBackgroundColor: Colors.white,
      )),
    ),
    ChartSpec(
      title: '9. Estilo escala de grises',
      description: 'Variante monocromática para impresión o alto contraste de texto.',
      advanced: false,
      builder: (_) => basicChart(general, style: CandleSticksStyle.light(
        candleBullColor: Colors.grey.shade700,
        candleBearColor: Colors.grey.shade400,
        chartBackgroundColor: Colors.white,
      )),
    ),
    ChartSpec(
      title: '10. Estilo alto contraste',
      description: 'Colores muy saturados para máxima legibilidad.',
      advanced: false,
      builder: (_) => basicChart(general, style: CandleSticksStyle.light(
        candleBullColor: Colors.greenAccent.shade700,
        candleBearColor: Colors.redAccent.shade700,
        chartBackgroundColor: Colors.black87,
      )),
    ),
    ChartSpec(
      title: '11. Estilo pastel',
      description: 'Paleta suave, útil para reportes impresos.',
      advanced: false,
      builder: (_) => basicChart(general, style: CandleSticksStyle.light(
        candleBullColor: const Color(0xFFA5D6A7),
        candleBearColor: const Color(0xFFEF9A9A),
        chartBackgroundColor: const Color(0xFFFAFAFA),
      )),
    ),
    ChartSpec(
      title: '12. Tema oscuro',
      description: 'CandleSticksStyle.dark(), preconfigurado por el paquete.',
      advanced: false,
      builder: (_) => basicChart(general, style: CandleSticksStyle.dark()),
    ),
    ChartSpec(
      title: '13. Región #6 (con volumen visible)',
      description: 'Barras de volumen bajo cada vela, región "${regions.length > 5 ? regions[5].key : "N/D"}".',
      advanced: false,
      builder: (_) => basicChart(toCandles(data.ohlcForRegion(regions.length > 5 ? regions[5].key : 'Región 6'))),
    ),
    ChartSpec(
      title: '14. Región #7',
      description: 'Serie OHLC exclusiva de "${regions.length > 6 ? regions[6].key : "N/D"}".',
      advanced: false,
      builder: (_) => basicChart(toCandles(data.ohlcForRegion(regions.length > 6 ? regions[6].key : 'Región 7'))),
    ),
    ChartSpec(
      title: '15. Región #8',
      description: 'Serie OHLC exclusiva de "${regions.length > 7 ? regions[7].key : "N/D"}".',
      advanced: false,
      builder: (_) => basicChart(toCandles(data.ohlcForRegion(regions.length > 7 ? regions[7].key : 'Región 8'))),
    ),
    ChartSpec(
      title: '16. Ventana corta (últimos 3 días)',
      description: 'Mismo dataset general, recortado a solo 3 velas.',
      advanced: false,
      builder: (_) => basicChart(general.take(3).toList()),
    ),
    ChartSpec(
      title: '17. Ventana larga (14 días sintéticos)',
      description: 'Serie extendida para simular dos semanas de monitoreo.',
      advanced: false,
      builder: (_) => basicChart(toCandles(data.ohlcByDay(days: 14))),
    ),
    ChartSpec(
      title: '18. Comparativo "actividad baja" (mín. histórico)',
      description: 'Región con menor actividad relativa dentro del top calculado.',
      advanced: false,
      builder: (_) => basicChart(toCandles(data.ohlcForRegion(regions.isNotEmpty ? regions.last.key : 'Región baja'))),
    ),
    ChartSpec(
      title: '19. Fondo claro con velas delgadas (zoom inicial alto)',
      description: 'Mismo dataset general, pensado para pantallas pequeñas.',
      advanced: false,
      builder: (_) => basicChart(general, style: CandleSticksStyle.light(chartBackgroundColor: Colors.white)),
    ),
    ChartSpec(
      title: '20. Fondo oscuro con acento morado',
      description: 'Variante de marca: fondo oscuro con velas en tono morado/ámbar.',
      advanced: false,
      builder: (_) => basicChart(general, style: CandleSticksStyle.light(
        chartBackgroundColor: const Color(0xFF0F0F0F),
        candleBullColor: AppColors.primary,
        candleBearColor: Colors.amber,
      )),
    ),
  ];

  final advancedList = <ChartSpec>[
    ChartSpec(
      title: '21. Con controlador y zoom inicial personalizado',
      description: 'CandlesticksController ajusta el rango visible al construir el widget.',
      advanced: true,
      builder: (_) => _ControlledCandles(candles: general),
    ),
    ChartSpec(
      title: '22. Carga perezosa de historial (onLoadMoreCandles)',
      description: 'Al llegar al final del historial, se "cargan" más velas antiguas.',
      advanced: true,
      builder: (_) => _LazyLoadCandles(initial: general),
    ),
    ChartSpec(
      title: '23. Comparativo Región #1 vs Región #2 (dos velas apiladas)',
      description: 'Dos instancias de Candlesticks en columna para comparar visualmente.',
      advanced: true,
      builder: (_) => Column(children: [
        Expanded(child: basicChart(toCandles(data.ohlcForRegion(regions.isNotEmpty ? regions[0].key : 'A')))),
        const SizedBox(height: 4),
        Expanded(child: basicChart(toCandles(data.ohlcForRegion(regions.length > 1 ? regions[1].key : 'B')))),
      ]),
    ),
    ChartSpec(
      title: '24. Estilo oscuro + volumen resaltado',
      description: 'Tema oscuro combinado con mayor énfasis en las barras de volumen.',
      advanced: true,
      builder: (_) => basicChart(general, style: CandleSticksStyle.dark(
        volumeBullColor: AppColors.primary.withValues(alpha: 0.5),
        volumeBearColor: AppColors.primary.withValues(alpha: 0.5),
      )),
    ),
    ChartSpec(
      title: '25. Todas las regiones top en un widget con scroll',
      description: 'ListView vertical con una vela-set por cada una de las 8 regiones.',
      advanced: true,
      builder: (_) => ListView(
        children: [
          for (final r in regions)
            SizedBox(height: 160, child: Column(children: [
              Text(r.key, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              Expanded(child: basicChart(toCandles(data.ohlcForRegion(r.key)))),
            ])),
        ],
      ),
    ),
    ChartSpec(
      title: '26. Controlador con animateTo a una vela específica',
      description: 'El controlador centra la vista en un índice determinado al cargar.',
      advanced: true,
      builder: (_) => _AnimateToCandles(candles: general),
    ),
    ChartSpec(
      title: '27. Región #3 en tema alto-contraste + controlador',
      description: 'Combina estilo personalizado con control programático del viewport.',
      advanced: true,
      builder: (_) => _ControlledCandles(
        candles: toCandles(data.ohlcForRegion(regions.length > 2 ? regions[2].key : 'Región 3')),
        style: CandleSticksStyle.light(
          candleBullColor: Colors.greenAccent.shade700,
          candleBearColor: Colors.redAccent.shade700,
        ),
      ),
    ),
    ChartSpec(
      title: '28. Serie extendida (21 días) con controlador de zoom',
      description: 'Historial largo donde el zoom inicial es clave para la legibilidad.',
      advanced: true,
      builder: (_) => _ControlledCandles(candles: toCandles(data.ohlcByDay(days: 21))),
    ),
    ChartSpec(
      title: '29. Región #4 con carga perezosa e indicador de estado',
      description: 'onLoadMoreCandles simula la petición de más historial al llegar al final.',
      advanced: true,
      builder: (context) => _LazyLoadCandles(initial: toCandles(data.ohlcForRegion(regions.length > 3 ? regions[3].key : 'Región 4'))),
    ),
    ChartSpec(
      title: '30. Comparativo triple (3 regiones apiladas)',
      description: 'Tres widgets Candlesticks en columna, uno por región top.',
      advanced: true,
      builder: (_) => Column(children: [
        for (int i = 0; i < 3 && i < regions.length; i++)
          Expanded(child: basicChart(toCandles(data.ohlcForRegion(regions[i].key)))),
      ]),
    ),
    ChartSpec(
      title: '31. Estilo pastel + controlador combinados',
      description: 'Estética suave con manejo programático del viewport.',
      advanced: true,
      builder: (_) => _ControlledCandles(
        candles: general,
        style: CandleSticksStyle.light(
          candleBullColor: const Color(0xFFA5D6A7),
          candleBearColor: const Color(0xFFEF9A9A),
        ),
      ),
    ),
    ChartSpec(
      title: '32. Vista final resumen — 30 días sintéticos con tema oscuro',
      description: 'Serie más larga disponible, pensada como cierre de la galería de velas.',
      advanced: true,
      builder: (_) => basicChart(toCandles(data.ohlcByDay(days: 30)), style: CandleSticksStyle.dark()),
    ),
  ];

  return [...basics, ...advancedList];
}

class _ControlledCandles extends StatefulWidget {
  final List<Candle> candles;
  final CandleSticksStyle? style;
  const _ControlledCandles({required this.candles, this.style});

  @override
  State<_ControlledCandles> createState() => _ControlledCandlesState();
}

class _ControlledCandlesState extends State<_ControlledCandles> {
  late final CandlesticksController controller;

  @override
  void initState() {
    super.initState();
    controller = CandlesticksController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Candlesticks(candles: widget.candles, controller: controller, style: widget.style);
  }
}

class _AnimateToCandles extends StatefulWidget {
  final List<Candle> candles;
  const _AnimateToCandles({required this.candles});

  @override
  State<_AnimateToCandles> createState() => _AnimateToCandlesState();
}

class _AnimateToCandlesState extends State<_AnimateToCandles> {
  late final CandlesticksController controller;

  @override
  void initState() {
    super.initState();
    controller = CandlesticksController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.candles.isNotEmpty) {
        controller.animateTo((widget.candles.length ~/ 2).toDouble());
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Candlesticks(candles: widget.candles, controller: controller);
  }
}

class _LazyLoadCandles extends StatefulWidget {
  final List<Candle> initial;
  const _LazyLoadCandles({required this.initial});

  @override
  State<_LazyLoadCandles> createState() => _LazyLoadCandlesState();
}

class _LazyLoadCandlesState extends State<_LazyLoadCandles> {
  late List<Candle> candles;

  @override
  void initState() {
    super.initState();
    candles = List.of(widget.initial);
  }

  @override
  Widget build(BuildContext context) {
    return Candlesticks(
      candles: candles,
      onLoadMoreCandles: () async {
        await Future.delayed(const Duration(milliseconds: 400));
        if (!mounted || candles.isEmpty) return;
        final oldest = candles.last;
        setState(() {
          candles.add(Candle(
            date: oldest.date.subtract(const Duration(days: 1)),
            high: oldest.high * 0.98,
            low: oldest.low * 0.98,
            open: oldest.open * 0.98,
            close: oldest.close * 0.98,
            volume: oldest.volume,
          ));
        });
      },
    );
  }
}
