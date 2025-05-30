import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/evento.dart';
import '../services/api_service.dart';
import 'evento_detalle_screen.dart';

class InscripcionesScreen extends StatefulWidget {
  const InscripcionesScreen({Key? key}) : super(key: key);

  @override
  State<InscripcionesScreen> createState() => _InscripcionesScreenState();
}

class _InscripcionesScreenState extends State<InscripcionesScreen> {
  List<Evento> _inscritos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarInscripciones();
  }

  Future<void> _cargarInscripciones() async {
    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final listaIds = prefs.getStringList('inscripciones') ?? [];
      final eventos = await ApiService().fetchEventos();
      final filtrados = eventos.where((e) => listaIds.contains(e.id.toString())).toList();

      setState(() {
        _inscritos = filtrados;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _cancelarInscripcion(int eventoId) async {
    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList('inscripciones') ?? [];
    lista.remove(eventoId.toString());
    await prefs.setStringList('inscripciones', lista);

    setState(() {
      _inscritos.removeWhere((e) => e.id == eventoId);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Inscripción cancelada')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Inscripciones'),
        backgroundColor: Color(0xFF415A77),
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _inscritos.isEmpty
          ? const Center(child: Text('Aún no estás inscrito en ningún evento.'))
          : ListView.builder(
        itemCount: _inscritos.length,
        itemBuilder: (ctx, i) {
          final e = _inscritos[i];
          return Dismissible(
            key: ValueKey(e.id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => _cancelarInscripcion(e.id),
            child: ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: Text(e.titulo),
              subtitle: Text(e.ciudad),
              trailing: IconButton(
                icon: const Icon(Icons.cancel),
                onPressed: () => _cancelarInscripcion(e.id),
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventoDetalleScreen(evento: e),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}