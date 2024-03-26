import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'variables.dart';
import 'categories.dart';
import 'meal_details.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  

  int _currentIndex = 0;

  TextEditingController _controller = TextEditingController();
  String _mealName = '';

  PageController _pageController = PageController();

  void _fetchMealDetails(String mealName) async {
    final url = '${Variables.baseUrl}/search.php?s=$mealName';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['meals'] != null) {
        final mealInstructions = (data['meals'][0]['strInstructions'] as String)
            .split('\n')
            .where((instruction) => instruction.trim().isNotEmpty)
            .toList();
        final mealImage = data['meals'][0]['strMealThumb'];
        final mealName = data['meals'][0]['strMeal'];
        final mealCategory = data['meals'][0]['strCategory'];
        final List<String?> mealIngredientsWithNull = List.generate(
          20,
          (index) {
            final ingredient = data['meals'][0]['strIngredient${index + 1}'];
            final measure = data['meals'][0]['strMeasure${index + 1}'];
            if (ingredient != null && ingredient.isNotEmpty) {
              return '$measure $ingredient';
            }
            return null;
          },
        );

        final mealIngredients =
            mealIngredientsWithNull.whereType<String>().toList();

        final youtubeLink = data['meals'][0]['strYoutube'];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MealDetailsWidget(
              mealName: mealName,
              mealCategory: mealCategory,
              mealIngredients: mealIngredients,
              mealImage: mealImage,
              mealInstructions: mealInstructions,
              youtubeLink: youtubeLink,
            ),
          ),
        );
      } else {
        _showMealNotFoundDialog(context);
      }
    }
  }

  void _showMealNotFoundDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          backgroundColor: Color.fromARGB(227, 233, 150, 159),
          title: Text("Meal Not Found"),
          content: Text("The meal you searched for was not found."),
          contentPadding: EdgeInsets.all(20),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    Text(
                      'Welcome to Dish-Cover!',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 153, 71, 3),
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Find your favorite recipes here',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 59, 58, 58),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextFormField(
                          controller: _controller,
                          decoration: InputDecoration(
                            hintText: 'Search meal...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _mealName = value;
                            });
                          },
                        ),
                      ),
                    ),
                    if (_mealName.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                            _mealName = '';
                          });
                        },
                      ),
                    Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                          color: Color.fromARGB(255, 215, 132, 44),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            _fetchMealDetails(_mealName);
                          },
                          padding: EdgeInsets.only(left: 3.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Categories(),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: HomePage(),
  ));
}
