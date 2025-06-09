import 'package:flutter/material.dart';
import '../models/producto_model.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/carrito_provider.dart';
import 'package:myapp/providers/favoritos_provider.dart'; // <- AÑADIDO

class ProductDetailsScreen extends StatelessWidget {
  final Producto producto;

  const ProductDetailsScreen({Key? key, required this.producto})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(producto.nombre),
        actions: [
          Consumer<FavoritosProvider>(
            builder: (context, favProvider, _) {
              final esFavorito = favProvider.esFavorito(producto);
              return IconButton(
                icon: Icon(
                  esFavorito ? Icons.favorite : Icons.favorite_border,
                  color: esFavorito ? Colors.red : null,
                ),
                onPressed: () {
                  favProvider.toggleFavorito(producto);
                  final mensaje = esFavorito
                      ? 'Eliminado de favoritos'
                      : 'Agregado a favoritos';
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(mensaje)),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                producto.imagenUrl,
                height: 200,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.image_not_supported, size: 100),
              ),
            ),
            SizedBox(height: 20),
            Text(
              producto.nombre,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(producto.descripcion),
            SizedBox(height: 10),
            Text(
              '\$${producto.precio.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 20, color: Colors.green),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: Icon(Icons.add_shopping_cart),
                label: Text('Agregar al carrito'),
                onPressed: () {
                  Provider.of<CarritoProvider>(
                    context,
                    listen: false,
                  ).agregarProducto(producto);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text('${producto.nombre} agregado al carrito'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
