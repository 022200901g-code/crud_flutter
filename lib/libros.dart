class Libro {
  int? id;               // Identificador único (nullable porque lo genera SQLite)
  String tituloLibro;    // Título del libro

  // Constructor de la clase Libro
  Libro({this.id, required this.tituloLibro});

  // Convierte un objeto Libro en un Map (clave-valor)
  // Esto es necesario para insertar o actualizar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,                   // Clave "id" con valor de la propiedad id
      'tituloLibro': tituloLibro, // Clave "tituloLibro" con valor del título
    };
  }

  // Convierte un Map (obtenido de SQLite) en un objeto Libro
  factory Libro.fromMap(Map<String, dynamic> map) {
    return Libro(
      id: map['id'], 
      tituloLibro: map['tituloLibro'],
    );
  }
}
