import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/evento.dart';
import '../services/api_service.dart';
import 'evento_detalle_screen.dart';

class Favoritos_Screen extends StatefulWidget {
  const Favoritos_Screen({Key? key}) : super(key: key);

  @override
  State<Favoritos_Screen> createState() => _Favoritos_ScreenState();
}

class _Favoritos_ScreenState extends State<Favoritos_Screen> {
  List<Evento> _favoritos = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }

  Future<void> _cargarFavoritos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList('favoritos') ?? [];

      final todos = await ApiService().fetchEventos();
      final favoritos = todos.where((e) => ids.contains(e.id.toString())).toList();

      setState(() {
        _favoritos = favoritos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        backgroundColor: Color(0xFF415A77),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _favoritos.isEmpty
          ? const Center(child: Text('No tienes eventos favoritos'))
          : ListView.builder(
        itemCount: _favoritos.length,
        itemBuilder: (ctx, i) {
          final e = _favoritos[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              title: Text(e.titulo),
              subtitle: Text(
                e.descripcion.isNotEmpty ? e.descripcion : 'Sin información',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
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