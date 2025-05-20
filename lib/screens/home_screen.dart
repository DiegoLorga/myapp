import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/recipe_providers.dart';
import 'package:myapp/screens/recipe_details.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // probando fetchRecipes
    //final data = fetchRecipes();
    //fetchRecipes();

    final recipesProvider = Provider.of<RecipeProviders>(
      context,
      listen: false,
    );
    recipesProvider.fetchRecipes();

    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      //body: FutureBuilder<List<dynamic>>(
      //future: fetchRecipes(),
      body: Consumer<RecipeProviders>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (provider.recipes.isEmpty) {
            return Center(child: Text('No hay recetas'));
          }

          return ListView.builder(
            itemCount: provider.recipes.length,
            itemBuilder: (context, index) {
              return _recipesCard(context, provider.recipes[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showButton(context);
        },
        backgroundColor: colors.primary,
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<void> _showButton(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder:
          (_) => Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            height: 500,
            child: FormularioReceta(),
          ),
    );
  }

  Widget _recipesCard(BuildContext context, dynamic recipe) {
    final colors = Theme.of(context).colorScheme;
    //print(recipe);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            //builder: (context) => FavoritesScreen(),
            builder: (context) => RecipeDetails(recipesData: recipe),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: 125,
          child: Card(
            color: Colors.amberAccent,
            child: Row(
              children: <Widget>[
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        //'https://myplate-prod.azureedge.us/sites/default/files/styles/recipe_525_x_350_/public/2022-01/Noodles_1.jpg?itok=D8SbUIWg',
                        //'https://www.excelsior.com.mx/800x600/filters:format(webp):quality(75)/media/pictures/2025/05/03/3301163.jpg',
                        recipe.imageLink,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // child: ClipRRect(
                  //   borderRadius: BorderRadius.circular(10),
                  //   child: Container(),
                  //   //child: Text("rpu"),
                  // ),
                ),
                SizedBox(width: 50, height: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      "Nombre: ${recipe.name}",
                      style: TextStyle(
                        fontSize: 26,
                        fontFamily: 'Quicksand',
                        color: colors.primary,
                      ),
                    ),
                    Container(width: 100, height: 3, color: colors.primary),
                    SizedBox(height: 5),
                    Text(
                      "By ${recipe.author}",
                      style: TextStyle(fontSize: 12, fontFamily: 'QuickSand'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FormularioReceta extends StatelessWidget {
  FormularioReceta({super.key});

  //controlador
  final TextEditingController _recipeName = TextEditingController();
  final TextEditingController _recipeAuthor = TextEditingController();
  final TextEditingController _recipeURL = TextEditingController();
  final TextEditingController _recipeDescription = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Nueva receta",
              style: TextStyle(color: colors.primary, fontSize: 20),
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _recipeName,
              context: context,
              label: "Nombre de la receta",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Introduce el nombre de la receta';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _recipeAuthor,
              context: context,
              label: "Autor de la receta",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Introduce el nombre del autor';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _recipeURL,
              context: context,
              label: "URL de la imagen",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Introduce la URL de la imagen';
                }
                return null;
              },
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _recipeDescription,
              context: context,
              label: "Descripción",
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Introduce la descripción';
                }
                return null;
              },
              maxLines: 4,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Guardar receta",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String? Function(String?) validator,
    required TextEditingController controller,
    required BuildContext context,
    required String label,
    int maxLines = 1,
  }) {
    final colors = Theme.of(context).colorScheme;
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontFamily: 'QuickSand', color: colors.primary),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: colors.tertiary, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
      maxLines: maxLines,
    );
  }
}
