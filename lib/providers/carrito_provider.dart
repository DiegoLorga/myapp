import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/producto_model.dart';

class ItemCarrito {
  final Producto producto;
  int cantidad;

  ItemCarrito({required this.producto, required this.cantidad});
}

class CarritoProvider with ChangeNotifier {
  List<ItemCarrito> _items = [];

  List<ItemCarrito> get items => _items;

  double get total => _items.fold(
    0,
    (suma, item) => suma + item.producto.precio * item.cantidad,
  );

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  Future<void> setUser(String uid) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(uid)
              .collection('carrito')
              .get();

      _items =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return ItemCarrito(
              producto: Producto.fromFirestore(data, doc.id),
              cantidad: data['cantidad'] ?? 1,
            );
          }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error cargando carrito: $e");
    }
  }

  /// 🔄 Recarga el carrito desde Firestore
  Future<void> recargarCarrito() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('usuarios')
              .doc(uid)
              .collection('carrito')
              .get();

      _items =
          snapshot.docs.map((doc) {
            final data = doc.data();
            return ItemCarrito(
              producto: Producto.fromFirestore(data, doc.id),
              cantidad: data['cantidad'] ?? 1,
            );
          }).toList();

      notifyListeners();
    } catch (e) {
      debugPrint("❌ Error cargando carrito: $e");
    }
  }

  Future<void> agregarProducto(Producto producto) async {
    final index = _items.indexWhere((item) => item.producto.id == producto.id);
    final docRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('carrito')
        .doc(producto.id);

    if (index >= 0) {
      _items[index].cantidad += 1;
      await docRef.update({'cantidad': _items[index].cantidad});
    } else {
      _items.add(ItemCarrito(producto: producto, cantidad: 1));
      await docRef.set({...producto.toMap(), 'cantidad': 1});
    }

    notifyListeners();
  }

  Future<void> cambiarCantidad(String id, int nuevaCantidad) async {
    final index = _items.indexWhere((item) => item.producto.id == id);
    if (index >= 0) {
      _items[index].cantidad = nuevaCantidad;

      final docRef = FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .collection('carrito')
          .doc(id);

      await docRef.update({'cantidad': nuevaCantidad});
      notifyListeners();
    }
  }

  Future<void> removerProducto(String id) async {
    _items.removeWhere((item) => item.producto.id == id);

    final docRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('carrito')
        .doc(id);

    await docRef.delete();
    notifyListeners();
  }

  Future<void> confirmarCompra() async {
    final refCarrito = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('carrito');

    final productosRef = FirebaseFirestore.instance.collection('productos');

    for (var item in _items) {
      final productoDoc = productosRef.doc(item.producto.id);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(productoDoc);
        final currentStock = snapshot['cantidadDisponible'] ?? 0;
        final nuevoStock = currentStock - item.cantidad;

        if (nuevoStock < 0) throw Exception("Stock insuficiente");

        transaction.update(productoDoc, {'cantidadDisponible': nuevoStock});
      });
    }

    // Vaciar carrito
    final snapshot = await refCarrito.get();
    for (var doc in snapshot.docs) {
      await doc.reference.delete();
    }

    _items.clear();
    notifyListeners();
  }
}
