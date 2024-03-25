import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';


class MealDetailsWidget extends StatelessWidget {
  final String mealImage;
  final List<String> mealInstructions;
  final String mealName;
  final String mealCategory;
  final List<String> mealIngredients;
  final String youtubeLink; 
  
  MealDetailsWidget({
    required this.mealImage,
    required this.mealInstructions,
    required this.mealName,
    required this.mealCategory,
    required this.mealIngredients,
    required this.youtubeLink, 
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meal Details'),
        backgroundColor: Color.fromARGB(255, 215, 132, 44), 
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
             Stack(
  children: [
    Image.network(
      mealImage,
      height: 300,
      width: double.infinity,
      fit: BoxFit.cover,
    ),
    if (youtubeLink.isNotEmpty)
      Positioned(
        bottom: 20,
        right: 20,
        child: ElevatedButton(
          onPressed: () {
            
             launchUrl(Uri.parse(youtubeLink));
          },
          child: Icon(Icons.play_arrow),

        ),
      ),
  ],
),

              SizedBox(height: 20),
              _buildBoxWithShadow(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        children: [
                          Text(
                            '$mealName',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Category: $mealCategory',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Ingredients:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: mealIngredients.map((ingredient) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: IngredientCapsule(ingredient: ingredient),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Instructions:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  mealInstructions.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: EdgeInsets.only(right: 8.0),
                          padding: EdgeInsets.all(4.0),
                          decoration: BoxDecoration(
                            color: Colors.blue, 
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          child: Text(
                            '${index + 1}', 
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _removeLeadingNumber(mealInstructions[index]),
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  String _removeLeadingNumber(String instruction) {
  
    final regex = RegExp(r'^\d+\.\s*');
    return instruction.replaceAll(regex, '');
  }

  Widget _buildBoxWithShadow({required Widget child, double width = double.infinity}) {
    return Container(
      width: width,
      child: SizedBox(
        width: double.infinity,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                offset: Offset(0, 3),
              ),
            ],
            border: Border.all(color: Color.fromARGB(255, 94, 91, 91)),
          ),
          child: child,
        ),
      ),
    );
  }
}


class IngredientCapsule extends StatelessWidget {
  final String ingredient;

  const IngredientCapsule({Key? key, required this.ingredient}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 124, 205, 32),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(ingredient),
    );
  }
}
