import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/producto_model.dart';
import 'package:myapp/screens/product_details.dart';
import 'package:myapp/screens/carrito_screen.dart';
import 'package:myapp/screens/favoritos_screen.dart'; // ✅ AÑADIDO
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void cerrarSesion(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Volverá automáticamente al login porque tu AuthGate lo controla
  }

  @override
  Widget build(BuildContext context) {
    final productosRef = FirebaseFirestore.instance.collection('productos');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lorga toys'),
        backgroundColor: const Color.fromARGB(255, 44, 104, 235),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Ver carrito',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CarritoScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.favorite_border),
            tooltip: 'Ver favoritos',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FavoritosScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => cerrarSesion(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: productosRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final productos =
                snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return Producto.fromFirestore(data, doc.id);
                }).toList();

            return ListView.builder(
              itemCount: productos.length,
              itemBuilder: (context, index) {
                final p = productos[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 4,
                  child: ListTile(
                    leading: Image.network(
                      p.imagenUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(p.nombre),
                    subtitle: Text('\$${p.precio.toStringAsFixed(2)}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProductDetailsScreen(producto: p),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar productos'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
