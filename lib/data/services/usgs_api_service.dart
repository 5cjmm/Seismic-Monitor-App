import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/earthquake_model.dart';

/// Excepción propia de la capa de datos para errores de red/API.
class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

/// Servicio responsable exclusivamente de la comunicación HTTP con la
/// API pública de USGS. No conoce nada de UI ni de estado de la app.
class UsgsApiService {
  final http.Client _client;

  UsgsApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Descarga el feed GeoJSON y lo convierte en una lista de [Earthquake].
  Future<List<Earthquake>> fetchEarthquakes({
    required String magnitude,
    required String period,
  }) async {
    final url = ApiConstants.buildFeedUrl(
      magnitude: magnitude,
      period: period,
    );

    try {
      final response = await _client
          .get(Uri.parse(url))
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode != 200) {
        throw ApiException(
          'El servidor de USGS respondió con código ${response.statusCode}',
        );
      }

      final Map<String, dynamic> body = json.decode(response.body);
      final List features = body['features'] as List? ?? [];

      return features
          .map((f) => Earthquake.fromGeoJson(f as Map<String, dynamic>))
          .toList();
    } on FormatException {
      throw ApiException('La respuesta de la API no tiene un formato válido.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(
        'No fue posible conectar con USGS. Verifica tu conexión a internet.',
      );
    }
  }

  void dispose() => _client.close();
}
