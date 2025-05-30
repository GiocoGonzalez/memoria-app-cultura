import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../models/evento.dart';

class ApiService {
  // Detectar automáticamente el host según la plataforma
  static String get _host {
    if (kIsWeb) return 'http://localhost:8080';      // Flutter Web
    if (Platform.isAndroid) return 'http://10.0.2.2:8080'; // Android emulador
    return 'http://localhost:8080';                  // iOS, desktop, etc.
  }

  static String get _importRuta  => '$_host/api/importar/madrid';
  static String get _eventosBase => '$_host/api/eventos';

  /// Dispara la importación desde Madrid en el backend
  Future<void> importarEventosMadrid() async {
    final uri = Uri.parse(_importRuta);
    final resp = await http.post(uri).timeout(const Duration(seconds: 15));
    if (resp.statusCode != 200) {
      throw Exception('Importación fallida (código ${resp.statusCode})');
    }
  }

  /// Obtener eventos (opcionalmente filtrados por ciudad)
  Future<List<Evento>> fetchEventos({String? ciudad}) {
    return fetchEventosPaginados(page: 0, size: 20, ciudad: ciudad);
  }

  /// Obtener eventos paginados
  Future<List<Evento>> fetchEventosPaginados({
    required int page,
    required int size,
    String? ciudad,
  }) async {
    final query = ciudad != null && ciudad.isNotEmpty
        ? '?page=$page&size=$size&filtro=$ciudad'
        : '?page=$page&size=$size';

    final uri = Uri.parse('$_eventosBase/paginado$query');
    final resp = await http.get(uri).timeout(const Duration(seconds: 10));

    if (resp.statusCode != 200) {
      throw Exception('Error cargando eventos (código ${resp.statusCode})');
    }

    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    final content = body['content'] as List<dynamic>;

    final eventos = content
        .map((e) => Evento.fromJson(e as Map<String, dynamic>))
        .toList();

    // Ordenar: primero los que tienen urlInscripcion
    eventos.sort((a, b) {
      final aTiene = a.urlInscripcion?.isNotEmpty ?? false;
      final bTiene = b.urlInscripcion?.isNotEmpty ?? false;

      if (aTiene && !bTiene) return -1;
      if (!aTiene && bTiene) return 1;
      return 0;
    });

    return eventos;
  }
}