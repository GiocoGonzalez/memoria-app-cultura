import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EnterRecoveryCodeScreen extends StatefulWidget {
  const EnterRecoveryCodeScreen({Key? key}) : super(key: key);

  @override
  State<EnterRecoveryCodeScreen> createState() => _EnterRecoveryCodeScreenState();
}

class _EnterRecoveryCodeScreenState extends State<EnterRecoveryCodeScreen> {
  final _codeCtrl = TextEditingController();
  String? _message;

  void _verify() {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) {
      setState(() { _message = 'Ingresa el código'; });
      return;
    }
    // Navegamos al reset pasando el token
    GoRouter.of(context).go('/reset/$code');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingresa tu código')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Te hemos enviado un código a tu correo.\n'
                  'Cópialo y pégalo aquí para continuar.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _codeCtrl,
              decoration: const InputDecoration(
                labelText: 'Código de recuperación',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_message != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _message!.startsWith('Ingresa') ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _verify,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF415A77),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Verificar'),
            ),
          ],
        ),
      ),
    );
  }
}