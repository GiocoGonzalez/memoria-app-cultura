import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _tokenController    = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _message;

  Future<void> _resetPassword() async {
    final token = _tokenController.text.trim();
    final pwd   = _passwordController.text;

    if (token.isEmpty || pwd.isEmpty) {
      setState(() => _message = 'Token y contraseña son obligatorios.');
      return;
    }

    setState(() {
      _loading = true;
      _message = null;
    });

    try {
      // Llama a tu AuthService, que usa 10.0.2.2 y tu baseUrl correcto
      final success = await AuthService()
          .resetPassword(token, pwd)
          .timeout(const Duration(seconds: 10));

      if (success) {
        setState(() => _message = 'Contraseña actualizada con éxito');
        // Deja que el usuario lea el mensaje
        await Future.delayed(const Duration(seconds: 2));
        // Vuelve al login (o directamente al home si prefieres)
        context.go('/login');
      } else {
        setState(() => _message = 'Token inválido o expirado');
      }
    } on TimeoutException {
      setState(() => _message = '⚠ Tiempo de espera agotado. Inténtalo de nuevo.');
    } catch (e) {
      setState(() => _message = '⚠ Error de red: $e');
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restablecer contraseña'),
        backgroundColor: Color(0xFF415A77),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.vpn_key),
                labelText: 'Código de recuperación',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock),
                labelText: 'Nueva contraseña',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            if (_message != null)
              Text(
                _message!,
                style: TextStyle(
                  color: _message!.startsWith('✅') ? Colors.green : Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 12),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF415A77),
              ),
              child: const Text('Restablecer contraseña'),
            ),
          ],
        ),
      ),
    );
  }
}