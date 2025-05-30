import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({Key? key}) : super(key: key);

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _nombreController   = TextEditingController();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService        = AuthService();

  bool   _loading = false;
  String? _error;

  Future<void> _registro() async {
    setState(() {
      _loading = true;
      _error   = null;
    });

    final nombre   = _nombreController.text.trim();
    final email    = _emailController.text.trim();
    final password = _passwordController.text;

    if (nombre.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() {
        _error   = 'Completa todos los campos';
        _loading = false;
      });
      return;
    }

    try {
      final mensaje = await _authService.registro(nombre, email, password);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.green, duration: const Duration(seconds: 3)),
      );
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Cuenta'), backgroundColor: Color(0xFF415A77),),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 30),
          TextField(
            controller: _nombreController,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.person),
              labelText: 'Nombre completo',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.email),
              labelText: 'Correo electrónico',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.lock),
              labelText: 'Contraseña',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
            onPressed: _registro,
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF415A77), padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Registrarse', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('¿Ya tienes cuenta? Inicia sesión'),
          ),
        ]),
      ),
    );
  }
}