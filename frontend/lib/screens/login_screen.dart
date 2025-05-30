import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authService  = AuthService();

  bool   _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });

    final email = _emailCtrl.text.trim();
    final pwd   = _passwordCtrl.text.trim();
    if (email.isEmpty || pwd.isEmpty) {
      setState(() {
        _error   = 'Completa todos los campos';
        _loading = false;
      });
      return;
    }

    try {
      await _authService.login(email, pwd);
      context.go('/home');
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
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 30),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.email), labelText: 'Correo electrónico', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordCtrl,
            obscureText: true,
            decoration: const InputDecoration(prefixIcon: Icon(Icons.lock), labelText: 'Contraseña', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ElevatedButton(
            onPressed: _login,
            style: ElevatedButton.styleFrom(),
            child: const Text('Entrar'),
          ),
          const SizedBox(height: 8),
          TextButton(onPressed: () => context.go('/registro'), child: const Text('¿No tienes cuenta? Regístrate')),
          TextButton(onPressed: () => context.go('/forgot'), child: const Text('¿Olvidaste tu contraseña?')),
          ElevatedButton.icon(
            icon: const Icon(Icons.g_mobiledata),
            label: const Text('Entrar con Google'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: const BorderSide(color: Colors.black26),
            ),
            onPressed: () async {
              setState(() {
                _loading = true;
                _error = null;
              });

              try {
                await _authService.loginWithGoogle();
                if (mounted) context.go('/home');
              } catch (e) {
                setState(() {
                  _error = e.toString().replaceAll('Exception: ', '');
                });
              } finally {
                if (mounted) setState(() => _loading = false);
              }
            },
          ),

        ]),
      ),
    );
  }
}