import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/evento.dart';
import '../services/favorites_service.dart';

class EventoDetalleScreen extends StatefulWidget {
  final Evento evento;
  const EventoDetalleScreen({Key? key, required this.evento}) : super(key: key);

  @override
  State<EventoDetalleScreen> createState() => _EventoDetalleScreenState();
}

class _EventoDetalleScreenState extends State<EventoDetalleScreen> {
  bool _isFavorito = false;

  @override
  void initState() {
    super.initState();
    _cargarEstadoFavorito();
  }

  Future<void> _cargarEstadoFavorito() async {
    final isFav = await FavoritesService.isFavorite(widget.evento.id.toString());
    setState(() => _isFavorito = isFav);
  }

  Future<void> _toggleFavorito() async {
    await FavoritesService.toggle(widget.evento.id.toString());
    setState(() => _isFavorito = !_isFavorito);
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.evento;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Evento'),
        backgroundColor: const Color(0xFF415A77),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              _isFavorito ? Icons.favorite : Icons.favorite_border,
              color: _isFavorito ? Colors.red : null,
            ),
            onPressed: _toggleFavorito,
            tooltip: _isFavorito ? 'Quitar de favoritos' : 'Marcar como favorito',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Icon(Icons.event, size: 80, color: const Color(0xFF415A77)),
            ),
            const SizedBox(height: 24),
            Text(
              e.titulo,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFF415A77)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.ciudad,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.description_outlined, color: Color(0xFF415A77)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    e.descripcion.isNotEmpty ? e.descripcion : 'Sin información',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Divider(thickness: 1),
            const SizedBox(height: 16),

            //  Botón de inscripción (redirige a la URL oficial)
            if (e.urlInscripcion != null && e.urlInscripcion!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(e.urlInscripcion!);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No se pudo abrir el enlace.')),
                        );
                      }
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text("Inscribirse"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF415A77),
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),

            const Center(
              child: Text(
                'Próximamente: mapa, horarios y más.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Datos obtenidos del Ayuntamiento',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}