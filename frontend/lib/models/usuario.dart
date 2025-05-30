class Usuario {
  final int id;
  final String nombreCompleto;
  final String email;

  Usuario({
    required this.id,
    required this.nombreCompleto,
    required this.email,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombreCompleto: json['nombreCompleto'],
      email: json['email'],
    );
  }
}
