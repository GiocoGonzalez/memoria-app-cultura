import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RecuperarPasswordScreen extends StatefulWidget {
  const RecuperarPasswordScreen({super.key});

  @override
  State<RecuperarPasswordScreen> createState() => _RecuperarPasswordScreenState();
}

class _RecuperarPasswordScreenState extends State<RecuperarPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _loading = false;
  String? _mensaje;

  void _enviarRecuperacion() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => _mensaje = 'Por favor, ingresa tu correo electrónico');
      return;
    }

    setState(() {
      _loading = true;
      _mensaje = null;
    });

    try {
      await _authService.recuperarPassword(email);
      setState(() {
        _mensaje = '📩 Revisa tu correo para restablecer la contraseña';
      });
    } catch (e) {
      print("Error en recuperación $e");
      setState(() {
        _mensaje = '❌ Error al enviar el correo, ¿El email está registado?: ${e.toString().replaceAll('Exception:', '')}';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        backgroundColor: Color(0xFF415A77),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Olvidaste tu contraseña?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text('Ingresa tu correo electrónico y te enviaremos instrucciones para recuperarla.'),
            const SizedBox(height: 24),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Correo electrónico',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _enviarRecuperacion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF415A77),
                foregroundColor: Colors.white,
              ),
              child: const Text('Enviar'),
            ),
            if (_mensaje != null) ...[
              const SizedBox(height: 16),
              Text(
                _mensaje!,
                style: TextStyle(
                  color: _mensaje!.startsWith('❌') ? Colors.red : Colors.green,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}