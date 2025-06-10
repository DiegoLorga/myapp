import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarProductoScreen extends StatefulWidget {
  const AgregarProductoScreen({super.key});

  @override
  _AgregarProductoScreenState createState() => _AgregarProductoScreenState();
}

class _AgregarProductoScreenState extends State<AgregarProductoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _imagenUrlCtrl = TextEditingController();

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _imagenUrlCtrl.dispose();
    super.dispose();
  }

  void _guardarProducto() async {
    if (_formKey.currentState!.validate()) {
      final producto = {
        'nombre': _nombreCtrl.text.trim(),
        'descripcion': _descripcionCtrl.text.trim(),
        'precio': double.parse(_precioCtrl.text),
        'imagenUrl': _imagenUrlCtrl.text.trim(),
      };

      await FirebaseFirestore.instance.collection('productos').add(producto);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto agregado correctamente')),
      );

      Navigator.pop(context); // Vuelve a pantalla anterior
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Agregar producto')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreCtrl,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator:
                    (value) => value!.isEmpty ? 'Ingrese el nombre' : null,
              ),
              TextFormField(
                controller: _descripcionCtrl,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator:
                    (value) => value!.isEmpty ? 'Ingrese la descripción' : null,
              ),
              TextFormField(
                controller: _precioCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Precio'),
                validator:
                    (value) => value!.isEmpty ? 'Ingrese el precio' : null,
              ),
              TextFormField(
                controller: _imagenUrlCtrl,
                decoration: InputDecoration(labelText: 'URL de imagen'),
                validator:
                    (value) =>
                        value!.isEmpty ? 'Ingrese la URL de imagen' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _guardarProducto,
                child: Text('Guardar producto'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
