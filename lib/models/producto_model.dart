class Producto {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagenUrl; // Imagen destacada (thumbnail)
  final int cantidadDisponible;
  final List<String> imagenes; // ✅ nuevas imágenes
  final List<String> videos; // ✅ nuevos videos

  Producto({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenUrl,
    required this.cantidadDisponible,
    required this.imagenes,
    required this.videos,
  });

  factory Producto.fromFirestore(Map<String, dynamic> data, String id) {
    return Producto(
      id: id,
      nombre: data['nombre'],
      descripcion: data['descripcion'],
      precio: (data['precio'] as num).toDouble(),
      imagenUrl: data['imagenUrl'],
      cantidadDisponible: data['cantidadDisponible'] ?? 0,
      imagenes: List<String>.from(data['imagenes'] ?? []),
      videos: List<String>.from(data['videos'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagenUrl': imagenUrl,
      'cantidadDisponible': cantidadDisponible,
      'imagenes': imagenes,
      'videos': videos,
    };
  }
}
