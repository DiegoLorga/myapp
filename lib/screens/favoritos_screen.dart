import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/favoritos_provider.dart';
import '../models/producto_model.dart';
import 'product_details.dart';

class FavoritosScreen extends StatelessWidget {
  const FavoritosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoritos = context.watch<FavoritosProvider>().favoritos;

    if (favoritos.isEmpty) {
      return const Center(
        child: Text(
          'No tienes productos favoritos.',
          style: TextStyle(fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      itemCount: favoritos.length,
      itemBuilder: (context, index) {
        final producto = favoritos[index];
        return ListTile(
          leading: Image.network(producto.imagenUrl, width: 50),
          title: Text(producto.nombre),
          subtitle: Text(producto.descripcion),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(producto: producto),
              ),
            );
          },
        );
      },
    );
  }
}
