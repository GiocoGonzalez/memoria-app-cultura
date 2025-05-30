import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/evento.dart';
import 'evento_detalle_screen.dart';

class BuscarScreen extends StatefulWidget {
  const BuscarScreen({Key? key}) : super(key: key);

  @override
  State<BuscarScreen> createState() => _BuscarScreenState();
}

class _BuscarScreenState extends State<BuscarScreen> {
  final _buscarController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  List<Evento> _resultados = [];

  final Map<String, String> _keywordImages = {
    'cultura': 'assets/images/culturaa.jpg',
    'leer': 'assets/images/lectura.jpg',
    'lectura': 'assets/images/lectura.jpg',
    'musica': 'assets/images/musica.jpg',
    'turismo': 'assets/images/turismo.jpg',
    'danza': 'assets/images/danza.jpg',
    'coreografia': 'assets/images/coreografia.jpg',
    'teatro': 'assets/images/teatro.jpg',
    'humor': 'assets/images/humor.jpg',
    'logo': 'assets/images/logo.jpg',
  };

  String _imagenParaDescripcion(String desc) {
    final text = desc.toLowerCase();
    for (final entry in _keywordImages.entries) {
      if (text.contains(entry.key)) return entry.value;
    }
    return 'assets/images/culturaa.jpg';
  }

  Future<void> _buscarEventos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final filtro = _buscarController.text.trim();
      final eventos = await ApiService().fetchEventos(ciudad: filtro); // ciudad = filtro

      eventos.sort((a, b) {
        final aUrl = a.urlInscripcion ?? '';
        final bUrl = b.urlInscripcion ?? '';
        final aTiene = aUrl.isNotEmpty;
        final bTiene = bUrl.isNotEmpty;
        return bTiene && !aTiene ? 1 : aTiene && !bTiene ? -1 : 0;
      });

      setState(() => _resultados = eventos);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _buscarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscar Eventos'),
        backgroundColor: Color(0xFF415A77),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _buscarController,
                    decoration: const InputDecoration(
                      labelText: 'Buscar por ciudad o categoría',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _buscarEventos(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _buscarEventos,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF415A77),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Buscar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                ? Center(child: Text('Error: $_error'))
                : _resultados.isEmpty
                ? const Center(child: Text('No hay resultados'))
                : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _resultados.length,
              itemBuilder: (ctx, i) {
                final e = _resultados[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.asset(
                            _imagenParaDescripcion(e.descripcion),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      ListTile(
                        title: Text(e.titulo),
                        subtitle: Text(
                          e.descripcion.isNotEmpty ? e.descripcion : 'Sin información',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventoDetalleScreen(evento: e),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}