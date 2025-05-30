import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool   _loading = false;
  String? _message;

  Future<void> _sendCode() async {
    setState(() { _loading = true; _message = null; });
    try {
      await AuthService().recuperarPassword(_emailCtrl.text.trim());
      context.go('/reset');
    } catch (e) {
      setState(() { _message = 'Error: ${e.toString()}'; });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar contraseña'), backgroundColor: Color(0xFF415A77),),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const Text('Ingresa tu correo para recibir un código de recuperación', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          TextField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Correo electrónico', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          if (_message != null) Text(_message!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
          _loading
              ? const CircularProgressIndicator()
              : ElevatedButton(
            onPressed: _sendCode,
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF415A77),),
            child: const Text('Enviar código'),
          ),
        ]),
      ),
    );
  }
}