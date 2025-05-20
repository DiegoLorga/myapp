import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/recipe_providers.dart';
import 'package:myapp/screens/favorites_screen.dart';
import 'package:myapp/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => RecipeProviders())],
      child: MaterialApp(
        title: 'Recetario',
        theme: ThemeData(fontFamily: 'Montserrat'),
        //theme: ThemeData(fontFamily: 'Diplomacy'),
        home: Recetario(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class Recetario extends StatelessWidget {
  const Recetario({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colors.primary,
          title: Text(
            "Recetario de mamá",
            style: TextStyle(color: Colors.white),
          ),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            tabs: <Widget>[
              Tab(icon: Icon(Icons.home), text: 'Inicio base'),
              Tab(icon: Icon(Icons.favorite), text: 'Favoritos'),
            ],
          ),
        ),
        body: //HomeScreen(),
            TabBarView(children: [HomeScreen(), FavoritesScreen()]),
      ),
    );
  }
}
