import 'package:flutter/material.dart';
import '../models/evento.dart';
import '../services/api_service.dart';
import 'evento_detalle_screen.dart';

class EventosScreen extends StatefulWidget {
  const EventosScreen({super.key});

  @override
  State<EventosScreen> createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  final _ciudadController = TextEditingController();
  late final PageController _pageController;

  List<Evento> _eventos = [];
  int _paginaActual = 0;
  int _paginasCargadas = 1;
  final int _tamanioPagina = 20;
  bool _cargando = false;
  bool _hayMas = true;


  final Map<String, String> _keywordImages = {
    'cultura': 'assets/images/culturaa.jpg',
    'leer':    'assets/images/lectura.jpg',
    'lectura': 'assets/images/lectura.jpg',
    'musica':  'assets/images/musica.jpg',
    'turismo': 'assets/images/turismo.jpg',
    'banda': 'assets/images/banda.jpg',
    'Folclore': 'assets/images/Folclore.jpg',
    'teatro': 'assets/images/teatro.jpg',
    'coreografia': 'assets/images/coreografia.jpg',
    'humor': 'assets/images/humor.jpg',
    'Ballet': 'assets/images/danza.jpg',
    'gobiernos': 'assets/images/danza.jpg',

  };

  String _imagenParaDescripcion(String descripcion) {
    final txt = descripcion.toLowerCase();
    for (final e in _keywordImages.entries) {
      if (txt.contains(e.key)) return e.value;
    }
    return 'assets/images/culturaa.jpg';
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0)
      ..addListener(_pageListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarEventos(reset: true);
    });
  }

  void _pageListener() {
    final nueva = _pageController.page?.round();
    if (nueva != null && nueva != _paginaActual) {
      setState(() => _paginaActual = nueva);
      if (nueva == _paginasCargadas - 1 && _hayMas) {
        _cargarEventos();
      }
    }
  }

  @override
  void dispose() {
    _pageController
      ..removeListener(_pageListener)
      ..dispose();
    super.dispose();
  }

  Future<void> _cargarEventos({bool reset = false}) async {
    if (reset) {
      _paginaActual = 0;
      _paginasCargadas = 1;
      _eventos.clear();
      _hayMas = true;
      _pageController.jumpToPage(0);
    }

    setState(() => _cargando = true);
    try {
      final nuevos = await ApiService().fetchEventosPaginados(
        page: _paginaActual,
        size: _tamanioPagina,

      );
      setState(() {
        _eventos = nuevos;
        _hayMas = nuevos.length == _tamanioPagina;
        if (!reset) _paginasCargadas = _paginaActual + 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando eventos: $e')),
      );
    } finally {
      setState(() => _cargando = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eventos Culturales'),
        backgroundColor: Color(0xFF415A77),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [

          //  Páginas horizontales de eventos
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              itemCount: _paginasCargadas,
              itemBuilder: (ctx, pageIndex) {
                if (_cargando && pageIndex == _paginaActual) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _eventos.length,
                  itemBuilder: (_, i) {
                    final e = _eventos[i];
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
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: Image.asset(
                                _imagenParaDescripcion(e.descripcion),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          ListTile(
                            title: Text(e.titulo,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall),
                            subtitle: Text(
                              e.descripcion.isNotEmpty
                                  ? e.descripcion
                                  : 'Sin información',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    EventoDetalleScreen(evento: e),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),


          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_paginasCargadas, (i) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _paginaActual ? 12 : 8,
                  height: i == _paginaActual ? 12 : 8,
                  decoration: BoxDecoration(
                    color: i == _paginaActual
                        ? Color(0xFF415A77)
                        : Colors.grey.shade400,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ),

          if (_cargando) const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }
}