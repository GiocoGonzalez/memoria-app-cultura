import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static const String baseUrl = 'http://10.0.2.2:8080/api/usuarios';

  /// Login clásico
  Future<void> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('usuario_id', data['id'].toString());
      prefs.setString('usuario_nombre', data['nombreCompleto']);
      prefs.setString('usuario_email', data['email']);
      prefs.setString('usuario_origen', data['origen']);
      prefs.setBool('usuario_activo', data['activo']);
      print('Login exitoso');
    } else {
      throw Exception(utf8.decode(response.bodyBytes));
    }
  }

  /// Registro de usuario contra tu backend
  Future<String> registro(String nombre, String email, String password) async {
    final url = Uri.parse('$baseUrl/registro');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nombre': nombre,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Registro exitoso');
      return response.body;
    } else {
      print('Error en registro: ${response.statusCode}');
      throw Exception(response.body);
    }
  }

  /// Login con Google + validación con backend Spring Boot
  Future<void> loginWithGoogle() async {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception("Inicio cancelado");

    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
    final User? firebaseUser = userCredential.user;

    if (firebaseUser == null) throw Exception("Error de autenticación con Firebase");

    final idToken = await firebaseUser.getIdToken();

    final url = Uri.parse('$baseUrl/google-login');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('usuario_id', data['id'].toString());
      prefs.setString('usuario_nombre', data['nombreCompleto']);
      prefs.setString('usuario_email', data['email']);
      prefs.setString('usuario_origen', data['origen']);
      prefs.setBool('usuario_activo', data['activo']);
      print('Login con Google exitoso');
    } else {
      throw Exception(utf8.decode(response.bodyBytes));
    }
  }

  /// Cerrar sesión y limpiar sesión local
  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Verificar si el usuario está logueado (por SharedPreferences)
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('usuario_id');
  }

  /// Solicitar recuperación de contraseña
  Future<void> recuperarPassword(String email) async {
    final url = Uri.parse('$baseUrl/recuperar');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error: ${utf8.decode(response.bodyBytes)}');
    }
  }

  /// Reset de contraseña con token
  Future<bool> resetPassword(String token, String nuevaPassword) async {
    final url = Uri.parse('$baseUrl/reset-password');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'token': token,
        'nuevaPassword': nuevaPassword,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 400) {
      return false;
    } else {
      throw Exception('Error inesperado: ${response.statusCode}');
    }
  }
}