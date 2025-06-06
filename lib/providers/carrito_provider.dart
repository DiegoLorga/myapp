import 'package:flutter/material.dart';
import '../models/producto_model.dart';

class ItemCarrito {
  final Producto producto;
  int cantidad;

  ItemCarrito({required this.producto, this.cantidad = 1});
}

class CarritoProvider with ChangeNotifier {
  final List<ItemCarrito> _items = [];

  List<ItemCarrito> get items => _items;

  double get total => _items.fold(
    0,
    (suma, item) => suma + item.producto.precio * item.cantidad,
  );

  void agregarProducto(Producto producto) {
    final index = _items.indexWhere((item) => item.producto.id == producto.id);
    if (index >= 0) {
      _items[index].cantidad += 1;
    } else {
      _items.add(ItemCarrito(producto: producto));
    }
    notifyListeners();
  }

  void removerProducto(String id) {
    _items.removeWhere((item) => item.producto.id == id);
    notifyListeners();
  }

  void cambiarCantidad(String id, int nuevaCantidad) {
    final index = _items.indexWhere((item) => item.producto.id == id);
    if (index >= 0) {
      _items[index].cantidad = nuevaCantidad;
      notifyListeners();
    }
  }

  void vaciarCarrito() {
    _items.clear();
    notifyListeners();
  }
}
