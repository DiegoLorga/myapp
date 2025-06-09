import 'package:flutter/material.dart';
import '../models/producto_model.dart';

class FavoritosProvider with ChangeNotifier {
  final List<Producto> _favoritos = [];

  List<Producto> get favoritos => _favoritos;

  void toggleFavorito(Producto producto) {
    final existe = _favoritos.any((p) => p.id == producto.id);
    if (existe) {
      _favoritos.removeWhere((p) => p.id == producto.id);
    } else {
      _favoritos.add(producto);
    }
    notifyListeners();
  }

  bool esFavorito(Producto producto) {
    return _favoritos.any((p) => p.id == producto.id);
  }
}
