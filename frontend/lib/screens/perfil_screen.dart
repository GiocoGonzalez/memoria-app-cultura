import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String _nombre = 'Usuario';
  String _email = '';
  String _ciudad = 'Añade tu ciudad';

  final TextEditingController _ciudadController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nombre = prefs.getString('usuario_nombre') ?? 'Usuario';
      _email = prefs.getString('usuario_email') ?? '';
      _ciudad = prefs.getString('usuario_ciudad') ?? 'Añade tu ciudad';
      _ciudadController.text = _ciudad == 'Añade tu ciudad' ? '' : _ciudad;
    });
  }

  Future<void> _guardarCiudad() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario_ciudad', _ciudadController.text.trim());
    setState(() {
      _ciudad = _ciudadController.text.trim();
    });
    Navigator.pop(context);
  }

  void _mostrarDialogoAyuda() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿En qué podemos ayudarte?'),
        content: const Text(
          'Escríbenos a gioco@giocodev.com',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _editarCiudad() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar ciudad'),
        content: TextField(
          controller: _ciudadController,
          decoration: const InputDecoration(labelText: 'Tu ciudad'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _guardarCiudad,
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {

    await AuthService().logout();

    context.go('/login');
  }

  @override
  void dispose() {
    _ciudadController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi perfil'),
        backgroundColor: Color(0xFF415A77),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFF415A77),
              child: Icon(Icons.person, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 16),
            Text(
              'Bienvenida, $_nombre',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _email,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Divider(height: 32),
            ListTile(
              leading: const Icon(Icons.location_on, color: Color(0xFF415A77),),
              title: const Text('Ciudad'),
              subtitle: Text(_ciudad),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.grey),
                onPressed: _editarCiudad,
              ),
            ),
            const Divider(height: 32),
            const Text(
              '¿Alguna duda?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _mostrarDialogoAyuda,
              icon: const Icon(Icons.help_outline),
              label: const Text('Estamos para ayudarte'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}