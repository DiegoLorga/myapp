import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/carrito_provider.dart';

class CarritoScreen extends StatelessWidget {
  const CarritoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final carrito = Provider.of<CarritoProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Carrito de compras')),
      body:
          carrito.items.isEmpty
              ? Center(child: Text('El carrito está vacío'))
              : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: carrito.items.length,
                      itemBuilder: (context, index) {
                        final item = carrito.items[index];
                        return ListTile(
                          leading: Image.network(
                            item.producto.imagenUrl,
                            width: 50,
                          ),
                          title: Text(item.producto.nombre),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Precio: \$${item.producto.precio.toStringAsFixed(2)}',
                              ),
                              Row(
                                children: [
                                  Text('Cantidad: '),
                                  DropdownButton<int>(
                                    value: item.cantidad,
                                    items:
                                        List.generate(10, (i) => i + 1)
                                            .map(
                                              (n) => DropdownMenuItem(
                                                value: n,
                                                child: Text('$n'),
                                              ),
                                            )
                                            .toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        carrito.cambiarCantidad(
                                          item.producto.id,
                                          value,
                                        );
                                      }
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () async {
                                      await carrito.removerProducto(
                                        item.producto.id,
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text('Producto eliminado'),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Text(
                            '\$${(item.producto.precio * item.cantidad).toStringAsFixed(2)}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text(
                          'Total: \$${carrito.total.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              await carrito.confirmarCompra();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Compra realizada con éxito'),
                                ),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                          child: Text('Confirmar compra'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}
