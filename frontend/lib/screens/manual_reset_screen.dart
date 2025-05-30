import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ManualResetScreen extends StatefulWidget {
  const ManualResetScreen({Key? key}) : super(key: key);

  @override
  State<ManualResetScreen> createState() => _ManualResetScreenState();
}

class _ManualResetScreenState extends State<ManualResetScreen> {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _message;

  Future<void> _submit() async {
    setState(() { _loading = true; _message = null; });

    final token = _tokenController.text.trim();
    final pwd   = _passwordController.text;

    if (token.isEmpty || pwd.isEmpty) {
      setState(() {
        _message = 'Ingresa el código y la nueva contraseña';
        _loading = false;
      });
      return;
    }

    try {
      final success = await AuthService().resetPassword(token, pwd);
      setState(() {
        _message = success
            ? '✅ Contraseña actualizada con éxito'
            : '❌ Código inválido o expirado';
      });
    } catch (e) {
      setState(() {
        _message = 'Error de red: ${e.toString()}';
      });
    } finally {
      setState(() { _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset manual contraseña')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _tokenController,
              decoration: const InputDecoration(
                labelText: 'Código de recuperación',
                prefixIcon: Icon(Icons.vpn_key),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Nueva contraseña',
                prefixIcon: Icon(Icons.lock),
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
              ),
            const SizedBox(height: 12),
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
              onPressed: _submit,
              child: const Text('Restablecer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF415A77),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}