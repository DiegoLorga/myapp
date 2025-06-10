import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favoritos_provider.dart';
import '../models/producto_model.dart';
import 'product_details.dart';

class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritosProvider = context.watch<FavoritosProvider>();
    final favoritos = favoritosProvider.favoritos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Favoritos'),
        backgroundColor: const Color.fromARGB(255, 44, 104, 235),
      ),
      body:
          favoritos.isEmpty
              ? const Center(
                child: Text(
                  'No tienes productos favoritos.',
                  style: TextStyle(fontSize: 18),
                ),
              )
              : ListView.builder(
                itemCount: favoritos.length,
                itemBuilder: (context, index) {
                  final producto = favoritos[index];
                  return ListTile(
                    leading: Image.network(producto.imagenUrl, width: 50),
                    title: Text(producto.nombre),
                    subtitle: Text(producto.descripcion),
                    trailing: IconButton(
                      icon: const Icon(Icons.favorite, color: Colors.red),
                      tooltip: 'Eliminar de favoritos',
                      onPressed: () {
                        favoritosProvider.toggleFavorito(producto);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${producto.nombre} eliminado de favoritos',
                            ),
                          ),
                        );
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => ProductDetailsScreen(producto: producto),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
