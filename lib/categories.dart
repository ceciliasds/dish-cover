import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'variables.dart';
import 'meal_details.dart';

class Categories extends StatefulWidget {
  @override
  _CategoriesState createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final url = '${Variables.baseUrl}/categories.php';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> categoryList = data['categories'];
      setState(() {
        categories = categoryList.map<Map<String, dynamic>>((category) => {
          'name': category['strCategory'] as String,
          'image': category['strCategoryThumb'] as String
        }).toList();
      });
    } else {
      print('Failed to load categories: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MealsByCategoryPage(
                    categoryName: categories[index]['name'] as String,
                  ),
                ),
              );
            },
            child: CategoryBox(
              name: categories[index]['name'] as String,
              image: categories[index]['image'] as String,
            ),
          );
        },
      ),
    );
  }
}

class CategoryBox extends StatelessWidget {
  final String name;
  final String image;

  CategoryBox({required this.name, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        image: DecorationImage(
          image: NetworkImage(image),
          fit: BoxFit.cover,
        ),
        border: Border.all(
          color: Colors.black, 
          width: 1.0, 
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            color: Colors.black.withOpacity(0.5),
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MealsByCategoryPage extends StatefulWidget {
  final String categoryName;

  MealsByCategoryPage({required this.categoryName});

  @override
  _MealsByCategoryPageState createState() => _MealsByCategoryPageState();
}

class _MealsByCategoryPageState extends State<MealsByCategoryPage> {
  List<dynamic> meals = [];

  @override
  void initState() {
    super.initState();
    _fetchMeals();
  }

 Future<void> _fetchMeals() async {
  final url = '${Variables.baseUrl}/filter.php?c=${widget.categoryName}';
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final List<dynamic> mealList = data['meals'];
    
    List<Future<dynamic>> mealFutures = [];

    for (var meal in mealList) {
      final mealFuture = http.get(Uri.parse('${Variables.baseUrl}/lookup.php?i=${meal['idMeal']}'));
      mealFutures.add(mealFuture);
    }

    final List<dynamic> mealResponses = await Future.wait(mealFutures);

    final List<dynamic> fetchedMeals = [];
    for (var mealResponse in mealResponses) {
      if (mealResponse.statusCode == 200) {
        final mealData = json.decode(mealResponse.body);
        fetchedMeals.add(mealData['meals'][0]);
      } else {
        print('Failed to load meal details: ${mealResponse.statusCode}');
      }
    }

    setState(() {
      meals = fetchedMeals;
    });
  } else {
    print('Failed to load meals: ${response.statusCode}');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
      title: Text(widget.categoryName),
      backgroundColor: Color.fromARGB(255, 215, 132,44),
    ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: meals.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: SizedBox(
                height: 150, 
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MealDetailsWidget(
                          mealName: meals[index]['strMeal'],
                          mealImage: meals[index]['strMealThumb'],
                          mealCategory: meals[index]['strCategory'],
                          mealIngredients: _extractIngredients(meals[index]),
                          mealInstructions: _extractInstructions(meals[index]),
                          youtubeLink: meals[index]['strYoutube'], 
                        ),
                      ),
                    );
                  },
                  child: MealTile(
                    mealName: meals[index]['strMeal'],
                    mealImage: meals[index]['strMealThumb'],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<String> _extractIngredients(Map<String, dynamic> meal) {
    final List<String> ingredients = [];
    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      final measure = meal['strMeasure$i'];
      if (ingredient != null && ingredient.isNotEmpty && measure != null && measure.isNotEmpty) {
        ingredients.add('$measure $ingredient');
      } else {
        break;
      }
    }
    return ingredients;
  }

  List<String> _extractInstructions(Map<String, dynamic> meal) {
    final String instructions = meal['strInstructions'];
    return instructions.split('\n').where((element) => element.isNotEmpty).toList();
  }
}

class MealTile extends StatelessWidget {
  final String mealName;
  final String mealImage;

  const MealTile({Key? key, required this.mealName, required this.mealImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        image: DecorationImage(
          image: NetworkImage(mealImage),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        color: Colors.black.withOpacity(0.5),
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
        child: Text(
          mealName,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      ),
    );
  }
}

void main() {
 
  runApp(MaterialApp(
    home: Categories(),
  ));
}
