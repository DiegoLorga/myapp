import 'package:flutter/material.dart';
import 'package:myapp/models/producto_model.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/carrito_provider.dart';
import 'package:myapp/providers/favoritos_provider.dart'; // ✅ Importado para favoritos

class ProductDetailsScreen extends StatefulWidget {
  final Producto producto;

  const ProductDetailsScreen({super.key, required this.producto});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  List<Widget> mediaWidgets = [];
  final PageController _pageController = PageController();

  final List<VideoPlayerController> _videoControllers = [];
  final List<ChewieController> _chewieControllers = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    List<Widget> tempWidgets = [];

    // Agrega imágenes
    tempWidgets.addAll(
      widget.producto.imagenes.map(
        (url) => Image.network(url, fit: BoxFit.contain),
      ),
    );

    // Intenta agregar videos, atrapando errores
    for (String videoUrl in widget.producto.videos) {
      try {
        final videoController = VideoPlayerController.network(videoUrl);
        await videoController.initialize();
        _videoControllers.add(videoController);

        final chewieController = ChewieController(
          videoPlayerController: videoController,
          autoPlay: false,
          looping: false,
          showControls: true,
        );
        _chewieControllers.add(chewieController);

        tempWidgets.add(
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chewie(controller: chewieController),
          ),
        );
      } catch (e) {
        debugPrint("❌ Error cargando video: $e");
      }
    }

    setState(() {
      mediaWidgets = tempWidgets;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var c in _videoControllers) {
      c.dispose();
    }
    for (var ch in _chewieControllers) {
      ch.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;

    return Scaffold(
      appBar: AppBar(
        title: Text(producto.nombre),
        backgroundColor: Colors.deepPurple,
        actions: [
          Consumer<FavoritosProvider>(
            builder: (context, favProvider, _) {
              final esFav = favProvider.esFavorito(producto);
              return IconButton(
                icon: Icon(
                  esFav ? Icons.favorite : Icons.favorite_border,
                  color: esFav ? Colors.red : Colors.white,
                ),
                onPressed: () {
                  favProvider.toggleFavorito(producto);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        esFav
                            ? 'Eliminado de favoritos'
                            : 'Agregado a favoritos',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carrusel
                    SizedBox(
                      height: 300,
                      child: GestureDetector(
                        onVerticalDragUpdate: (details) {
                          _pageController.position.moveTo(
                            _pageController.position.pixels - details.delta.dy,
                          );
                        },
                        onHorizontalDragUpdate: (details) {
                          _pageController.position.moveTo(
                            _pageController.position.pixels - details.delta.dx,
                          );
                        },
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: mediaWidgets.length,
                          itemBuilder: (context, index) {
                            return Center(child: mediaWidgets[index]);
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Descripción
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        producto.descripcion,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Precio
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        '\$${producto.precio.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors.green,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Cantidad disponible
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Disponible: ${producto.cantidadDisponible} unidades',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Botón: Agregar al carrito
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.add_shopping_cart),
                          label: const Text('Agregar al carrito'),
                          onPressed:
                              producto.cantidadDisponible > 0
                                  ? () async {
                                    final carrito =
                                        context.read<CarritoProvider>();
                                    await carrito.agregarProducto(producto);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Producto agregado al carrito',
                                        ),
                                      ),
                                    );
                                  }
                                  : null,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
    );
  }
}
