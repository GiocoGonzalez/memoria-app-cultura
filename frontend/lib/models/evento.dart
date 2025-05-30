class Evento {
  final int id;
  final String titulo;
  final String ciudad;
  final String categoria;
  final String descripcion;
  final String? urlInscripcion;

  Evento({
    required this.id,
    required this.titulo,
    required this.ciudad,
    required this.categoria,
    required this.descripcion,
    this.urlInscripcion,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? '',
      ciudad: json['ciudad']?['nombre'] ?? 'Desconocida',
      categoria: json['categoria']?['nombre'] ?? 'General',
      descripcion: json['descripcion'] ?? '',
      urlInscripcion: json['urlInscripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'ciudad': ciudad,
      'categoria': categoria,
      'descripcion': descripcion,
      'urlInscripcion': urlInscripcion,
    };
  }
}